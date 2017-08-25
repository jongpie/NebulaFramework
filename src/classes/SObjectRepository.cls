/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Repository
*
* @description TODO
*
*/
public abstract class SObjectRepository extends DML implements ISObjectRepository, IDML {

    protected List<IQueryFilter> BaseQueryFilters = new List<IQueryFilter>();

    protected ISObjectQueryBuilder Query {
        get {
            return new SObjectQueryBuilder(this.getSObjectType())
                .filterBy(this.BaseQueryFilters);
        }
        private set;
    }

    protected IAggregateResultQueryBuilder AggregateQuery {
        get {
            return new AggregateResultQueryBuilder(this.getSObjectType())
                .filterBy(this.BaseQueryFilters);
        }
        private set;
    }

    protected ISearchQueryBuilder SearchQuery {
        get { return new SearchQueryBuilder(); }
        private set;
    }

    private List<Schema.SObjectField> sobjectFieldList;
    private Map<String, Schema.SObjectField> sobjectFieldMap;
    private QueryField idQueryField;

    public SObjectRepository() {
        this.currentModule = NebulaCore.Module.REPOSITORY;

        this.sobjectFieldMap = this.getSObjectType().getDescribe().fields.getMap();
        this.idQueryField    = new QueryField(this.getField('Id'));
    }

    public abstract Schema.SObjectType getSObjectType();

    // SOQL
    public virtual SObject getById(Id recordId) {
        return this.Query
            .filterBy(new QueryFilter().filterByField(this.idQueryField, QueryOperator.EQUALS, recordId))
            .filterBy(new QueryFilter().filterByField(this.idQueryField, QueryOperator.EQUALS, recordId))
            .getFirstQueryResult();
    }

    public virtual List<SObject> getById(List<Id> recordIds) {
        return this.Query
            .filterBy(new QueryFilter().filterByField(this.idQueryField, QueryOperator.IS_IN, recordIds))
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
            .filterBy(new QueryFilter().filterByField(this.idQueryField, QueryOperator.IS_IN, idList))
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
        return this.SearchQuery
            .addSObjectQueryBuilders(this.Query.filterBy(queryFilters))
            .setQuerySearchGroup(searchGroup)
            .getFirstSearchResult(searchTerm);
    }

    private Schema.SObjectField getField(String fieldName) {
        return this.sobjectFieldMap.get(fieldName);
    }

}