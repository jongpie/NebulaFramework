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
        return new SObjectQueryBuilder(this.getSObjectType())
            .filterBy(new QueryFilter().filterByField(this.idQueryField, QueryOperator.EQUALS, recordId))
            .filterBy(new QueryFilter().filterByField(this.idQueryField, QueryOperator.EQUALS, recordId))
            .getFirstQueryResult();
    }

    public virtual List<SObject> getById(List<Id> recordIds) {
        return new SObjectQueryBuilder(this.getSObjectType())
            .filterBy(new QueryFilter().filterByField(this.idQueryField, QueryOperator.IS_IN, recordIds))
            .getQueryResults();
    }

    public virtual List<SObject> get(IQueryFilter queryFilter) {
        return this.get(new List<IQueryFilter>{queryFilter});
    }

    public virtual List<SObject> get(List<IQueryFilter> queryFilters) {
        return new SObjectQueryBuilder(this.getSObjectType())
            .filterBy(queryFilters)
            .getQueryResults();
    }

    public virtual List<SObject> getByIdAndQueryFilters(Set<Id> idSet, List<IQueryFilter> queryFilters) {
        return this.getByIdAndQueryFilters(new List<Id>(idSet), queryFilters);
    }

    public virtual List<SObject> getByIdAndQueryFilters(List<Id> idList, List<IQueryFilter> queryFilters) {
        return new SObjectQueryBuilder(this.getSObjectType())
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
        return new SearchQueryBuilder(searchTerm, new SObjectQueryBuilder(this.getSObjectType()).filterBy(queryFilters))
            .setQuerySearchGroup(searchGroup)
            .getFirstSearchResult();
    }

    private Schema.SObjectField getField(String fieldName) {
        return this.sobjectFieldMap.get(fieldName);
    }

}