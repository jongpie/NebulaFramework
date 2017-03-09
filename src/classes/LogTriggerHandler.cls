public without sharing class LogTriggerHandler extends SObjectTriggerHandler {

    /*protected override void executeBeforeInsert(List<SObject> newRecordList) {
        List<Log__c> newLogList = (List<Log__c>)newRecordList;

        for(Log__c newLog : newLogList) {
            this.setTransactionId(newLog);
        }
    }

    protected override void executeBeforeUpdate(List<SObject> updatedRecordList, Map<Id, SObject> updatedRecordListMap, List<SObject> oldRecordList, Map<Id, SObject> oldRecordMap) {
        List<Log__c> updatedLogList = (List<Log__c>)updatedRecordList;
        Map<Id, Log__c> oldLogMap   = (Map<Id, Log__c>)oldRecordMap;

        for(Log__c updatedLog : updatedLogList) {
            Log__c oldLog = oldLogMap.get(updatedLog.Id);

            this.setTransactionId(updatedLog, oldLog);
        }
    }

    private void setTransactionId(Log__c updatedLog, Log__c oldLog) {
        // You probably don't want to allow the UUID to change, so add an error
        if(updatedLog.TransactionId__c != oldLog.TransactionId__c) updatedLog.TransactionId__c.addError('Transaction ID cannot be changed');

        // If it's a new field, you can have the UUID set the next time the record is updated
        if(!UUID.isValid(updatedLog.TransactionId__c)) this.setTransactionId(updatedLog);
    }

    private void setTransactionId(Log__c log) {
        if(UUID.isValid(log.TransactionId__c)) return;

        log.TransactionId__c = new UUID().getValue();
    }*/

}