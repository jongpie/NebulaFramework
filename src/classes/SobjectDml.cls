/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public abstract class SobjectDml extends NebulaCore implements ISobjectDml {

    public enum CrudMode { SYSTEM_MODE, USER_MODE }

    private enum DmlOperation {
        INSERT_RECORDS, UPDATE_RECORDS, UPSERT_RECORDS,
        DELETE_RECORDS, UNDELETE_RECORDS, HARD_DELETE_RECORDS, MERGE_RECORDS
    }

    private CrudMode currentMode;
    private List<Sobject> insertRecordList   = new List<Sobject>();
    private List<Sobject> updateRecordList   = new List<Sobject>();
    private List<Sobject> upsertRecordList   = new List<Sobject>();
    private List<Sobject> deleteRecordList   = new List<Sobject>();
    private List<Sobject> undeleteRecordList = new List<Sobject>();

    public SobjectDml () {
        this.currentMode = CrudMode.USER_MODE;
    }

    public ISobjectDml setMode(CrudMode mode) {
        this.currentMode = mode;
        return this;
    }

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
        if(this.currentMode == CrudMode.USER_MODE) this.validateUserPermissions(records, DmlOperation.INSERT_RECORDS);

        this.registerInsertRecords(records);
        return Database.insert(records);
    }

    public virtual List<Database.SaveResult> updateRecords(Sobject record) {
        return this.updateRecords(new List<Sobject>{record});
    }

    public virtual List<Database.SaveResult> updateRecords(List<Sobject> records) {
        if(this.currentMode == CrudMode.USER_MODE) this.validateUserPermissions(records, DmlOperation.UPDATE_RECORDS);

        return Database.update(records);
    }

    public virtual List<Database.UpsertResult> upsertRecords(Sobject record) {
        return this.upsertRecords(this.castRecords(record));
    }

    public virtual List<Database.UpsertResult> upsertRecords(List<Sobject> records) {
        if(this.currentMode == CrudMode.USER_MODE) this.validateUserPermissions(records, DmlOperation.UPSERT_RECORDS);

        return Database.upsert(records);
    }

    public virtual List<Database.UndeleteResult> undeleteRecords(Sobject record) {
        return this.undeleteRecords(new List<Sobject>{record});
    }

    public virtual List<Database.UndeleteResult> undeleteRecords(List<Sobject> records) {
        if(this.currentMode == CrudMode.USER_MODE) this.validateUserPermissions(records, DmlOperation.UNDELETE_RECORDS);

        return Database.undelete(records);
    }

    public virtual List<Database.DeleteResult> deleteRecords(Sobject record) {
        return this.deleteRecords(new List<Sobject>{record});
    }

    public virtual List<Database.DeleteResult> deleteRecords(List<Sobject> records) {
        if(this.currentMode == CrudMode.USER_MODE) this.validateUserPermissions(records, DmlOperation.DELETE_RECORDS);

        return Database.delete(records);
    }

    public virtual List<Database.DeleteResult> hardDeleteRecords(Sobject record) {
        return this.hardDeleteRecords(new List<Sobject>{record});
    }

    public virtual List<Database.DeleteResult> hardDeleteRecords(List<Sobject> records) {
        if(this.currentMode == CrudMode.USER_MODE) this.validateUserPermissions(records, DmlOperation.HARD_DELETE_RECORDS);

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
        if(this.currentMode == CrudMode.USER_MODE) this.validateUserPermissions(recordsToMerge, DmlOperation.MERGE_RECORDS);

        return Database.merge(masterRecord, recordsToMerge);
    }

    protected virtual List<Database.UpsertResult> upsertRecords(Sobject record, Schema.SobjectField externalIdField) {
        return this.upsertRecords(this.castRecords(record), externalIdField);
    }

    protected virtual List<Database.UpsertResult> upsertRecords(List<Sobject> records, Schema.SobjectField externalIdField) {
        if(this.currentMode == CrudMode.USER_MODE) this.validateUserPermissions(records, DmlOperation.UPSERT_RECORDS);

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

    private void validateUserPermissions(List<Sobject> records, DmlOperation operation) {
        Schema.SobjectType sobjectType = records.getSobjectType();
        DescribeSobjectResult sobjectDescribe = sobjectType.getDescribe();

        switch on operation {
            when INSERT_RECORDS {
                if(!sobjectDescribe.isCreateable()) throw new DmlPermissionException('No insert access for ' + sobjectType);
            }
            when UPDATE_RECORDS {
                if(!sobjectDescribe.isUpdateable()) throw new DmlPermissionException('No update access for ' + sobjectType);
            }
            when UPSERT_RECORDS {
                if(!sobjectDescribe.isCreateable() || !sobjectDescribe.isUpdateable()) {
                    throw new DmlPermissionException('No upsert access for ' + sobjectType);
                }
            }
            when DELETE_RECORDS, UNDELETE_RECORDS, HARD_DELETE_RECORDS, MERGE_RECORDS {
                if(!sobjectDescribe.isDeletable()) throw new DmlPermissionException('No delete access for ' + sobjectType);
            }
        }
    }

    public class DmlPermissionException extends Exception {}

}