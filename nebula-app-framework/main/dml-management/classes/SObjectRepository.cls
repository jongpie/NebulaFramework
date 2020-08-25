/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public abstract class SObjectRepository extends SObjectDml implements ISObjectRepository {

    protected Schema.SObjectField idField {get; private set;}

    public SObjectRepository() {
        this.idField = this.getField('Id');
    }

    public override abstract Schema.SObjectType getSObjectType();

    public virtual Query getQuery() {
        return new Query(this.getSObjectType());
    }

    public virtual RecordSearch getRecordSearch(String searchTerm) {
        return new RecordSearch(searchTerm, this.getQuery());
    }

    public virtual SObject get(Id recordId) {
        return this.getQuery()
            .filterWhere(new Soql.QueryFilter(this.idField, Soql.Operator.EQUALS, recordId))
            .getFirstResult();
    }

    public virtual List<SObject> get(Set<Id> recordIds) {
        return this.get(new List<Id>(recordIds));
    }

    public virtual List<SObject> get(List<Id> recordIds) {
        return this.get(new Soql.QueryFilter(this.idField, Soql.Operator.IS_IN, recordIds));
    }

    public virtual List<SObject> get(Soql.QueryFilter queryFilter) {
        return this.get(new List<Soql.QueryFilter>{queryFilter});
    }

    public virtual List<SObject> get(List<Soql.QueryFilter> queryFilters) {
        return this.getQuery()
            .filterWhere(queryFilters)
            .getResults();
    }

    public virtual List<SObject> get(Set<Id> idSet, List<Soql.QueryFilter> queryFilters) {
        return this.get(new List<Id>(idSet), queryFilters);
    }

    public virtual List<SObject> get(List<Id> idList, List<Soql.QueryFilter> queryFilters) {
        return this.getQuery()
            .filterWhere(new Soql.QueryFilter(this.idField, Soql.Operator.IS_IN, idList))
            .filterWhere(queryFilters)
            .getResults();
    }

    public virtual void set(SObject record, Schema.SObjectField field, Object value) {
        this.set(new List<SObject>{record}, field, value);
    }

    public virtual void set(List<SObject> records, Schema.SObjectField field, Object value) {
        for(SObject record : records) {
            record.put(field, value);
        }
    }

    public virtual List<SObject> search(String searchTerm) {
        return this.search(searchTerm, Sosl.SearchGroup.ALL_FIELDS, null);
    }

    public virtual List<SObject> search(String searchTerm, Sosl.SearchGroup searchGroup) {
        return this.search(searchTerm, searchGroup, null);
    }

    public virtual List<SObject> search(String searchTerm, Sosl.SearchGroup searchGroup, List<Soql.QueryFilter> queryFilters) {
        Query queryBuilder = this.getQuery().filterWhere(queryFilters);

        return new RecordSearch(searchTerm, queryBuilder)
            .inSearchGroup(searchGroup)
            .getFirstResults();
    }

    private Schema.SObjectField getField(String fieldName) {
        return this.getSObjectType().getDescribe().fields.getMap().get(fieldName);
    }

}