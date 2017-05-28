/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public virtual class SObjectRepository extends NebulaCore implements ISObjectRepository, IDML {

    protected IQueryBuilder Query {
        get { return new QueryBuilder(sobjectType, fieldSet, sObjectFieldList); }
    }

    private final Schema.SObjectType sobjectType;
    private final Schema.FieldSet fieldSet;
    private final List<Schema.SObjectField> sobjectFieldList;
    private final Schema.SObjectField idField;

    public SObjectRepository(Schema.SObjectType sobjectType, Schema.FieldSet fieldSet) {
        this(sobjectType, fieldSet, null);
    }

    public SObjectRepository(Schema.SObjectType sobjectType, List<Schema.SObjectField> sobjectFieldList) {
        this(sobjectType, null, sobjectFieldList);
    }

    private SObjectRepository(Schema.SObjectType sobjectType, Schema.FieldSet fieldSet, List<Schema.SObjectField> sobjectFieldList) {
        this.currentModule = NebulaCore.Module.REPOSITORY;

        this.sobjectType      = sobjectType;
        this.fieldSet         = fieldSet;
        this.sObjectFieldList = sObjectFieldList;
        this.idField          = this.getField(this.sobjectType, 'Id');
    }

    //SOQL
    public virtual SObject getById(Id recordId) {
        return this.Query
            .filterBy(new QueryFilter(this.idField, QueryOperator.EQUALS, recordId))
            .getQueryResults()[0];
    }

    public virtual List<SObject> getById(List<Id> recordIds) {
        return this.Query
            .filterBy(new QueryFilter(this.idField, QueryOperator.IS_IN, recordIds))
            .getQueryResults();
    }

    public virtual List<SObject> get(QueryFilter queryFilter) {
        return this.get(new List<QueryFilter>{queryFilter});
    }

    public virtual List<SObject> get(List<QueryFilter> queryFilters) {
        return this.Query
            .filterBy(queryFilters)
            .getQueryResults();
    }

    public virtual List<SObject> getByFieldForIds(Schema.SObjectField field, Object value, Set<Id> idSet) {
        return this.getByFieldForIds(field, value, new List<Id>(idSet));
    }

    public virtual List<SObject> getByFieldForIds(Schema.SObjectField field, Object value, List<Id> recordIds) {
        return this.Query
            .filterBy(new QueryFilter(this.idField, QueryOperator.IS_IN, recordIds))
            .filterBy(new QueryFilter(field, QueryOperator.EQUALS, value))
            .getQueryResults();
    }

    public List<SObject> getCreatedSinceTimeValue(Object timeValue) {
        return this.Query
            .filterBy(new QueryFilter(this.getCreatedDate(), QueryOperator.GREATER_THAN_OR_EQUAL_TO, timeValue))
            .getQueryResults();
    }

    //SOSL
    public virtual List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup) {
        return (List<SObject>)this.Query
            .limitCount(10)
            .getSearchResults(searchTerm, searchGroup);
    }

    private Schema.SObjectField getCreatedDate() {
        return this.getField(this.sobjectType, 'CreatedDate');
    }

    private Schema.SObjectField getField(Schema.SObjectType objType, String fieldName) {
        return sobjectType.getDescribe().fields.getMap().get(fieldName);
    }
}