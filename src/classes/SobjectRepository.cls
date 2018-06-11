/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public abstract class SobjectRepository extends SobjectDml implements ISobjectRepository {

    protected Schema.SobjectField idField {get; private set;}

    public SobjectRepository() {
        this.currentModule = NebulaCore.Module.REPOSITORY;

        this.idField = this.getField('Id');
    }

    public override abstract Schema.SobjectType getSobjectType();

    public virtual Soql getSoql() {
        return new Soql(this.getSobjectType());
    }

    public virtual Sobject get(Id recordId) {
        return this.getSoql()
            .filterWhere(new Soql.QueryFilter(this.idField, '=', recordId))
            .getFirstQueryResult();
    }

    public virtual List<Sobject> get(Set<Id> recordIds) {
        return this.get(new List<Id>(recordIds));
    }

    public virtual List<Sobject> get(List<Id> recordIds) {
        return this.get(new Soql.QueryFilter(this.idField, 'IN', recordIds));
    }

    public virtual List<Sobject> get(Soql.QueryFilter queryFilter) {
        return this.get(new List<Soql.QueryFilter>{queryFilter});
    }

    public virtual List<Sobject> get(List<Soql.QueryFilter> queryFilters) {
        return this.getSoql()
            .filterWhere(queryFilters)
            .getQueryResults();
    }

    public virtual List<Sobject> get(Set<Id> idSet, List<Soql.QueryFilter> queryFilters) {
        return this.get(new List<Id>(idSet), queryFilters);
    }

    public virtual List<Sobject> get(List<Id> idList, List<Soql.QueryFilter> queryFilters) {
        return this.getSoql()
            .filterWhere(new Soql.QueryFilter(this.idField, 'IN', idList))
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
        return new Sosl(searchTerm, this.getSoql()
            .filterWhere(queryFilters))
            .inSearchGroup(searchGroup)
            .getFirstSearchResults();
    }

    private Schema.SobjectField getField(String fieldName) {
        return this.getSobjectType().getDescribe().fields.getMap().get(fieldName);
    }

}