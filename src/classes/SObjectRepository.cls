public abstract class SObjectRepository extends NebulaCore implements ISObjectRepository {

    // Predefined SOQL operators
    protected final String EQUALS                   = '=';
    protected final String NOT_EQUAL_TO             = '!=';
    protected final String GREATER_THAN             = '>';
    protected final String GREATER_THAN_OR_EQUAL_TO = '>=';
    protected final String LESS_THAN                = '<';
    protected final String LESS_THAN_OR_EQUAL_TO    = '<=';
    protected final String IS_IN                    = 'IN';
    protected final String IS_NOT_IN                = 'NOT IN';
    protected final String INCLUDES                 = 'INCLUDES';
    protected final String EXCLUDES                 = 'EXCLUDES';
    protected final String IS_LIKE                  = 'LIKE';
    protected final String IS_NOT_LIKE              = 'NOT LIKE';

    protected QueryBuilder queryBuilder;

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
    public virtual void doUpsert(SObject record) {this.doUpsert(new List<SObject>{record});}
    public virtual void doUpsert(List<SObject> recordList) {Database.upsert(recordList);}
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