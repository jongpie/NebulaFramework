/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public virtual class SObjectRepository extends DML implements ISObjectRepository, IDML {

    protected IQueryBuilder Query {
        get { return new QueryBuilder(sobjectType, fieldSet, sobjectFieldList); }
    }

    private final Schema.SObjectType sobjectType;
    private final Schema.FieldSet fieldSet;
    private final List<Schema.SObjectField> sobjectFieldList;
    private final Map<String, Schema.SObjectField> sobjectFieldMap;
    private final Schema.SObjectField idField;

    public SObjectRepository(Schema.SObjectType sobjectType) {
        this(sobjectType, null, null);
    }

    public SObjectRepository(Schema.SObjectType sobjectType, Schema.FieldSet fieldSet) {
        this(sobjectType, fieldSet, null);
    }

    public SObjectRepository(Schema.SObjectType sobjectType, List<Schema.SObjectField> sobjectFieldList) {
        this(sobjectType, null, sobjectFieldList);
    }

    private SObjectRepository(Schema.SObjectType sobjectType, Schema.FieldSet fieldSet, List<Schema.SObjectField> sobjectFieldList) {
        super(sobjectType);

        this.currentModule = NebulaCore.Module.REPOSITORY;

        this.sobjectType      = sobjectType;
        this.fieldSet         = fieldSet;
        this.sObjectFieldList = sObjectFieldList;
        this.sobjectFieldMap  = sobjectType.getDescribe().fields.getMap();
        this.idField          = this.getField('Id');
    }

    // Add filters to the query without actually executing the query
    public virtual ISObjectRepository filterBy(IQueryFilter queryFilter) {
        return this.filterBy(new List<IQueryFilter>{queryFilter});
    }

    public virtual ISObjectRepository filterBy(List<IQueryFilter> queryFilters) {
        for(IQueryFilter queryFilter : queryFilters) this.Query.filterBy(queryFilter);

        return this;
    }

    // SOQL
    public virtual SObject getById(Id recordId) {
        return this.Query
            .filterBy(new QueryFilter(this.idField, QueryOperator.EQUALS, recordId))
            .getFirstQueryResult();
    }

    public virtual List<SObject> getById(List<Id> recordIds) {
        return this.Query
            .filterBy(new QueryFilter(this.idField, QueryOperator.IS_IN, recordIds))
            .getQueryResults();
    }

    public virtual List<SObject> get(IQueryFilter queryFilter) {
        return this.get(new List<IQueryFilter>{queryFilter});
    }

    public virtual List<SObject> get(List<IQueryFilter> queryFilters) {
        return this.Query
            .filterBy(queryFilters)
            .getQueryResults();
    }

    public virtual List<SObject> getByFieldForIds(Schema.SObjectField field, Object value, Set<Id> idSet) {
        return this.getByFieldForIds(field, value, new List<Id>(idSet));
    }

    public virtual List<SObject> getByFieldForIds(Schema.SObjectField field, Object value, List<Id> idList) {
        return this.Query
            .filterBy(new QueryFilter(this.idField, QueryOperator.IS_IN, idList))
            .filterBy(new QueryFilter(field, QueryOperator.EQUALS, value))
            .getQueryResults();
    }

    // SOSL
    public virtual List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup) {
        return (List<SObject>)this.Query
            .limitCount(10)
            .getSearchResults(searchTerm, searchGroup);
    }

    public virtual IQueryBuilder getQueryBuilder() {
        return this.Query;
    }

    private Schema.SObjectField getField(String fieldName) {
        return this.sobjectFieldMap.get(fieldName);
    }

}