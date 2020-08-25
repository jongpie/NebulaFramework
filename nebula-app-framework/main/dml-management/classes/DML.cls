/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Repository
*
* @description Provides methods with default behavior for DML actions (insert, upsert, etc)
*
*/
public abstract class DML implements IDML {

    public virtual List<Database.SaveResult> insertRecords(SObject record) {
        return this.insertRecords(new List<SObject>{record});
    }

    public virtual List<Database.SaveResult> insertRecords(List<SObject> records) {
        return Database.insert(records);
    }

    public virtual List<Database.SaveResult> updateRecords(SObject record) {
        return this.updateRecords(new List<SObject>{record});
    }

    public virtual List<Database.SaveResult> updateRecords(List<SObject> records) {
        return Database.update(records);
    }

    public virtual List<Database.UpsertResult> upsertRecords(SObject record) {
        return this.upsertRecords(this.castRecords(record));
    }

    public virtual List<Database.UpsertResult> upsertRecords(List<SObject> records) {
        return Database.upsert(records);
    }

    public virtual List<Database.UndeleteResult> undeleteRecords(SObject record) {
        return this.undeleteRecords(new List<SObject>{record});
    }

    public virtual List<Database.UndeleteResult> undeleteRecords(List<SObject> records) {
        return Database.undelete(records);
    }

    public virtual List<Database.DeleteResult> deleteRecords(SObject record) {
        return this.deleteRecords(new List<SObject>{record});
    }

    public virtual List<Database.DeleteResult> deleteRecords(List<SObject> records) {
        return Database.delete(records);
    }

    public virtual List<Database.DeleteResult> hardDeleteRecords(SObject record) {
        return this.hardDeleteRecords(new List<SObject>{record});
    }

    public virtual List<Database.DeleteResult> hardDeleteRecords(List<SObject> records) {
        List<Database.DeleteResult> results = this.deleteRecords(records);
        if(!records.isEmpty()) Database.emptyRecycleBin(records);
        return results;
    }

    // Not all objects will have external ID fields, so these methods are protected (instead of public)
    // Any object that needs an upsert by external ID can expose these methods in their repos
    protected virtual List<Database.UpsertResult> upsertRecords(SObject record, Schema.SObjectField externalIdField) {
        return this.upsertRecords(this.castRecords(record), externalIdField);
    }

    protected virtual List<Database.UpsertResult> upsertRecords(List<SObject> records, Schema.SObjectField externalIdField) {
        return Database.upsert(records, externalIdField);
    }

    private List<SObject> castRecords(SObject record) {
        // Salesforce will only allow upsert calls for SObjects if a declared-type list is passed in.
        // This is fine for the bulk method, where we can assume the caller is passing in an explicit list, but for a single record,
        // the only way to successfully perform the upsert is to dynamically spin up a list of the SObject's type

        String listType = 'List<' + record.getSObjectType() + '>';
        List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
        castRecords.add(record);

        return castRecords;
    }

}