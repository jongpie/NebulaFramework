/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public class QueryBuilder extends NebulaCore implements IQueryBuilder {

    private String query;
    private Set<String> queryFields;
    private List<String> childRelationshipQueries;
    private List<String> whereClauseList;
    @testVisible private List<String> orderByList;
    private QueryFilterScope filterScope;
    @testVisible private Boolean forUpdate;
    private Integer limitCount;

    private Boolean addAllFields;
    // TODO remove maybe
    //private Schema.FieldSet fieldSet;
    //private List<Schema.SObjectField> sobjectFieldList;
    private SObjectType sobjectType;
    private Map<String, Schema.SObjectField> sobjectTypeFieldMap;

    public QueryBuilder() {
        this.currentModule = NebulaCore.Module.REPOSITORY;

        this.queryFields              = new Set<String>();
        this.childRelationshipQueries = new List<String>();
        this.whereClauseList          = new List<String>();
        this.orderByList              = new List<String>();
        this.forUpdate                = false;
        this.addAllFields             = false;

        this.addCommonQueryFields();
    }

    public IQueryBuilder setSObjectType(Schema.SObjectType sobjectType) {
        this.sobjectType         = sobjectType;
        this.sobjectTypeFieldMap = sobjectType.getDescribe().fields.getMap();
        return this;
    }

    public IQueryBuilder addFields(Schema.FieldSet fieldSet) {
        for(Schema.FieldSetMember field : fieldSet.getFields()) this.queryFields.add(field.getFieldPath().toLowerCase());
        return this;
    }

    public IQueryBuilder addFields(List<Schema.SObjectField> fields) {
        for(Schema.SObjectField field : fields) this.queryFields.add(field.getDescribe().getName().toLowerCase());
        return this;
    }

    public IQueryBuilder addAllFields() {
        // TODO
        this.addAllFields = true;
        for(Schema.SObjectField field : this.sobjectTypeFieldMap.values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            this.queryFields.add(fieldDescribe.getName());
        }
        return this;
    }

    public IQueryBuilder addAllStandardFields() {
        for(Schema.SObjectField field : this.sobjectTypeFieldMap.values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            // If it's not a standard field, skip it
            if(fieldDescribe.isCustom()) continue;

            this.queryFields.add(fieldDescribe.getName());
        }
        return this;
    }

    public IQueryBuilder addAllCustomFields() {
        for(Schema.SObjectField field : this.sobjectTypeFieldMap.values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            // If it's not a custom field, skip it
            if(!fieldDescribe.isCustom()) continue;

            this.queryFields.add(field.getDescribe().getName());
        }
        return this;
    }


    public IQueryBuilder filterBy(IQueryFilter queryFilter) {
        return this.filterBy(new List<IQueryFilter>{queryFilter});
    }

    public IQueryBuilder filterBy(List<IQueryFilter> queryFilters) {
        if(queryFilters == null) return this;

        for(IQueryFilter queryFilter : queryFilters) this.whereClauseList.add(queryFilter.getValue());
        return this;
    }

    public IQueryBuilder includeChildrenRecords(Schema.SObjectField childToParentRelationshipField, ISObjectRepository childSObjectRepository) {
        return this.includeChildrenRecords(new Map<Schema.SObjectField, ISObjectRepository>{childToParentRelationshipField => childSObjectRepository});
    }

    public IQueryBuilder includeChildrenRecords(Map<Schema.SObjectField, ISObjectRepository> childFieldToChildSObjectRepositoryMap) {
        for(Schema.SObjectField sobjectField : childFieldToChildSObjectRepositoryMap.keySet()) {
            IQueryBuilder childQueryBuilder = childFieldToChildSObjectRepositoryMap.get(sobjectField).getQueryBuilder();

            this.childRelationshipQueries.add(childQueryBuilder.getQuery(sobjectField));
        }
        return this;
    }

    public IQueryBuilder orderBy(Schema.SObjectField orderByField) {
        return this.orderBy(orderByField, null, null);
    }

    public IQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder) {
        return this.orderBy(orderByField, sortOrder, null);
    }

    public IQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder, QueryNullSortOrder nullsSortOrder) {
        String sortOrderSoql = '';
        if(sortOrder == QuerySortOrder.ASCENDING) sortOrderSoql = ' ASC';
        else if(sortOrder == QuerySortOrder.DESCENDING) sortOrderSoql = ' DESC';

        if(nullsSortOrder != null) sortOrderSoql += ' NULLS ' + nullsSortOrder;

        this.orderByList.add(orderByField.getDescribe().getName() + sortOrderSoql);

        return this;
    }

    public IQueryBuilder limitCount(Integer limitCount) {
        this.limitCount = limitCount;
        return this;
    }

    public IQueryBuilder setAsUpdate() {
        this.forUpdate = true;
        return this;
    }

    public IQueryBuilder usingScope(QueryFilterScope filterScope) {
        this.filterScope = filterScope;
        return this;
    }

    // Query execution methods
    public SObject getFirstQueryResult() {
        return this.getQueryResults()[0];
    }

    public List<SObject> getQueryResults() {
        List<SObject> results = Database.query(this.getQuery());

        this.logEntry(results);

        return results;
    }

    public virtual List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup) {
        List<SObject> results = Search.query(this.getSearchQuery(searchTerm, searchGroup))[0];

        this.logEntry(results);

        return results;
    }

    // Query string methods
    public String getQuery() {
        return this.getQuery(String.valueOf(this.sobjectType));
    }

    public String getQuery(Schema.SObjectField childRelationshipSObjectField) {
        Schema.SObjectType parentSObjectType = new SObjectFieldDescriber(childRelationshipSObjectField).getParentSObjectType();
        String childRelationshipName = new SObjectTypeDescriber(parentSObjectType).getChildRelationshipName(childRelationshipSObjectField);
        return this.getQuery(childRelationshipName);
    }

    private String getQuery(String sobjectQueryName) {
        this.query = 'SELECT ' + this.getQueryFieldString();

        // Only 1 level of child relationships is allowed, so don't include them if the SObject name isn't the current SObject Type
        if(sobjectQueryName == String.valueOf(this.sobjectType)) this.query += this.getChildRelationshipsQueryString();

        this.query +='\nFROM ' + sobjectQueryName
            + this.getWhereClauseString()
            + this.getOrderByString()
            + this.getLimitCountString()
            + this.getForUpdateString();

        return this.query;
    }

    private String getSearchQuery(String searchTerm, QuerySearchGroup searchGroup) {
        this.query = 'FIND ' + NebulaFactory.getQueryArgumentFormatter().getValue(searchTerm.toLowerCase())
            + '\nIN ' + searchGroup.name().replace('_', ' ')
            + '\nRETURNING ' + this.sobjectType + '('
                + this.getQueryFieldString()
                + this.getWhereClauseString()
                + this.getOrderByString()
                + this.getLimitCountString()
            + ')';

        if(this.forUpdate) Logger.addEntry(this, 'SOSL Search Query method flagged as FOR UPDATE. SOSL cannot use FOR UPDATE, ignoring');
        if(this.filterScope != null) Logger.addEntry(this, 'SOSL Search Query method flagged as USING SCOPE ' + this.filterScope + '. SOSL cannot use USING SCOPE, ignoring');

        return this.query;
    }

    private String getQueryFieldString() {
        Set<String> cleanedQueryField = new Set<String>();
        for(String queryField : new List<String>(this.queryFields)) {
            cleanedQueryField.add(queryField.toLowerCase());
        }
        this.queryFields = cleanedQueryField;
        List<String> queryFieldList = new List<String>(this.queryFields);
        queryFieldList.sort();
        return String.join(queryFieldList, ', ');
    }

    private String getChildRelationshipsQueryString() {
        if(this.childRelationshipQueries.isEmpty()) return '';

        return ',\n(' + String.join(childRelationshipQueries, '), (') + ')';
    }

    private String getWhereClauseString() {
        return !this.whereClauseList.isEmpty() ? '\nWHERE ' + String.join(this.whereClauseList, '\nAND ') : '';
    }

    private String getOrderByString() {
        return !this.orderByList.isEmpty() ? '\nORDER BY ' + String.join(new List<String>(orderByList), ', ') : '';
    }

    private String getLimitCountString() {
        return this.limitCount != null ? '\nLIMIT '+ this.limitCount : '';
    }

    private String getForUpdateString() {
        return this.orderByList.isEmpty() && this.forUpdate ? '\nFOR UPDATE' : '';
    }

    private void addCommonQueryFields() {
        if(!NebulaSettings.RepositorySettings.IncludeCommonFields__c) return;
        // Auto-add the common fields that are available for the SObject Type
        List<String> commonFieldNameList = new List<String>{
            'Id', 'CaseNumber', 'CreatedById', 'CreatedDate', 'IsClosed', 'LastModifiedById', 'LastModifiedDate',
            'Name', 'OwnerId', 'ParentId', 'Subject', 'RecordTypeId', 'SystemModStamp'
        };
        for(String commonFieldName : commonFieldNameList) {
            if(!this.sobjectTypeFieldMap.containsKey(commonFieldName)) continue;

            this.queryFields.add(commonFieldName.toLowerCase());
        }
    }

    private void logEntry(List<Object> results) {
        String logEntry = 'Query:\n' + this.query + '\n\nResults:\n' + JSON.serialize(results);
        Logger.addEntry(this, logEntry);
    }

}