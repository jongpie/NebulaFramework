/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
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

    //CRUD - virtual so that DML options / upserting on specific foreign Id's can be allowed through overriding
    public virtual void doInsert(SObject record) {this.doInsert(new List<SObject>{record});}
    public virtual void doInsert(List<SObject> records) {Database.insert(records);}

    public virtual void doUpdate(SObject record) {this.doUpdate(new List<SObject>{record});}
    public virtual void doUpdate(List<SObject> records) {Database.update(records);}

    public virtual void doUpsert(SObject record) {
        //Salesforce will only allow upsert calls for SObjects if a declared-type list is passed in.
        //This is fine for the bulk method, where we can assume the caller is passing in an explicit list, but for a single record,
        //the only way to successfully perform the upsert is to dynamically spin up a list of the SObject's type
        String listType = 'List<' + record.getSObjectType() + '>';
        List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
        castRecords.add(record);
        this.doUpsert(castRecords);
    }

    public virtual void doUpsert(List<SObject> records) {Database.upsert(records);}

    public virtual void doDelete(SObject record) {this.doDelete(new List<SObject>{record});}
    public virtual void doDelete(List<SObject> records) {Database.delete(records);}

    public virtual void doHardDelete(SObject record) {this.doHardDelete(new List<SObject>{record});}
    public virtual void doHardDelete(List<SObject> recordList) {
        Database.delete(recordList);
        if(!recordList.isEmpty()) Database.emptyRecycleBin(recordList);
    }

    public virtual void doUndelete(SObject record) {this.doUnDelete(new List<SObject>{record});}
    public virtual void doUndelete(List<SObject> records) {Database.undelete(records);}
}