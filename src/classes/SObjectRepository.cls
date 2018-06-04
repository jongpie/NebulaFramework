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
public abstract class SObjectRepository extends Dml implements ISObjectRepository, IDml {

    private List<Schema.SObjectField> sobjectFieldList;
    private Map<String, Schema.SObjectField> sobjectFieldMap;
    private Soql.QueryField idQueryField;

    public SObjectRepository() {
        this.currentModule = NebulaCore.Module.REPOSITORY;

        this.sobjectFieldMap = this.getSObjectType().getDescribe().fields.getMap();
        this.idQueryField    = new Soql.QueryField(this.getField('Id'));
    }

    public override abstract Schema.SObjectType getSObjectType();

    // SOQL
    public virtual SObject getById(Id recordId) {
        return new Soql(this.getSObjectType())
            .filterWhere(new Soql.QueryFilter(this.idQueryField, '=', recordId))
            .getFirstQueryResult();
    }

    public virtual List<SObject> getById(List<Id> recordIds) {
        return new Soql(this.getSObjectType())
            .filterWhere(new Soql.QueryFilter(this.idQueryField, 'IN', recordIds))
            .getQueryResults();
    }

    public virtual List<SObject> get(Soql.QueryFilter queryFilter) {
        return this.get(new List<Soql.QueryFilter>{queryFilter});
    }

    public virtual List<SObject> get(List<Soql.QueryFilter> queryFilters) {
        return new Soql(this.getSObjectType())
            .filterWhere(queryFilters)
            .getQueryResults();
    }

    public virtual List<SObject> getByIdAndQueryFilters(Set<Id> idSet, List<Soql.QueryFilter> queryFilters) {
        return this.getByIdAndQueryFilters(new List<Id>(idSet), queryFilters);
    }

    public virtual List<SObject> getByIdAndQueryFilters(List<Id> idList, List<Soql.QueryFilter> queryFilters) {
        return new Soql(this.getSObjectType())
            .filterWhere(new Soql.QueryFilter(this.idQueryField, 'IN', idList))
            .filterWhere(queryFilters)
            .getQueryResults();
    }

    // SOSL
    public virtual List<SObject> getSearchResults(String searchTerm) {
        return this.getSearchResults(searchTerm, Sosl.SearchGroup.ALL_FIELDS, null);
    }

    public virtual List<SObject> getSearchResults(String searchTerm, Sosl.SearchGroup searchGroup) {
        return this.getSearchResults(searchTerm, searchGroup, null);
    }

    public virtual List<SObject> getSearchResults(String searchTerm, Sosl.SearchGroup searchGroup, List<Soql.QueryFilter> queryFilters) {
        return new Sosl(searchTerm, new Soql(this.getSObjectType()).filterWhere(queryFilters))
            .inSearchGroup(searchGroup)
            .getFirstSearchResults();
    }

    private Schema.SObjectField getField(String fieldName) {
        return this.sobjectFieldMap.get(fieldName);
    }

}