public class UnitOfWork extends NebulaCore {

    private List<Schema.SObjectType> commitOrder;
    private Map<Schema.SObjectType, List<IDML>> dmlMap = new Map<Schema.SObjectType, List<IDML>>();
    //private List<IDML> dmls = new List<IDML>();
    private List<RecordRelator> recordRelators = new List<RecordRelator>();
    private Map<Schema.SObjectType, List<RecordRelator>> recordRelatorMap = new Map<Schema.SObjectType, List<RecordRelator>>();

    public UnitOfWork(List<Schema.SObjectType> commitOrder) {
        this.commitOrder = commitOrder;
    }

    public void add(IDML dml) {
        List<IDML> dmlBySObjectType = this.dmlMap.get(dml.getSObjectType());
        // If it's the first instance of this sobject type, initialize the list
        if(dmlBySObjectType == null) dmlBySObjectType = new List<IDML>();

        dmlBySObjectType.add(dml);
        this.dmlMap.put(dml.getSObjectType(), dmlBySObjectType);
    }

    // public void addSObjectRepository_old(IDML dml) {
    //     this.dmls.add(dml);
    // }

    public void relate(SObject childRecord, Schema.SObjectField relationshipField, SObject parentRecord) {
        List<RecordRelator> recordRelatorsForParentSObjectType = this.recordRelatorMap.get(parentRecord.getSObjectType());
        // If it's the first instance of this sobject type, initialize the list
        if(recordRelatorsForParentSObjectType == null) recordRelatorsForParentSObjectType = new List<RecordRelator>();

        RecordRelator recordRelator = new RecordRelator(childRecord, relationshipField, parentRecord);
        recordRelatorsForParentSObjectType.add(recordRelator);
        this.recordRelatorMap.put(parentRecord.getSObjectType(), recordRelatorsForParentSObjectType);
    }

    // public void relate_old(SObject childRecord, Schema.SObjectField relationshipField, SObject parentRecord) {
    //     this.recordRelators.add(new RecordRelator(childRecord, relationshipField, parentRecord));
    // }

    public void commitChanges() {
        // TODO add logger entries about commitOrder, repos, etc
        SavePoint sp = Database.setSavepoint();
        try {
            // Loop through the list of commit orders - sorted list == we know the order to run DML
            for(Schema.SObjectType currentSObjectType : this.commitOrder) {
                // Check all of the DMLs - there could be multiple DML implementations for the same SObject Type, so must be a list as well
                for(IDML dml : this.dmlMap.get(currentSObjectType)) {
                    // Do it
                    this.processDML(dml);
                    this.relateRecords(currentSObjectType);
                }
            }
            Logger.saveLogs();
        } catch(Exception ex) {
            Database.rollback(sp);
            this.rollbackInsertRecordIds();
            this.rollbackRecordRelators();
            throw(ex);
        }
    }

    private void processDML(IDML dml) {
        if(!dml.getInsertRecords().isEmpty()) dml.insertRecords(dml.getInsertRecords());
        if(!dml.getUpdateRecords().isEmpty()) dml.updateRecords(dml.getUpdateRecords());
        if(!dml.getUpsertRecords().isEmpty()) dml.upsertRecords(dml.getUpsertRecords());
        if(!dml.getDeleteRecords().isEmpty()) dml.deleteRecords(dml.getDeleteRecords());
        if(!dml.getUndeleteRecords().isEmpty()) dml.undeleteRecords(dml.getUndeleteRecords());
    }

    private void relateRecords(Schema.SObjectType currentSObjectType) {
        if(!this.recordRelatorMap.containsKey(currentSObjectType)) return;

        for(RecordRelator recordRelator : this.recordRelatorMap.get(currentSObjectType)) {
            recordRelator.relate();
        }
    }

    private void rollbackInsertRecordIds() {
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_transaction_control.htm
        // From the documentation,
        //      "The ID on an sObject inserted after setting a savepoint is not cleared after a rollback.
        //      Create an sObject to insert after a rollback. Attempting to insert the sObject using the variable created before
        //      the rollback fails because the sObject variable has an ID. Updating or upserting the sObject using the same variable
        //      also fails because the sObject is not in the database and, thus, cannot be updated."
        for(List<IDML> dmls : this.dmlMap.values()) {
            for(IDML dml : dmls) {
                for(SObject insertRecord : dml.getInsertRecords()) {
                    insertRecord.put('Id', null);
                }
            }
        }
    }

    private void rollbackRecordRelators() {
        for(List<RecordRelator> recordRelators : this.recordRelatorMap.values()) {
            for(RecordRelator recordRelator : recordRelators) {
                recordRelator.rollbackRelate();
            }
        }
    }

    // private void relateRecords_old(Schema.SObjectType currentSObjectType) {
    //     for(Integer i = 0; i < this.recordRelators.size(); i++) {
    //         // Get
    //         RecordRelator recordRelator = this.recordRelators[i];
    //         // Validate
    //         if(recordRelator.parentRecord.Id == null) throw new UnitOfWorkException('Parent record has not been inserted');
    //         // Verify
    //         if(recordRelator.parentRecord.getSObjectType() != currentSObjectType) continue;
    //         // Process
    //         String fieldName = recordRelator.relationshipField.getDescribe().getName();
    //         recordRelator.childRecord.put(fieldName, recordRelator.parentRecord.Id);
    //         recordRelators.remove(i);
    //     }
    // }

    private class UnitOfWorkException extends Exception {}

    private class RecordRelator {
        public SObject childRecord, parentRecord;
        public Schema.SObjectField relationshipField;

        private String relationshipFieldName;
        private Id originalRelationshipFieldValue;

        public RecordRelator(SObject childRecord, Schema.SObjectField relationshipField, SObject parentRecord) {
            this.childRecord       = childRecord;
            this.relationshipField = relationshipField;
            this.parentRecord      = parentRecord;

            this.relationshipFieldName          = this.relationshipField.getDescribe().getName();
            this.originalRelationshipFieldValue = (Id)childRecord.get(relationshipField.getDescribe().getName());
        }

        public void relate() {
            if(this.parentRecord.Id == null) throw new UnitOfWorkException('Parent record has not been inserted');

            this.childRecord.put(this.relationshipFieldName, this.parentRecord.Id);
        }

        public void rollbackRelate() {
            this.childRecord.put(this.relationshipFieldName, this.originalRelationshipFieldValue);
            //System.assert(false, 'value=' + this.childRecord.get(this.relationshipFieldName));
        }
    }

}