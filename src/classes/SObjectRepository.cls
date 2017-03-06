global abstract class SObjectRepository implements ISObjectRepository {

    global enum SortOrder { ASCENDING, DESCENDING }
    global enum NullsSortOrder { FIRST, LAST }

    global enum SearchGroup { ALL_FIELDS, NAME_FIELDS, EMAIL_FIELDS, PHONE_FIELDS, SIDEBAR_FIELDS }

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

    global SObjectRepository(Schema.SObjectType sobjectType, Schema.FieldSet fieldSet) {
        this(sobjectType, fieldSet, null);
    }

    global SObjectRepository(Schema.SObjectType sobjectType, List<Schema.SObjectField> sobjectFieldList) {
        this(sobjectType, null, sobjectFieldList);
    }

    private SObjectRepository(Schema.SObjectType sobjectType, Schema.FieldSet fieldSet, List<Schema.SObjectField> sobjectFieldList) {
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

    global protected SObjectRepository whereIdEquals(Id recordId) {
        return this.whereFieldEquals(sobjectTypeFieldMap.get('Id'), this.toSOQLString(recordId));
    }

    global protected SObjectRepository whereIdIn(Set<Id> recordIdSet) {
        return this.whereFieldIn(sobjectTypeFieldMap.get('Id'), new List<Id>(recordIdSet));
    }

    global protected SObjectRepository whereIdIn(List<Id> recordList) {
        return this.whereFieldIn(sobjectTypeFieldMap.get('Id'), recordList);
    }

    global protected SObjectRepository whereFieldEquals(Schema.SObjectField field, Object value) {
        return this.addCondition(field, '=', this.toSOQLString(value));
    }

    global protected SObjectRepository whereFieldDoesNotEqual(Schema.SObjectField field, Object value) {
        return this.addCondition(field, '!=', this.toSOQLString(value));
    }

    global protected SObjectRepository whereFieldGreaterThan(Schema.SObjectField field, Object value) {
        return this.addCondition(field, '>', this.toSOQLString(value));
    }

    global protected SObjectRepository whereFieldGreaterThanOrEqualTo(Schema.SObjectField field, Object value) {
        return this.addCondition(field, '>=', this.toSOQLString(value));
    }

    global protected SObjectRepository whereFieldLessThan(Schema.SObjectField field, Object value) {
        return this.addCondition(field, '<', this.toSOQLString(value));
    }

    global protected SObjectRepository whereFieldLessThanOrEqualTo(Schema.SObjectField field, Object value) {
        return this.addCondition(field, '<=', this.toSOQLString(value));
    }

    global protected SObjectRepository whereFieldIn(Schema.SObjectField field, List<Object> valueList) {
        return this.addCondition(field, 'IN', this.toSOQLString(valueList));
    }

    global protected SObjectRepository whereFieldNotIn(Schema.SObjectField field, List<Object> valueList) {
        return this.addCondition(field, 'NOT IN', this.toSOQLString(valueList));
    }

    global protected SObjectRepository whereFieldIncludes(Schema.SObjectField field, List<Object> valueList) {
        return this.addCondition(field, 'INCLUDES', this.toSOQLString(valueList));
    }

    global protected SObjectRepository whereFieldExcludes(Schema.SObjectField field, List<Object> valueList) {
        return this.addCondition(field, 'EXCLUDES', this.toSOQLString(valueList));
    }

    global protected SObjectRepository whereFieldLike(Schema.SObjectField field, String comparisonValue) {
        return this.addCondition(field, 'LIKE', comparisonValue);
    }

    global protected SObjectRepository whereFieldNotLike(Schema.SObjectField field, String comparisonValue) {
        return this.addCondition(field, 'NOT LIKE', comparisonValue);
    }

    global protected SObjectRepository orderBy(Schema.SObjectField orderByField) {
        return this.orderBy(orderByField, null, null);
    }

    global protected SObjectRepository orderBy(Schema.SObjectField orderByField, SObjectRepository.SortOrder sortOrder) {
        return orderBy(orderByField, sortOrder, null);
    }

    global protected SObjectRepository orderBy(Schema.SObjectField orderByField, SObjectRepository.SortOrder sortOrder, SObjectRepository.NullsSortOrder nullsSortOrder) {
        String sortOrderSoql = '';
        if(sortOrder == SObjectRepository.SortOrder.ASCENDING) sortOrderSoql = ' ASC';
        else if(sortOrder == SObjectRepository.SortOrder.DESCENDING) sortOrderSoql = ' DESC';

        if(nullsSortOrder != null) sortOrderSoql += ' NULLS ' + nullsSortOrder;

        this.orderByList.add(orderByField.getDescribe().getName() + sortOrderSoql);

        return this;
    }

    global protected SObjectRepository limitCount(Integer limitCount) {
        this.limitCount = limitCount;
        return this;
    }

    global protected SObjectRepository setAsUpdate() {
        this.forUpdate = true;
        return this;
    }

    global protected SObject getFirstQueryResult() {
        return this.getQueryResults()[0];
    }

    global protected List<SObject> getQueryResults() {
        return Database.query(this.getQuery());
    }

    global protected List<SObject> getSearchResults(String searchTerm, SObjectRepository.SearchGroup searchGroup) {
        return Search.query(this.getSearchQuery(searchTerm, searchGroup))[0];
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

            this.queryFields.add(commonFieldName);
        }
        system.debug(this.queryFields);
    }

    private void addFieldSetMembers() {
        if(this.fieldSet == null) return;

        for(Schema.FieldSetMember field : this.fieldSet.getFields()) this.queryFields.add(field.getFieldPath());
    }

    private void addSObjectFields() {
        if(this.sobjectFieldList == null) return;

        for(Schema.SObjectField field : this.sobjectFieldList) this.queryFields.add(field.getDescribe().getName());
    }

    private SObjectRepository addCondition(Schema.SObjectField field, String operator, String value) {
        this.whereClauseList.add('(' + field + ' ' + operator.trim() + ' ' + value + ')');
        return this;
    }

    private String toSOQLString(List<Object> valueList) {
        List<String> parsedValueList = new List<String>();
        for(Object value : valueList) parsedValueList.add(toSOQLString(value));
        return '(' + String.join(parsedValueList, ',') + ')';
    }

    private String toSOQLString(Object value) {
        if(value == null) return null;
        else if(value instanceof Boolean) return String.valueOf((Boolean)value);
        else if(value instanceof Date) return String.valueOf((Date)value);
        else if(value instanceof Datetime) {
            Datetime datetimeValue = (Datetime)value;
            return datetimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'Greenwich Mean Time');
        }
        else if(value instanceof Decimal) return String.valueOf((Decimal) value);
        else if(value instanceof Double) return String.valueOf((Double) value);
        else if(value instanceof Integer) return String.valueOf((Integer) value);
        else if(value instanceof Long) return String.valueOf((Long) value);
        else if(value instanceof SObject) {
            SObject record = (SObject)value;
            return wrapInSingleQuotes(record.Id);
        }
        else if(value instanceof String) return wrapInSingleQuotes((String)value);
        else return String.valueOf(value);
    }

    private String wrapInSingleQuotes(String input) {
        if(input.left(1) != '\'') input = '\'' + input;
        if(input.right(1) != '\'') input = input + '\'';
        return input;
    }

    private String getQueryFieldString() {
        return String.join(new List<String>(this.queryFields), ',');
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

    private String getSearchQuery(String searchTerm, SObjectRepository.SearchGroup searchGroup) {
        this.query = 'FIND ' + this.toSOQLString(searchTerm)
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

        return this.query;
    }

}