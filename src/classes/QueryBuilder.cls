/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public without sharing class QueryBuilder extends NebulaCore implements IQueryBuilder {

    @testVisible private Boolean forUpdate;
    private Set<String> queryFields;
    private Integer limitCount;
    private String query;
    @testVisible private List<String> orderByList;
    private Map<String, Schema.SObjectField> sobjectTypeFieldMap;
    private List<String> whereClauseList;
    private QueryFilterScope filterScope;
    private List<String> childRelationshipQueries;

    private final Schema.FieldSet fieldSet;
    private final List<Schema.SObjectField> sobjectFieldList;
    private final SObjectType sobjectType;

    public QueryBuilder(Schema.SObjectType sobjectType, Schema.FieldSet fieldSet, List<Schema.SObjectField> sobjectFieldList) {
        this.sobjectType      = sobjectType;
        this.sobjectFieldList = sobjectFieldList;
        this.fieldSet         = fieldSet;

        this.forUpdate                = false;
        this.queryFields              = new Set<String>();
        this.orderByList              = new List<String>();
        this.sobjectTypeFieldMap      = this.sobjectType.getDescribe().fields.getMap();
        this.whereClauseList          = new List<String>();
        this.childRelationshipQueries = new List<String>();

        this.addCommonQueryFields();
        this.addFieldSetMembers();
        this.addSObjectFields();
        this.addSObjectTypeFields();
    }

    public IQueryBuilder filterBy(QueryFilter queryFilter) {
        return this.filterBy(new List<QueryFilter>{queryFilter});
    }

    public IQueryBuilder filterBy(List<QueryFilter> queryFilters) {
        for(QueryFilter queryFilter : queryFilters) {
            this.whereClauseList.add(queryFilter.getValue());
        }
        return this;
    }

    public IQueryBuilder includeChildRecords(Schema.SObjectField childToParentRelationshipField, IQueryBuilder childSObjectQueryBuilder) {
        return this.includeChildRecords(new Map<Schema.SObjectField, IQueryBuilder>{childToParentRelationshipField => childSObjectQueryBuilder});
    }

    public IQueryBuilder includeChildRecords(Map<Schema.SObjectField, IQueryBuilder> childFieldToChildSObjectQueryBuilderMap) {
        for(Schema.SObjectField sobjectField : childFieldToChildSObjectQueryBuilderMap.keySet()) {
            IQueryBuilder childQueryBuilder = childFieldToChildSObjectQueryBuilderMap.get(sobjectField);

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

/*    public String getChildRelationshipQueryString(Schema.SObjectField childToParentRelationshipField) {
        String childQuery = 'SELECT ' + this.getQueryFieldString() + this.getChildRelationshipsQueryString()
            + ' FROM ' + childToParentRelationshipField.getDescribe().getRelationshipName()
            + this.getWhereClauseString()
            + this.getOrderByString()
            + this.getLimitCountString();

        return childQuery;
    }*/

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

    public String getQuery(String sobjectQueryName) {
        //String sobjectQueryName = childRelationshipSObjectField.getDescribe().getRelationshipName();
        //String childRelationshipName = new SObjectTypeDescriber(this.sobjectType).getChildRelationshipName(childRelationshipSObjectField);
                                       //new SObjectTypeDescriber(Schema.Account.SObjectType).getChildRelationshipName(childRelationshipSObjectField))
        // childRelationshipSObjectField.getDescribe().getRelationshipName();
        //String sobjectQueryName = childRelationshipSObjectField == null ? String.valueOf(this.sobjectType) : childRelationshipName;

        this.query = 'SELECT ' + this.getQueryFieldString();

        // Only 1 level of child relationships is allowed, so don't include them if the SObject name isn't the current SObject Type
        if(sobjectQueryName == String.valueOf(this.sobjectType)) this.query += this.getChildRelationshipsQueryString();

        this.query +=' FROM ' + sobjectQueryName
            + this.getWhereClauseString()
            + this.getOrderByString()
            + this.getLimitCountString()
            + this.getForUpdateString();

        return this.query;
    }

    private String getSearchQuery(String searchTerm, QuerySearchGroup searchGroup) {
        this.query = 'FIND ' + new QueryArgumentFormatter(searchTerm.toLowerCase()).getValue()
            + ' IN ' + searchGroup.name().replace('_', ' ')
            + ' RETURNING ' + this.sobjectType + '('
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
        List<String> queryFieldList = new List<String>(this.queryFields);
        if(NebulaSettings.repositorySettings.SortQueryFields__c) queryFieldList.sort();
        return String.join(queryFieldList, ',');
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
        if(!NebulaSettings.repositorySettings.IncludeCommonFields__c) return;
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

    private void addFieldSetMembers() {
        if(this.fieldSet == null) return;

        for(Schema.FieldSetMember field : this.fieldSet.getFields()) this.queryFields.add(field.getFieldPath().toLowerCase());
    }

    private void addSObjectFields() {
        if(this.sobjectFieldList == null) return;

        for(Schema.SObjectField field : this.sobjectFieldList) this.queryFields.add(field.getDescribe().getName().toLowerCase());
    }

    private void addSObjectTypeFields() {
        if(this.fieldSet != null || this.sobjectFieldList != null) return;

        // If no field set or list of fields is provided, we enter 'lazy mode' and all fields for the SObject Type are added
        // This is effectively 'select * from <sobject>'. Performance issues can occur with large objects, so use carefully.
        for(Schema.SObjectField field : this.sobjectTypeFieldMap.values()) this.queryFields.add(field.getDescribe().getName().toLowerCase());
    }

    private void logEntry(List<Object> results) {
        String logEntry = 'Query:\n' + this.query + '\n\nResults:\n' + results;
        Logger.addEntry(this, logEntry);
    }

}