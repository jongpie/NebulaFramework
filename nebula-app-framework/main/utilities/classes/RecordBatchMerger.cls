/********************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.                    *
* See LICENSE file or go to https://github.com/jongpie/NebulaTriggerFramework for full license details. *
********************************************************************************************************/
public without sharing class RecordBatchMerger implements Database.Batchable<SObject>, Database.Stateful {

    private Schema.SObjectType sobjectType;
    private Schema.SObjectField masterRecordIdField;

    public RecordBatchMerger(Schema.SObjectType sobjectType, Schema.SObjectField masterRecordIdField) {
        this.sobjectType = sobjectType;
        this.masterRecordIdField = masterRecordIdField;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, ' + this.masterRecordIdField
            + ' FROM ' + this.sobjectType
            + ' WHERE ' + this.masterRecordIdField + ' != null';

        System.debug('Starting merge job using query: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<SObject> duplicateRecords) {
        for(SObject duplicateRecord : duplicateRecords) {
            System.debug('Merging duplicate record ID: ' + duplicateRecord.Id);

            Id masterRecordId = (Id)duplicateRecord.get(this.masterRecordIdField);
            System.debug('Master record ID: ' + masterRecordId);
            SObject masterRecord = this.sobjectType.newSObject(masterRecordId);

            Database.merge(masterRecord, duplicateRecord);
        }
    }

    public void finish(Database.BatchableContext context) {
        System.debug('Merge job finished for ' + this.sobjectType);
    }

}