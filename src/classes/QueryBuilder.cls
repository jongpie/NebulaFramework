/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public without sharing class QueryBuilder extends NebulaCore implements IQueryBuilder {

    private SObjectType sobjectType;
    private Map<String, Schema.SObjectField> sobjectTypeFieldMap;
    private Set<String> queryFields;
    private String query;
    private Schema.FieldSet fieldSet;
    private List<Schema.SObjectField> sobjectFieldList;
    private List<String> whereClauseList;
    private List<String> orderByList;
    private Integer limitCount;
    private Boolean forUpdate;

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

        this.addCommonQueryFields();
        this.addFieldSetMembers();
        this.addSObjectFields();
    }

    public QueryBuilder whereField(Schema.SObjectField field, QueryOperator operator, Object value) {
        String parsedValue = QueryUtils.toQueryString(value);

        this.whereClauseList.add(field + ' ' + operator.getValue() + ' ' + parsedValue);
        return this;
    }

    public QueryBuilder orderBy(Schema.SObjectField orderByField) {
        return this.orderBy(orderByField, null, null);
    }

    public QueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder) {
        return orderBy(orderByField, sortOrder, null);
    }

    public QueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder, QueryNullSortOrder nullSortOrder) {
        String sortOrderSoql = '';
        if(sortOrder == QuerySortOrder.ASCENDING) sortOrderSoql = ' ASC';
        else if(sortOrder == QuerySortOrder.DESCENDING) sortOrderSoql = ' DESC';

        if(nullSortOrder != null) sortOrderSoql += ' NULLS ' + nullSortOrder.name();

        this.orderByList.add(orderByField.getDescribe().getName() + sortOrderSoql);

        return this;
    }

    public QueryBuilder limitCount(Integer limitCount) {
        this.limitCount = limitCount;
        return this;
    }

    public QueryBuilder setAsUpdate() {
        this.forUpdate = true;
        return this;
    }

     // Query execution methods
    public SObject getFirstQueryResult() {
        return this.getQueryResults()[0];
    }

    public List<SObject> getQueryResults() {
        List<SObject> results = Database.query(this.getQuery());

        String logEntry = 'Query:\n' + this.query + '\n\nResults:\n' + results;
        this.addLogEntry(logEntry);

        return results;
    }

    public List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup) {
        List<SObject> results = Search.query(this.getSearchQuery(searchTerm, searchGroup))[0];

        String logEntry = 'Query:\n' + this.query + '\n\nResults:\n' + results;
        this.addLogEntry(logEntry);

        return results;
    }

    private String getQueryFieldString() {
        List<String> queryFieldList = new List<String>(this.queryFields);
        if(new NebulaSettings().repositorySettings.SortQueryFields__c) queryFieldList.sort();
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

    private String getQuery() {
        this.query = 'SELECT ' + this.getQueryFieldString()
            + '\nFROM ' + this.sobjectType
            + this.getWhereClauseString()
            + this.getOrderByString()
            + this.getLimitCountString()
            + this.getForUpdateString();

        this.addLogEntry(this.query);

        return this.query;
    }

    private String getSearchQuery(String searchTerm, QuerySearchGroup searchGroup) {
        this.query = 'FIND ' + QueryUtils.toQueryString(searchTerm)
            + '\nIN ' + searchGroup.name().replace('_', ' ')
            + '\nRETURNING ' + this.sobjectType + '('
                + this.getQueryFieldString()
                + this.getWhereClauseString()
                + this.getOrderByString()
                + this.getLimitCountString()
            + ')';

        if(this.forUpdate) this.addLogEntry('SOSL Search Query method flagged as FOR UPDATE. SOSL cannot use FOR UPDATE, ignoring');

        this.addLogEntry(this.query);

        return this.query;
    }

    private void addCommonQueryFields() {
        if(!new NebulaSettings().repositorySettings.IncludeCommonFields__c) return;

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