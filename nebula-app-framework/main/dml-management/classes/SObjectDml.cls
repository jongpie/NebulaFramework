/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public abstract class SObjectDml implements ISObjectDml {

    public enum CrudMode { SYSTEM_MODE, USER_MODE }

    private enum DmlOperation {
        INSERT_RECORDS, UPDATE_RECORDS, UPSERT_RECORDS,
        DELETE_RECORDS, UNDELETE_RECORDS, HARD_DELETE_RECORDS, MERGE_RECORDS
    }

    private CrudMode currentMode;
    private List<SObject> insertRecordList   = new List<SObject>();
    private List<SObject> updateRecordList   = new List<SObject>();
    private List<SObject> upsertRecordList   = new List<SObject>();
    private List<SObject> deleteRecordList   = new List<SObject>();
    private List<SObject> undeleteRecordList = new List<SObject>();

    public SObjectDml () {
        this.currentMode = CrudMode.USER_MODE;
    }

    public abstract Schema.SObjectType getSObjectType();

    public virtual LoggingLevel getLoggingLevel() {
        return LoggingLevel.DEBUG;
    }

    public ISObjectDml setMode(CrudMode mode) {
        this.currentMode = mode;
        return this;
    }

    public void registerInsertRecords(List<SObject> recordList) {
        this.insertRecordList.addAll(recordList);
    }

    public void registerUpdateRecords(List<SObject> recordList) {
        this.updateRecordList.addAll(recordList);
    }

    public void registerUpsertRecords(List<SObject> recordList) {
        this.upsertRecordList.addAll(recordList);
    }

    public void registerDeleteRecords(List<SObject> recordList) {
        this.deleteRecordList.addAll(recordList);
    }

    public void registerUndeleteRecords(List<SObject> recordList) {
        this.undeleteRecordList.addAll(recordList);
    }

    public List<SObject> getInsertRecords() {
        return this.insertRecordList;
    }

    public List<SObject> getUpdateRecords() {
        return this.updateRecordList;
    }

    public List<SObject> getUpsertRecords() {
        return this.upsertRecordList;
    }

    public List<SObject> getDeleteRecords() {
        return this.deleteRecordList;
    }

    public List<SObject> getUndeleteRecords() {
        return this.undeleteRecordList;
    }

    public virtual List<Database.SaveResult> insertRecords(SObject record) {
        return this.insertRecords(new List<SObject>{record});
    }

    public virtual List<Database.SaveResult> insertRecords(List<SObject> records) {
        if(this.currentMode == CrudMode.USER_MODE) this.validateUserPermissions(records, DmlOperation.INSERT_RECORDS);

        this.registerInsertRecords(records);
        return Database.insert(records);
    }

    public virtual List<Database.SaveResult> updateRecords(SObject record) {
        return this.updateRecords(new List<SObject>{record});
    }

    public virtual List<Database.SaveResult> updateRecords(List<SObject> records) {
        if(this.currentMode == CrudMode.USER_MODE) this.validateUserPermissions(records, DmlOperation.UPDATE_RECORDS);

        return Database.update(records);
    }

    public virtual List<Database.UpsertResult> upsertRecords(SObject record) {
        return this.upsertRecords(this.castRecords(record));
    }

    public virtual List<Database.UpsertResult> upsertRecords(List<SObject> records) {
        if(this.currentMode == CrudMode.USER_MODE) this.validateUserPermissions(records, DmlOperation.UPSERT_RECORDS);

        return Database.upsert(records);
    }

    public virtual List<Database.UndeleteResult> undeleteRecords(SObject record) {
        return this.undeleteRecords(new List<SObject>{record});
    }

    public virtual List<Database.UndeleteResult> undeleteRecords(List<SObject> records) {
        if(this.currentMode == CrudMode.USER_MODE) this.validateUserPermissions(records, DmlOperation.UNDELETE_RECORDS);

        return Database.undelete(records);
    }

    public virtual List<Database.DeleteResult> deleteRecords(SObject record) {
        return this.deleteRecords(new List<SObject>{record});
    }

    public virtual List<Database.DeleteResult> deleteRecords(List<SObject> records) {
        if(this.currentMode == CrudMode.USER_MODE) this.validateUserPermissions(records, DmlOperation.DELETE_RECORDS);

        return Database.delete(records);
    }

    public virtual List<Database.DeleteResult> hardDeleteRecords(SObject record) {
        return this.hardDeleteRecords(new List<SObject>{record});
    }

    public virtual List<Database.DeleteResult> hardDeleteRecords(List<SObject> records) {
        if(this.currentMode == CrudMode.USER_MODE) this.validateUserPermissions(records, DmlOperation.HARD_DELETE_RECORDS);

        List<Database.DeleteResult> results = this.deleteRecords(records);
        if(!records.isEmpty()) Database.emptyRecycleBin(records);
        return results;
    }

    // Not all objects are mergeable or will have external ID fields, so these methods are protected (instead of public)
    // Any object that needs these methods can expose these methods in their repos
    protected virtual List<Database.MergeResult> mergeRecords(SObject masterRecord, SObject recordToMerge) {
        return this.mergeRecords(masterRecord, this.castRecords(recordToMerge));
    }

    protected virtual List<Database.MergeResult> mergeRecords(SObject masterRecord, List<SObject> recordsToMerge) {
        if(this.currentMode == CrudMode.USER_MODE) this.validateUserPermissions(recordsToMerge, DmlOperation.MERGE_RECORDS);

        return Database.merge(masterRecord, recordsToMerge);
    }

    protected virtual List<Database.UpsertResult> upsertRecords(SObject record, Schema.SObjectField externalIdField) {
        return this.upsertRecords(this.castRecords(record), externalIdField);
    }

    protected virtual List<Database.UpsertResult> upsertRecords(List<SObject> records, Schema.SObjectField externalIdField) {
        if(this.currentMode == CrudMode.USER_MODE) this.validateUserPermissions(records, DmlOperation.UPSERT_RECORDS);

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

    private void validateUserPermissions(List<SObject> records, DmlOperation operation) {
        if(records == null || records.isEmpty()) return;

        Schema.SObjectType sobjectType = records[0].getSObjectType();
        DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();

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