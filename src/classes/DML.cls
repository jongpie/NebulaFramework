/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public abstract class DML extends NebulaCore implements IDML {

    private Schema.SObjectType sobjectType;

    public DML(Schema.SObjectType sobjectType) {
        this.sobjectType = sobjectType;
    }

    public virtual void insertRecords(SObject record) {
        this.insertRecords(new List<SObject>{record});
    }

    public virtual void insertRecords(List<SObject> records) {
        Database.insert(records);
    }

    public virtual void updateRecords(SObject record) {
        this.updateRecords(new List<SObject>{record});
    }

    public virtual void updateRecords(List<SObject> records) {
        Database.update(records);
    }

    public virtual void upsertRecords(SObject record) {
        this.upsertRecords(this.castRecords(record));
    }

    public virtual void upsertRecords(List<SObject> records) {
        Database.upsert(records);
    }

    public virtual void undeleteRecords(SObject record) {
        this.undeleteRecords(new List<SObject>{record});
    }

    public virtual void undeleteRecords(List<SObject> records) {
        Database.undelete(records);
    }

    public virtual void deleteRecords(SObject record) {
        this.deleteRecords(new List<SObject>{record});
    }

    public virtual void deleteRecords(List<SObject> records) {
        Database.delete(records);
    }

    public virtual void hardDeleteRecords(SObject record) {
        this.hardDeleteRecords(new List<SObject>{record});
    }

    public virtual void hardDeleteRecords(List<SObject> records) {
        this.deleteRecords(records);
        if(!records.isEmpty()) Database.emptyRecycleBin(records);
    }

    // Not all objects will have external ID fields, so these methods are protected (instead of public)
    // Any object that needs an upsert by external ID can expose these methods in their repos
    protected virtual void upsertRecords(SObject record, Schema.SObjectField externalIdField) {
        this.upsertRecords(this.castRecords(record), externalIdField);
    }

    protected virtual void upsertRecords(List<SObject> records, Schema.SObjectField externalIdField) {
        Database.upsert(records, externalIdField);
    }

    private List<SObject> castRecords(SObject record) {
        // Salesforce will only allow upsert calls for SObjects if a declared-type list is passed in.
        // This is fine for the bulk method, where we can assume the caller is passing in an explicit list, but for a single record,
        // the only way to successfully perform the upsert is to dynamically spin up a list of the SObject's type

        String listType = 'List<' + this.sobjectType + '>';
        List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
        castRecords.add(record);

        return castRecords;
    }

}