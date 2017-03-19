/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public without sharing class QueryBuilder extends NebulaCore implements IQueryBuilder {

    private SObjectType sobjectType;
    private Map<String, Schema.SObjectField> sobjectTypeFieldMap;
    private Set<String> queryFields;
    private Schema.FieldSet fieldSet;
    @testVisible private Boolean forUpdate;
    @testVisible private List<String> orderByList;
    @testVisible private Boolean shouldAddCommonFields;
    private List<Schema.SObjectField> sobjectFieldList;
    private List<String> whereClauseList;
    private Integer limitCount;
    private QueryFilterScope filterScope;

    public QueryBuilder(Schema.SObjectType sobjectType, Schema.FieldSet fieldSet, List<Schema.SObjectField> sobjectFieldList) {
        this.currentModule = NebulaCore.Module.REPOSITORY;

        this.sobjectType      = sobjectType;
        this.fieldSet         = fieldSet;
        this.sobjectFieldList = sobjectFieldList;

        this.sobjectTypeFieldMap = this.sobjectType.getDescribe().fields.getMap();
        this.queryFields         = new Set<String>();
        this.whereClauseList     = new List<String>();
        this.orderByList         = new List<String>();
        this.forUpdate           = false;
        this.shouldAddCommonFields = true;

        this.addCommonQueryFields();
        this.addFieldSetMembers();
        this.addSObjectFields();
    }

    public IQueryBuilder whereField(Schema.SObjectField field, QueryOperator operator, Object value) {
        String parsedValue = new QueryArgumentFormatter(value).getValue();
        String parsedOperator = operator.getValue();

        this.whereClauseList.add(field + ' ' + parsedOperator + ' ' + parsedValue);
        return this;
    }

    public IQueryBuilder whereField(Schema.SObjectField field, QueryOperator operator, List<Object> valueList) {
        String parsedValue = new QueryArgumentFormatter(valueList).getValue();
        String parsedOperator = operator.getValue();

        this.whereClauseList.add(field + ' ' + parsedOperator + ' ' + parsedValue);
        return this;
    }

    public IQueryBuilder orderBy(Schema.SObjectField orderByField) {
        return this.orderBy(orderByField, null, null);
    }

    public IQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder) {
        return this.orderBy(orderByField, sortOrder, null);
    }

    public IQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder, QueryNullSortOrder nullSortOrder) {
        String sortOrderSoql = '';
        if(sortOrder == QuerySortOrder.ASCENDING) sortOrderSoql = ' ASC';
        else if(sortOrder == QuerySortOrder.DESCENDING) sortOrderSoql = ' DESC';

        if(nullSortOrder != null) sortOrderSoql += ' NULLS ' + nullSortOrder.name();

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

    public IQueryBuilder turnOffCommonFields() {
        this.shouldAddCommonFields = false;
        return this;
    }

     // Query execution methods
    public SObject getFirstOrDefault() {
        return this.getQueryResults()[0];
    }

    public List<SObject> getQueryResults() {
        List<SObject> results = Database.query(this.getQuery());

        this.addLogEntry(logEntry);
        String logEntry = 'Query:\n' + this.query + '\n\nResults:\n' + results;

        return results;
    }

    public List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup) {
        List<SObject> results = Search.query(this.getSearchQuery(searchTerm, searchGroup))[0];

        this.addLogEntry(logEntry);
        String logEntry = 'Query:\n' + this.query + '\n\nResults:\n' + results;

        return results;
    }

    private String getQueryFieldString() {
        List<String> queryFieldList = new List<String>(this.queryFields);
        if(NebulaSettings.repositorySettings.SortQueryFields__c) queryFieldList.sort();
        return String.join(queryFieldList, ',');
    }

    private String getWhereClauseString() {
        String whereClauseString = '';
        if(!this.whereClauseList.isEmpty()) whereClauseString = '\nWHERE ' + String.join(this.whereClauseList, '\nAND ');
        return whereClauseString;
    }

    private String getOrderByString() {
        String orderByString = '';
        if(!this.orderByList.isEmpty()) orderByString = '\nORDER BY ' + String.join(new List<String>(orderByList), ', ');
        return orderByString;
    }

    private String getLimitCountString() {
        String limitString = '';
        if(this.limitCount != null) limitString = '\nLIMIT '+ this.limitCount;
        return limitString;
    }

    private String getForUpdateString() {
        String forUpdateString = '';
        if(this.orderByList.isEmpty() && this.forUpdate) forUpdateString = '\nFOR UPDATE';
        return forUpdateString;
    }

    private String getUsingScopeString() {
        String usingScopeString = '';
        if(this.filterScope != null) usingScopeString = '\nUSING SCOPE ' + this.filterScope.name();
        return usingScopeString;
// TODO figure out what to do for SOSL https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl_syntax.htm
    }

    private String getQueryString() {
        String query = 'SELECT ' + this.getQueryFieldString()
            + '\nFROM ' + this.sobjectType
            + this.getUsingScopeString()
            + this.getWhereClauseString()
            + this.getOrderByString()
            + this.getLimitCountString()
            + this.getForUpdateString();

        this.addLogEntry(query);

        return this.query;
    }

    private String getSearchQueryString(String searchTerm, QuerySearchGroup searchGroup) {
        String query = 'FIND ' + new QueryArgumentFormatter(searchTerm).getValue()
            + '\nIN ' + searchGroup.name().replace('_', ' ')
            + '\nRETURNING ' + this.sobjectType + '('
                + this.getQueryFieldString()
                + this.getWhereClauseString()
                + this.getOrderByString()
                + this.getLimitCountString()
            + ')';

        if(this.forUpdate) this.addLogEntry('SOSL Search Query method flagged as FOR UPDATE. SOSL cannot use FOR UPDATE, ignoring');
        if(this.filterScope != null) this.addLogEntry('SOSL Search Query method flagged as USING SCOPE ' + this.filterScope + '. SOSL cannot use USING SCOPE, ignoring');

        this.addLogEntry(query);

        return this.query;
    }

    private void addCommonQueryFields() {
        if(!NebulaSettings.repositorySettings.IncludeCommonFields__c) return;
        if(!this.shouldAddCommonFields) return;

        // Auto-add the common fields that are available for the SObject Type
        List<String> commonFieldNameList = new List<String>{
            'Id', 'CaseNumber', 'CreatedById', 'CreatedDate', 'IsClosed', 'LastModifiedById', 'LastModifiedDate',
            'Name', 'OwnerId', 'Subject', 'RecordTypeId', 'SystemModStamp'
        };
        for(String commonFieldName : commonFieldNameList) {
            if(!this.sobjectTypeFieldMap.containsKey(commonFieldName)) continue;

            this.queryFields.add(commonFieldName.toLowerCase());
        }
        this.addLogEntry('this.queryFields=' + this.queryFields);
    }

    private void addFieldSetMembers() {
        if(this.fieldSet == null) return;

        for(Schema.FieldSetMember field : this.fieldSet.getFields()) this.queryFields.add(field.getFieldPath().toLowerCase());
    }

    private void addSObjectFields() {
        if(this.sobjectFieldList == null) return;

        for(Schema.SObjectField field : this.sobjectFieldList) this.queryFields.add(field.getDescribe().getName().toLowerCase());
    }
}