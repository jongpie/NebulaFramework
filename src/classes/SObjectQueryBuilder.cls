/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Query Builder
*
* @description A builder class that generates dynamic SOQL & returns an SObject or list of SObjects
*
*/
public class SObjectQueryBuilder extends QueryBuilder implements ISObjectQueryBuilder {

    private Set<String> queryFields;
    private List<String> childRelationshipQueries;
    private QueryFilterScope filterScope;
    private Boolean forUpdate;
    private SObjectType sobjectType;
    private Map<String, Schema.SObjectField> sobjectTypeFieldMap;


    public SObjectQueryBuilder() {
        this.queryFields              = new Set<String>();
        this.childRelationshipQueries = new List<String>();
        this.forUpdate                = false;
    }

    public ISObjectQueryBuilder setSObjectType(Schema.SObjectType sobjectType) {
        // TODO verify/refactor so that this method doesnt have to be called as the first method
        this.sobjectType         = sobjectType;
        this.sobjectTypeFieldMap = sobjectType.getDescribe().fields.getMap();
        this.addCommonQueryFields();
        return this;
    }

    public ISObjectQueryBuilder addFields(Schema.FieldSet fieldSet) {
        for(Schema.FieldSetMember field : fieldSet.getFields()) {
            this.addField(this.sobjectTypeFieldMap.get(field.getFieldPath()));
        }
        return this;
    }

    public ISObjectQueryBuilder addFields(List<Schema.SObjectField> fields) {
        for(Schema.SObjectField field : fields) this.addField(field);
        return this;
    }

    public ISObjectQueryBuilder addAllFields() {
        for(Schema.SObjectField field : this.sobjectTypeFieldMap.values()) this.addField(field);
        return this;
    }

    public ISObjectQueryBuilder addAllStandardFields() {
        for(Schema.SObjectField field : this.sobjectTypeFieldMap.values()) {
            if(field.getDescribe().isCustom()) continue;

            this.addField(field);
        }
        return this;
    }

    public ISObjectQueryBuilder addAllCustomFields() {
        for(Schema.SObjectField field : this.sobjectTypeFieldMap.values()) {
            if(!field.getDescribe().isCustom()) continue;

            this.addField(field);
        }
        return this;
    }

    public ISObjectQueryBuilder addAllReadableFields() {
        for(Schema.SObjectField field : this.sobjectTypeFieldMap.values()) {
            if(!field.getDescribe().isAccessible()) continue;

            this.addField(field);
        }
        return this;
    }

    public ISObjectQueryBuilder addAllEditableFields() {
        for(Schema.SObjectField field : this.sobjectTypeFieldMap.values()) {
            if(!field.getDescribe().isUpdateable()) continue;

            this.addField(field);
        }
        return this;
    }

    public ISObjectQueryBuilder includeChildrenRecords(Schema.SObjectField childToParentRelationshipField, ISObjectQueryBuilder sobjectQueryBuilder) {
         childRelationshipQueries.add(sobjectQueryBuilder.getChildQuery(childToParentRelationshipField));
         return this;
    }

    public ISObjectQueryBuilder filterBy(IQueryFilter queryFilter) {
        super.doFilterBy(queryFilter);
        return this;
    }

    public ISObjectQueryBuilder filterBy(List<IQueryFilter> queryFilters) {
       super.doFilterBy(queryFilters);
       return this;
    }

    public ISObjectQueryBuilder orderBy(Schema.SObjectField orderByField) {
        super.doOrderBy(orderByField);
        return this;
    }

    public ISObjectQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder) {
        super.doOrderBy(orderByField, sortOrder);
        return this;
    }

    public ISObjectQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder, QueryNullSortOrder nullsSortOrder) {
        super.doOrderBy(orderByField, sortOrder, nullsSortOrder);
        return this;
    }

    public ISObjectQueryBuilder limitCount(Integer limitCount) {
        super.doLimitCount(limitCount);
        return this;
    }

    public ISObjectQueryBuilder setAsUpdate() {
        this.forUpdate = true;
        return this;
    }

    public ISObjectQueryBuilder usingScope(QueryFilterScope filterScope) {
        this.filterScope = filterScope;
        return this;
    }

    public Database.QueryLocator getQueryLocator() {
        return Database.getQueryLocator(this.getQuery());
    }

    public String getQuery() {
        String query = 'SELECT ' + this.getQueryFieldString() + this.getChildRelationshipsQueryString()
            + '\nFROM ' + this.sobjectType
            + this.getUsingScopeString()
            + super.doGetWhereClauseString()
            + super.doGetOrderByString()
            + super.doGetLimitCountString()
            + this.getForUpdateString();

        return query;
    }

    public String getSearchQuery() {
        String sobjectTypeOptions = this.getQueryFieldString()
            + super.doGetWhereClauseString()
            + super.doGetOrderByString()
            + super.doGetLimitCountString();
        // If we have any sobject-specific options, then wrap the options in parentheses
        sobjectTypeOptions = String.isEmpty(sobjectTypeOptions) ? '' : '(' + sobjectTypeOptions + ')';
        String query = this.sobjectType + sobjectTypeOptions;

        return query;
    }

    public String getChildQuery(Schema.SObjectField childToParentRelationshipField) {
        Schema.SObjectType parentSObjectType = childToParentRelationshipField.getDescribe().getReferenceTo()[0];
        // Get the relationship name
        String childRelationshipName;
        for(Schema.ChildRelationship childRelationship : parentSObjectType.getDescribe().getChildRelationships()) {
            if(childRelationship.getField() != childToParentRelationshipField) continue;

            childRelationshipName = childRelationship.getRelationshipName();
        }

        String query = 'SELECT ' + this.getQueryFieldString()
            + '\nFROM ' + childRelationshipName
            + this.getUsingScopeString()
            + super.doGetWhereClauseString()
            + super.doGetOrderByString()
            + super.doGetLimitCountString();

        return query;
    }

    // Query execution methods
    public SObject getFirstQueryResult() {
        return this.getQueryResults()[0];
    }

    public List<SObject> getQueryResults() {
       return super.doGetQueryResults(this.getQuery());
    }

    private void addField(Schema.SObjectField field) {
        this.queryFields.add(field.getDescribe().getName());

        // If the field is a lookup, then we need to get the name field from the parent object
        if(field.getDescribe().getType().name() == 'Reference') {
            this.queryFields.add(this.getParentSObjectNameField(field));
        }
    }

    private String getParentSObjectNameField(Schema.SObjectField field) {
        String relationshipName = field.getDescribe().getRelationshipName();
        Schema.SObjectType parentSObjectType = field.getDescribe().getReferenceTo()[0];
        String nameField;
        for(Schema.SObjectField parentField : parentSObjectType.getDescribe().fields.getMap().values()) {
            if(parentField.getDescribe().isNameField()) {
                nameField = parentField.getDescribe().getName();
                break;
            }
        }
        return relationshipName + '.' + nameField;
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

    private String getForUpdateString() {
        return this.orderByList.isEmpty() && this.forUpdate ? '\nFOR UPDATE' : '';
    }

    private String getUsingScopeString() {
        return this.filterScope == null ? '' : '\nUSING SCOPE ' + this.filterScope.name();
    }

    private void addCommonQueryFields() {
        if(!NebulaSettings.SObjectQueryBuilderSettings.IncludeCommonFields__c) return;
        // Auto-add the common fields that are available for the SObject Type
        List<String> commonFieldNameList = new List<String>{
            'Id', 'CaseNumber', 'CreatedById', 'CreatedDate', 'IsClosed', 'LastModifiedById', 'LastModifiedDate',
            'Name', 'OwnerId', 'ParentId', 'Subject', 'RecordTypeId', 'SystemModStamp'
        };
        for(String commonFieldName : commonFieldNameList) {
            this.sobjectTypeFieldMap = this.sobjectType.getDescribe().fields.getMap();
            if(!this.sobjectTypeFieldMap.containsKey(commonFieldName)) continue;

            this.queryFields.add(commonFieldName);
        }
    }

}