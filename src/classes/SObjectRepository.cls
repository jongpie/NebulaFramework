/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public abstract class SObjectRepository extends DML implements ISObjectRepository, IDML {

    protected IQueryBuilder Query {
        get { return new QueryBuilder(this.sobjectType, this.fieldSet, this.sobjectFieldList); }
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
        this.sobjectFieldList = sobjectFieldList;
        this.sobjectFieldMap  = sobjectType.getDescribe().fields.getMap();
        this.idField          = this.getField('Id');
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

    public virtual List<SObject> getByIdAndQueryFilters(Set<Id> idSet, List<IQueryFilter> queryFilters) {
        return this.getByIdAndQueryFilters(new List<Id>(idSet), queryFilters);
    }

    public virtual List<SObject> getByIdAndQueryFilters(List<Id> idList, List<IQueryFilter> queryFilters) {
        return this.Query
            .filterBy(new QueryFilter(this.idField, QueryOperator.IS_IN, idList))
            .filterBy(queryFilters)
            .getQueryResults();
    }

    // SOSL
    public virtual List<SObject> getSearchResults(String searchTerm) {
        return this.getSearchResults(searchTerm, QuerySearchGroup.ALL_FIELDS, null);
    }

    public virtual List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup) {
        return this.getSearchResults(searchTerm, searchGroup, null);
    }

    public virtual List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup, List<IQueryFilter> queryFilters) {
        return this.Query
            .filterBy(queryFilters)
            .getSearchResults(searchTerm, searchGroup);
    }

    public virtual IQueryBuilder getQueryBuilder() {
        return this.Query;
    }

    private Schema.SObjectField getField(String fieldName) {
        return this.sobjectFieldMap.get(fieldName);
    }

}