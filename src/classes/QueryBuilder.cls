public without sharing class QueryBuilder extends Core {

    public enum SortOrder {ASCENDING, DESCENDING}
    public enum NullsSortOrder {FIRST, LAST}

    public enum SearchGroup {ALL_FIELDS, NAME_FIELDS, EMAIL_FIELDS, PHONE_FIELDS, SIDEBAR_FIELDS}

    private RepositorySettings__c repositorySettings;
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

        this.sobjectType      = sobjectType;
        this.fieldSet         = fieldSet;
        this.sobjectFieldList = sobjectFieldList;

        this.sobjectTypeFieldMap = this.sobjectType.getDescribe().fields.getMap();
        this.queryFields         = new Set<String>();
        this.whereClauseList     = new List<String>();
        this.orderByList         = new List<String>();
        this.forUpdate           = false;

        this.getRepositorySettings();
        this.addCommonQueryFields();
        this.addFieldSetMembers();
        this.addSObjectFields();
    }

    public QueryBuilder whereField(Schema.SObjectField field, String operator, Object value) {
        String parsedValue = SOQLUtils.toSOQLString(value);

        this.whereClauseList.add(field + ' ' + operator.trim() + ' ' + parsedValue);
        return this;
    }

    public QueryBuilder whereField(Schema.SObjectField field, String operator, List<Object> valueList) {
        String parsedValue = SOQLUtils.toSOQLString(valueList);

        this.whereClauseList.add(field + ' ' + operator.trim() + ' ' + parsedValue);
        return this;
    }

    public QueryBuilder orderBy(Schema.SObjectField orderByField) {
        return this.orderBy(orderByField, null, null);
    }

    public QueryBuilder orderBy(Schema.SObjectField orderByField, QueryBuilder.SortOrder sortOrder) {
        return orderBy(orderByField, sortOrder, null);
    }

    public QueryBuilder orderBy(Schema.SObjectField orderByField, QueryBuilder.SortOrder sortOrder, QueryBuilder.NullsSortOrder nullsSortOrder) {
        String sortOrderSoql = '';
        if(sortOrder == QueryBuilder.SortOrder.ASCENDING) sortOrderSoql = ' ASC';
        else if(sortOrder == QueryBuilder.SortOrder.DESCENDING) sortOrderSoql = ' DESC';

        if(nullsSortOrder != null) sortOrderSoql += ' NULLS ' + nullsSortOrder;

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
        this.saveLogs();

        return results;
    }

    public List<SObject> getSearchResults(String searchTerm, SearchGroup searchGroup) {
        List<SObject> results = Search.query(this.getSearchQuery(searchTerm, searchGroup))[0];

        String logEntry = 'Query:\n' + this.query + '\n\nResults:\n' + results;
        this.addLogEntry(logEntry);
        this.saveLogs();

        return results;
    }

    private String getQueryFieldString() {
        List<String> queryFieldList = new List<String>(this.queryFields);
        if(this.repositorySettings.SortQueryFields__c) queryFieldList.sort();
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
            + ' FROM ' + this.sobjectType
            + this.getWhereClauseString()
            + this.getOrderByString()
            + this.getLimitCountString()
            + this.getForUpdateString();

        System.debug(LoggingLevel.INFO, this.query); // TODO: add custom setting to disable debug statements

        return this.query;
    }

    private String getSearchQuery(String searchTerm, SearchGroup searchGroup) {
        this.query = 'FIND ' + SOQLUtils.toSOQLString(searchTerm)
            + ' IN ' + searchGroup.name().replace('_', ' ')
            + ' RETURNING ' + this.sobjectType + '('
                + this.getQueryFieldString()
                + this.getWhereClauseString()
                + this.getOrderByString()
                + this.getLimitCountString()
            + ')';

        // TODO: add custom setting to disable debug statements
        // TODO: consider putting debug messages into custom labels
        if(this.forUpdate) System.debug(LoggingLevel.WARN, 'SOSL Search Query method flagged as FOR UPDATE. SOSL cannot use FOR UPDATE, ignoring');

        // TODO: add custom setting to disable debug statements
        System.debug(this.query);
        this.addLogEntry(this.query);

        return this.query;
    }

    private void getRepositorySettings() {
        this.repositorySettings = RepositorySettings__c.getInstance();

        if(this.repositorySettings.Id == null) {
            // If there's no ID, then there are settings setup for the current user at the user, profile or org level
            // Upsert the org defaults - the default field values will be used
            upsert RepositorySettings__c.getOrgDefaults();
            // Call getInstance() again to get the settings with the field defaults
            this.repositorySettings = RepositorySettings__c.getInstance();
        }

        this.addLogEntry('RepositorySettings__c.getInstance():\n' + JSON.serialize(this.repositorySettings).replace(',', ', ').replace(':', ': '));
    }

    private void addCommonQueryFields() {
        if(!this.repositorySettings.IncludeCommonFields__c) return;

        // Auto-add the common fields that are available for the SObject Type
        List<String> commonFieldNameList = new List<String>{
            'Id', 'CaseNumber', 'CreatedById', 'CreatedDate', 'IsClosed', 'LastModifiedById', 'LastModifiedDate',
            'Name', 'OwnerId', 'Subject', 'RecordTypeId', 'SystemModStamp'
        };
        for(String commonFieldName : commonFieldNameList) {
            if(!this.sobjectTypeFieldMap.containsKey(commonFieldName)) continue;

            this.queryFields.add(commonFieldName.toLowerCase());
        }
        System.debug(this.queryFields);
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