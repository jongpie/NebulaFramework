/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public abstract class Dml extends NebulaCore implements IDml {

    private List<Sobject> insertRecordList = new List<Sobject>();
    private List<Sobject> updateRecordList = new List<Sobject>();
    private List<Sobject> upsertRecordList = new List<Sobject>();
    private List<Sobject> deleteRecordList = new List<Sobject>();
    private List<Sobject> undeleteRecordList = new List<Sobject>();

    public abstract Schema.SobjectType getSobjectType();

    public void registerInsertRecords(List<Sobject> recordList) {
        this.insertRecordList.addAll(recordList);
    }

    public void registerUpdateRecords(List<Sobject> recordList) {
        this.updateRecordList.addAll(recordList);
    }

    public void registerUpsertRecords(List<Sobject> recordList) {
        this.upsertRecordList.addAll(recordList);
    }

    public void registerDeleteRecords(List<Sobject> recordList) {
        this.deleteRecordList.addAll(recordList);
    }

    public void registerUndeleteRecords(List<Sobject> recordList) {
        this.undeleteRecordList.addAll(recordList);
    }

    public List<Sobject> getInsertRecords() {
        return this.insertRecordList;
    }

    public List<Sobject> getUpdateRecords() {
        return this.updateRecordList;
    }

    public List<Sobject> getUpsertRecords() {
        return this.upsertRecordList;
    }

    public List<Sobject> getDeleteRecords() {
        return this.deleteRecordList;
    }

    public List<Sobject> getUndeleteRecords() {
        return this.undeleteRecordList;
    }

    public virtual List<Database.SaveResult> insertRecords(Sobject record) {
        return this.insertRecords(new List<Sobject>{record});
    }

    public virtual List<Database.SaveResult> insertRecords(List<Sobject> records) {
        this.registerInsertRecords(records);
        return Database.insert(records);
    }

    public virtual List<Database.SaveResult> updateRecords(Sobject record) {
        return this.updateRecords(new List<Sobject>{record});
    }

    public virtual List<Database.SaveResult> updateRecords(List<Sobject> records) {
        return Database.update(records);
    }

    public virtual List<Database.UpsertResult> upsertRecords(Sobject record) {
        return this.upsertRecords(this.castRecords(record));
    }

    public virtual List<Database.UpsertResult> upsertRecords(List<Sobject> records) {
        return Database.upsert(records);
    }

    public virtual List<Database.UndeleteResult> undeleteRecords(Sobject record) {
        return this.undeleteRecords(new List<Sobject>{record});
    }

    public virtual List<Database.UndeleteResult> undeleteRecords(List<Sobject> records) {
        return Database.undelete(records);
    }

    public virtual List<Database.DeleteResult> deleteRecords(Sobject record) {
        return this.deleteRecords(new List<Sobject>{record});
    }

    public virtual List<Database.DeleteResult> deleteRecords(List<Sobject> records) {
        return Database.delete(records);
    }

    public virtual List<Database.DeleteResult> hardDeleteRecords(Sobject record) {
        return this.hardDeleteRecords(new List<Sobject>{record});
    }

    public virtual List<Database.DeleteResult> hardDeleteRecords(List<Sobject> records) {
        List<Database.DeleteResult> results = this.deleteRecords(records);
        if(!records.isEmpty()) Database.emptyRecycleBin(records);
        return results;
    }

    // Not all objects are mergeable or will have external ID fields, so these methods are protected (instead of public)
    // Any object that needs these methods can expose these methods in their repos
    protected virtual List<Database.MergeResult> mergeRecords(Sobject masterRecord, Sobject recordToMerge) {
        return this.mergeRecords(masterRecord, this.castRecords(recordToMerge));
    }

    protected virtual List<Database.MergeResult> mergeRecords(Sobject masterRecord, List<Sobject> recordsToMerge) {
        return Database.merge(masterRecord, recordsToMerge);
    }

    protected virtual List<Database.UpsertResult> upsertRecords(Sobject record, Schema.SobjectField externalIdField) {
        return this.upsertRecords(this.castRecords(record), externalIdField);
    }

    protected virtual List<Database.UpsertResult> upsertRecords(List<Sobject> records, Schema.SobjectField externalIdField) {
        return Database.upsert(records, externalIdField);
    }

    private List<Sobject> castRecords(Sobject record) {
        // Salesforce will only allow upsert calls for Sobjects if a declared-type list is passed in.
        // This is fine for the bulk method, where we can assume the caller is passing in an explicit list, but for a single record,
        // the only way to successfully perform the upsert is to dynamically spin up a list of the Sobject's type

        String listType = 'List<' + record.getSobjectType() + '>';
        List<Sobject> castRecords = (List<Sobject>)Type.forName(listType).newInstance();
        castRecords.add(record);

        return castRecords;
    }

}