/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Query Builder
* @group-content /ApexDocContent/QueryBuilder.html
*
* @description A builder class that generates dynamic SOQL & SOSL queries & returns an SObject or list of SObjects
*
*/
public class SObjectQueryBuilder extends QueryBuilder implements ISObjectQueryBuilder {

    private Set<String> queryFields;
    private List<String> childRelationshipQueries;
    private QueryFilterScope filterScope;
    @testVisible private Boolean forUpdate;
    private SObjectType sobjectType;
    private Map<String, Schema.SObjectField> sobjectTypeFieldMap;


    public SObjectQueryBuilder() {
        this.queryFields              = new Set<String>();
        this.childRelationshipQueries = new List<String>();
        //this.whereClauseList          = new List<String>();
        //this.orderByList              = new List<String>();
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
        for(Schema.SObjectField field : this.sobjectTypeFieldMap.values()) {
            this.queryFields.add(field.getDescribe().getName());
        }
        return this;
    }

    public ISObjectQueryBuilder addAllStandardFields() {
        for(Schema.SObjectField field : this.sobjectTypeFieldMap.values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            // If it's not a standard field, skip it
            if(fieldDescribe.isCustom()) continue;

            this.queryFields.add(fieldDescribe.getName());
        }
        return this;
    }

    public ISObjectQueryBuilder addAllCustomFields() {
        for(Schema.SObjectField field : this.sobjectTypeFieldMap.values()) {
            // If it's not a custom field, skip it
            if(!field.getDescribe().isCustom()) continue;

            this.queryFields.add(field.getDescribe().getName());
        }
        return this;
    }

    public ISObjectQueryBuilder addAllReadableFields() {
        for(Schema.SObjectField field : this.sobjectTypeFieldMap.values()) {
            // If it's not a readable field, skip it
            if(!field.getDescribe().isAccessible()) continue;

            this.queryFields.add(field.getDescribe().getName());
        }
        return this;
    }

    public ISObjectQueryBuilder addAllEditableFields() {
        for(Schema.SObjectField field : this.sobjectTypeFieldMap.values()) {
            // If it's not an editable field, skip it
            if(!field.getDescribe().isUpdateable()) continue;

            this.queryFields.add(field.getDescribe().getName());
        }
        return this;
    }

    public ISObjectQueryBuilder filterBy(IQueryFilter queryFilter) {
        return this.filterBy(new List<IQueryFilter>{queryFilter});
    }

    public ISObjectQueryBuilder filterBy(List<IQueryFilter> queryFilters) {
        if(queryFilters == null) return this;

        for(IQueryFilter queryFilter : queryFilters) this.whereClauseList.add(queryFilter.getValue());
        return this;
    }

    public ISObjectQueryBuilder andFilterBy(List<IQueryFilter> queryFilters) {
       // TODO finish implementing!
       this.filterByWithSeparator(queryFilters, 'AND');
       return this;
    }

    public ISObjectQueryBuilder orFilterBy(List<IQueryFilter> queryFilters) {
        // TODO finish implementing!
       this.filterByWithSeparator(queryFilters, 'OR');
       return this;
    }

// TODO finish implementing subselects!, come up with better method name that uses verb for name (get, set, etc)
    public ISObjectQueryBuilder inSubquery(Schema.SObjectField lookupFieldOnRelatedSObject) {
        return this.inSubquery(this.sobjectType.getDescribe().fields.getMap().get('Id'), lookupFieldOnRelatedSObject);
    }

    public ISObjectQueryBuilder inSubquery(Schema.SObjectField sobjectFieldToFilter, Schema.SObjectField lookupFieldOnRelatedSObject) {
        return this.addSubquery(sobjectFieldToFilter, lookupFieldOnRelatedSObject, 'IN');
    }

    public ISObjectQueryBuilder notInSubquery(Schema.SObjectField lookupFieldOnRelatedSObject) {
        return this.notInSubquery(this.sobjectType.getDescribe().fields.getMap().get('Id'), lookupFieldOnRelatedSObject);
    }

    public ISObjectQueryBuilder notInSubquery(Schema.SObjectField sobjectFieldToFilter, Schema.SObjectField lookupFieldOnRelatedSObject) {
        return this.addSubquery(sobjectFieldToFilter, lookupFieldOnRelatedSObject, 'NOT IN');
    }

    public ISObjectQueryBuilder includeChildrenRecords(Schema.SObjectField childToParentRelationshipField, List<Schema.SObjectField> childFields, List<IQueryFilter> childFilters) {
        // Get the relationship name
        String childRelationshipName;
        for(Schema.ChildRelationship childRelationship : this.sobjectType.getDescribe().getChildRelationships()) {
            if(childRelationship.getField() != childToParentRelationshipField) continue;

            childRelationshipName = childRelationship.getRelationshipName();
        }

        // Build the child filters
        List<String> childFieldNames = new List<String>();
        for(Schema.SObjectField childField : childFields) childFieldNames.add(childField.getDescribe().getName());
        childFieldNames.sort();

        // Build the child filters
        List<String> childWhereClauseList = new List<String>();
        for(IQueryFilter childFilter : childFilters) childWhereClauseList.add(childFilter.getValue());
        String childWhereClauseString = childWhereClauseList.isEmpty() ? '' : '\nWHERE ' + String.join(childWhereClauseList, '\nAND ');

        // Build the child query
        String childQuery = 'SELECT ' + String.join(childFieldNames, ', ')
            + '\nFROM ' + childRelationshipName
            + childWhereClauseString;
        childRelationshipQueries.add(childQuery);
        return this;
    }

   public ISObjectQueryBuilder orderBy(Schema.SObjectField orderByField) {
       return this.orderBy(orderByField, null, null);
   }

   public ISObjectQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder) {
       return this.orderBy(orderByField, sortOrder, null);
   }

   public ISObjectQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder, QueryNullSortOrder nullsSortOrder) {
       String sortOrderSoql = '';
       if(sortOrder == QuerySortOrder.ASCENDING) sortOrderSoql = ' ASC';
       else if(sortOrder == QuerySortOrder.DESCENDING) sortOrderSoql = ' DESC';

       if(nullsSortOrder != null) sortOrderSoql += ' NULLS ' + nullsSortOrder;

       this.orderByList.add(orderByField.getDescribe().getName() + sortOrderSoql);

       return this;
   }

   public ISObjectQueryBuilder limitCount(Integer limitCount) {
       super.add_limitCount(limitCount);
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

   // Query execution methods
   public SObject getFirstQueryResult() {
       return this.getQueryResults()[0];
   }

   public List<SObject> getQueryResults() {
       List<SObject> results = Database.query(this.getQuery());

       this.logEntry(this.getQuery(), results);

       return results;
   }

   public virtual List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup) {
       // TODO SObjectQueryBuilder??
       List<SObject> results = Search.query(this.getSearchQuery(searchTerm, searchGroup))[0];

       this.logEntry(this.getSearchQuery(searchTerm, searchGroup), results);

       return results;
   }

    private void addField(Schema.SObjectField field) {
        // TODO move this method to be with the rest of the private methods
        this.queryFields.add(field.getDescribe().getName().toLowerCase());

        // If the field is a lookup, then we need to get the name field from the parent object
        if(field.getDescribe().getType().name() == 'Reference') {
            this.queryFields.add(this.getParentSObjectNameField(field).toLowerCase());
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

    private ISObjectQueryBuilder addSubquery(Schema.SObjectField sobjectFieldToFilter, Schema.SObjectField lookupFieldOnRelatedSObject, String inOrOut) {
        String sobjectFieldToFilterName = sobjectFieldToFilter.getDescribe().getName();
        String relatedSObjectTypeName = new SObjectFieldDescriber(lookupFieldOnRelatedSObject).SObjectType.getDescribe().getName(); // TODO change SObjectType to getSObjectType()
        String lookupFieldOnRelatedSObjectName = lookupFieldOnRelatedSObject.getDescribe().getName();

        String subselectString = sobjectFieldToFilterName + ' ' + inOrOut + ' (SELECT ' + lookupFieldOnRelatedSObjectName + ' FROM ' + relatedSObjectTypeName + ')';
        this.whereClauseList.add(subselectString);
        return this;
    }

    @testVisible
    private String getQuery() {
        String query = 'SELECT ' + this.getQueryFieldString()
            + '\nFROM ' + this.sobjectType
            + this.getWhereClauseString()
            + this.getOrderByString()
            + this.getLimitCountString()
            + this.getForUpdateString();

        return query;
    }

    @testVisible
    private String getSearchQuery(String searchTerm, QuerySearchGroup searchGroup) {
        String query = 'FIND ' + NebulaFactory.getQueryArgumentFormatter().getValue(searchTerm.toLowerCase())
            + '\nIN ' + searchGroup.name().replace('_', ' ')
            + '\nRETURNING ' + this.sobjectType + '('
                + this.getQueryFieldString()
                + this.getWhereClauseString()
                + this.getOrderByString()
                + this.getLimitCountString()
            + ')';

        if(this.forUpdate) Logger.addEntry(this, 'SOSL Search Query method flagged as FOR UPDATE. SOSL cannot use FOR UPDATE, ignoring');
        if(this.filterScope != null) Logger.addEntry(this, 'SOSL Search Query method flagged as USING SCOPE ' + this.filterScope + '. SOSL cannot use USING SCOPE, ignoring');

        return query;
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

    private String getForUpdateString() {// TODO - SObjectQueryBuilder??
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
            // TODO this is duplicated from the constructor, need to consolidate
            this.sobjectTypeFieldMap = this.sobjectType.getDescribe().fields.getMap();
            if(!this.sobjectTypeFieldMap.containsKey(commonFieldName)) continue;

            this.queryFields.add(commonFieldName.toLowerCase());
        }
    }

}