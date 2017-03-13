public abstract class SObjectRepository extends NebulaCore implements ISObjectRepository {

    protected IQueryBuilder queryBuilder;

    protected SObjectRepository(Schema.SObjectType sobjectType, Schema.FieldSet fieldSet) {
        this(sobjectType, fieldSet, null);
    }

    protected SObjectRepository(Schema.SObjectType sobjectType, List<Schema.SObjectField> sobjectFieldList) {
        this(sobjectType, null, sobjectFieldList);
    }

    private SObjectRepository(Schema.SObjectType sobjectType, Schema.FieldSet fieldSet, List<Schema.SObjectField> sobjectFieldList) {
        this.currentModule = NebulaCore.Module.REPOSITORY;

        this.queryBuilder = new QueryBuilder(sobjectType, fieldSet, sobjectFieldList);
    }

    public virtual void doInsert(SObject record) {this.doInsert(new List<SObject>{record});}
    public virtual void doInsert(List<SObject> recordList) {Database.insert(recordList);}
    public virtual void doUpdate(SObject record) {this.doUpdate(new List<SObject>{record});}
    public virtual void doUpdate(List<SObject> recordList) {Database.update(recordList);}
    // Apex doesn't allow upserting on generic SObject, so we'll delegate the implementation to each concrete class
    public abstract void doUpsert(SObject record);
    public abstract void doUpsert(List<SObject> recordList);

    public virtual void doDelete(SObject record) {this.doDelete(new List<SObject>{record});}
    public virtual void doDelete(List<SObject> recordList) {Database.delete(recordList);}
    public virtual void doHardDelete(SObject record) {this.doHardDelete(new List<SObject>{record});}
    public virtual void doHardDelete(List<SObject> recordList) {
        Database.delete(recordList);
        if(!recordList.isEmpty()) Database.emptyRecycleBin(recordList);
    }
    public virtual void doUndelete(SObject record) {this.doUndelete(new List<SObject>{record});}
    public virtual void doUndelete(List<SObject> recordList) {Database.undelete(recordList);}

}