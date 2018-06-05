/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public abstract class SobjectRepository extends Dml implements ISobjectRepository, IDml {

    private Schema.SobjectField idQueryField;

    public SobjectRepository() {
        this.currentModule = NebulaCore.Module.REPOSITORY;

        this.idQueryField = this.getField('Id');
    }

    public override abstract Schema.SobjectType getSobjectType();

    public virtual Soql getSoql() {
        return new Soql(this.getSobjectType());
    }

    public virtual Sobject query(Id recordId) {
        return this.getSoql()
            .filterWhere(new Soql.QueryFilter(this.idQueryField, '=', recordId))
            .getFirstQueryResult();
    }

    public virtual List<Sobject> query(Set<Id> recordIds) {
        return this.query(new List<Id>(recordIds));
    }

    public virtual List<Sobject> query(List<Id> recordIds) {
        return this.getSoql()
            .filterWhere(new Soql.QueryFilter(this.idQueryField, 'IN', recordIds))
            .getQueryResults();
    }

    public virtual List<Sobject> query(Soql.QueryFilter queryFilter) {
        return this.query(new List<Soql.QueryFilter>{queryFilter});
    }

    public virtual List<Sobject> query(List<Soql.QueryFilter> queryFilters) {
        return this.getSoql()
            .filterWhere(queryFilters)
            .getQueryResults();
    }

    public virtual List<Sobject> query(Set<Id> idSet, List<Soql.QueryFilter> queryFilters) {
        return this.query(new List<Id>(idSet), queryFilters);
    }

    public virtual List<Sobject> query(List<Id> idList, List<Soql.QueryFilter> queryFilters) {
        return this.getSoql()
            .filterWhere(new Soql.QueryFilter(this.idQueryField, 'IN', idList))
            .filterWhere(queryFilters)
            .getQueryResults();
    }

    public virtual List<Sobject> search(String searchTerm) {
        return this.search(searchTerm, Sosl.SearchGroup.ALL_FIELDS, null);
    }

    public virtual List<Sobject> search(String searchTerm, Sosl.SearchGroup searchGroup) {
        return this.search(searchTerm, searchGroup, null);
    }

    public virtual List<Sobject> search(String searchTerm, Sosl.SearchGroup searchGroup, List<Soql.QueryFilter> queryFilters) {
        return new Sosl(searchTerm, this.getSoql().filterWhere(queryFilters))
            .inSearchGroup(searchGroup)
            .getFirstSearchResults();
    }

    private Schema.SobjectField getField(String fieldName) {
        return this.getSobjectType().getDescribe().fields.getMap().get(fieldName);
    }

}