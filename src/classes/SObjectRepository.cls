/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public virtual class SObjectRepository extends NebulaCore implements ISObjectRepository, IDML {

    private final Schema.SObjectType sObjectType;
    private final Schema.FieldSet fieldSet;
    private final List<Schema.SObjectField> sobjectFieldList;
    private final Schema.SObjectField idField;
    protected IQueryBuilder queryBuilder;

    public SObjectRepository(Schema.SObjectType sobjectType, Schema.FieldSet fieldSet) {
        this(sobjectType, fieldSet, null);
    }

    public SObjectRepository(Schema.SObjectType sobjectType, List<Schema.SObjectField> sobjectFieldList) {
        this(sobjectType, null, sobjectFieldList);
    }

    private SObjectRepository(Schema.SObjectType sobjectType, Schema.FieldSet fieldSet, List<Schema.SObjectField> sobjectFieldList) {
        this.currentModule = NebulaCore.Module.REPOSITORY;

        this.sObjectType = sObjectType;
        this.fieldSet = fieldSet;
        this.sObjectFieldList = sObjectFieldList;
        this.idField = this.getField(this.sObjectType, 'Id');
    }

    protected IQueryBuilder queryFactory {
        get {
            return new QueryBuilder(sObjectType, fieldSet, sObjectFieldList);
        }
    }

    //SOQL
    public virtual SObject getById(Id recordId) {
        return this.queryFactory
            .whereField(this.idField, QueryOperator.EQUALS, recordId)
            .getQueryResults()[0];
    }

    public virtual List<SObject> getById(List<Id> recordIds) {
        return this.queryFactory
            .whereField(this.idField, QueryOperator.IS_IN, recordIds)
            .getQueryResults();
    }

    public virtual List<SObject> get(QueryPredicate queryPredicate) {
        return this.get(new List<QueryPredicate> { queryPredicate });
    }

    public virtual List<SObject> get(List<QueryPredicate> queryPredicates) {
        return this.queryFactory
            .whereField(queryPredicates)
            .getQueryResults();
    }

    public virtual List<SObject> getByFieldForIds(Schema.SObjectField field, Object value, Set<Id> idSet) {
        return this.getByFieldForIds(field, value, new List<Id>(idSet));
    }

    public virtual List<SObject> getByFieldForIds(Schema.SObjectField field, Object value, List<Id> recordIds) {
        return this.queryFactory
            .whereField(this.idField, QueryOperator.IS_IN, recordIds)
            .whereField(field, QueryOperator.EQUALS, value)
            .getQueryResults();
    }

    public List<SObject> getCreatedSinceTimeValue(Object timeValue) {
        return this.queryFactory
            .whereField(this.getCreatedDate(), QueryOperator.GREATER_THAN_OR_EQUAL_TO, timeValue)
            .getQueryResults();
    }

    //SOSL
    public virtual List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup) {
        return (List<SObject>)this.queryFactory
            .limitCount(10)
            .getSearchResults(searchTerm, searchGroup);
    }

    private Schema.SObjectField getCreatedDate() {
        return this.getField(this.sObjectType, 'CreatedDate');
    }

    private Schema.SObjectField getField(Schema.SObjectType objType, String fieldName) {
        return sObjectType.getDescribe().fields.getMap().get(fieldName);
    }
}