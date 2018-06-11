/********************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.                    *
* See LICENSE file or go to https://github.com/jongpie/NebulaTriggerFramework for full license details. *
********************************************************************************************************/
public abstract class SobjectTriggerHandler implements ISobjectTriggerHandler {

    private static Map<Integer, Set<TriggerOperation>> hashCodesForProcessedRecords = new Map<Integer, Set<TriggerOperation>>();

    private Integer hashCode; // The hash code for the current records
    private Boolean isTestMode;
    private Boolean isTriggerExecuting; // Checks if the code was called by a trigger
    @testVisible private TriggerOperation currentTriggerOperation;

    @testVisible private List<Sobject> recordList, oldRecordList;
    @testVisible private Map<Id, Sobject> recordMap, oldRecordMap;

    public SobjectTriggerHandler() {
        this(false);
    }

    protected SobjectTriggerHandler(Boolean isTestMode) {
        this.isTestMode              = isTestMode;
        this.isTriggerExecuting      = Trigger.isExecuting;
        this.currentTriggerOperation = Trigger.operationType;

        this.recordList    = new List<Sobject>();
        this.recordMap     = new Map<Id, Sobject>();
        this.oldRecordList = new List<Sobject>();
        this.oldRecordMap  = new Map<Id, Sobject>();

        this.validateTriggerContext();
        this.setTriggerRecords();
    }

    public void execute() {
        // Check the custom setting. If it's disabled, stop everything, show's over
        // You don't have to go home but you can't stay here
        if(!this.shouldExecuteTriggers()) return;

        this.setHashCode();

        String sobjectType;
        if(this.isTestMode) sobjectType = String.valueOf(Schema.Lead.SobjectType);
        else sobjectType = Trigger.new == null ? String.valueOf(Trigger.old.getSobjectType()) : String.valueOf(Trigger.new.getSobjectType());

        if(this.haveRecordsAlreadyBeenProcessed()) return;

        switch on Trigger.operationType {
            when BEFORE_INSERT {
                this.executeBeforeInsert(this.recordList);
            } when BEFORE_UPDATE {
                this.executeBeforeUpdate(this.recordList, this.recordMap, this.oldRecordList, this.oldRecordMap);
            } when BEFORE_DELETE {
                this.executeBeforeDelete(this.oldRecordList, this.oldRecordMap);
            } when AFTER_INSERT {
                this.executeAfterInsert(this.recordList, this.recordMap);
            } when AFTER_UPDATE {
                this.executeAfterUpdate(this.recordList, this.recordMap, this.oldRecordList, this.oldRecordMap);
            } when AFTER_DELETE {
                this.executeAfterDelete(this.oldRecordList, this.oldRecordMap);
            } when AFTER_UNDELETE {
                this.executeAfterUndelete(this.recordList, this.recordMap);
            }
        }
    }

    protected virtual void executeBeforeInsert(List<Sobject> newRecordList) {}
    protected virtual void executeBeforeUpdate(List<Sobject> updatedRecordList, Map<Id, Sobject> updatedRecordMap, List<Sobject> oldRecordList, Map<Id, Sobject> oldRecordMap) {}
    protected virtual void executeBeforeDelete(List<Sobject> deletedRecordList, Map<Id, Sobject> deletedRecordMap) {}
    protected virtual void executeAfterInsert(List<Sobject> newRecordList, Map<Id, Sobject> newRecordMap) {}
    protected virtual void executeAfterUpdate(List<Sobject> updatedRecordList, Map<Id, Sobject> updatedRecordMap, List<Sobject> oldRecordList, Map<Id, Sobject> oldRecordMap) {}
    protected virtual void executeAfterDelete(List<Sobject> deletedRecordList, Map<Id, Sobject> deletedRecordMap) {}
    protected virtual void executeAfterUndelete(List<Sobject> undeletedRecordList, Map<Id, Sobject> undeletedRecordMap) {}

    private SobjectTriggerHandlerSettings__c getSettings() {
        SobjectTriggerHandlerSettings__c triggerHandlerSettings = SobjectTriggerHandlerSettings__c.getInstance();

        if(triggerHandlerSettings.Id != null) return triggerHandlerSettings;

        upsert SobjectTriggerHandlerSettings__c.getOrgDefaults();
        return SobjectTriggerHandlerSettings__c.getInstance();
    }

    private void validateTriggerContext() {
        if(this.isTestMode) return;

        String errorMessage = 'Trigger handler called outside of trigger execution';
        if(!this.isTriggerExecuting || Trigger.operationType == null) throw new SobjectTriggerHandlerException(errorMessage);
    }

    private String getClassName() {
        return String.valueOf(this).split(':')[0];
    }

    private void setTriggerRecords() {
        this.recordList    = this.isTestMode ? this.recordList : Trigger.new;
        this.recordMap     = this.isTestMode ? this.recordMap : Trigger.newMap;
        this.oldRecordList = this.isTestMode ? this.oldRecordList : Trigger.old;
        this.oldRecordMap  = this.isTestMode ? this.oldRecordMap : Trigger.oldMap;
    }

    private Boolean shouldExecuteTriggers() {
        String handlerClassesToSkipString = this.getSettings().HandlerClassesToSkip__c;
        if(handlerClassesToSkipString == null) handlerClassesToSkipString = '';
        Set<String> handlerClassesToSkip = new Set<String>(handlerClassesToSkipString.toLowerCase().split('\n'));

        // If ExecuteTriggers == true and the current class isn't in the list of handlers to skip, then execute
        return this.getSettings().ExecuteTriggers__c && !handlerClassesToSkip.contains(this.getClassName().toLowerCase());
    }

    private void setHashCode() {
        if(!this.getSettings().PreventRecursion__c) return;

        List<Sobject> recordToParseList;
        if(this.isTestMode) recordToParseList = this.recordList;
        else recordToParseList = Trigger.new != null ? Trigger.new : Trigger.old;

        List<String> parsedRecordsJson = new List<String>();
        for(Sobject record : recordToParseList) {
            // Some fields can cause the hash code to change even when the record itself has not
            // To get a consistent hash code, we deserialize into JSON, remove the problematic fields, then get the hash code
            Map<String, Object> parsedRecordMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(record));
            parsedRecordMap.remove('CompareName');
            parsedRecordMap.remove('CreatedById');
            parsedRecordMap.remove('CreatedDate');
            parsedRecordMap.remove('LastModifiedById');
            parsedRecordMap.remove('LastModifiedDate');
            parsedRecordMap.remove('SystemModstamp');

            // Since we're using an untyped object (map) & JSON string to generate the hash code, we need to sort the fields
            // Maps & sets aren't sortable, so we have to sort it ourselves
            Map<String, Object> sortedRecordMap = new Map<String, Object>();
            List<String> sortedKeyList = new List<String>(parsedRecordMap.keySet());
            sortedKeyList.sort();
            for(String key : sortedKeyList) sortedRecordMap.put(key, parsedRecordMap.get(key));

            parsedRecordsJson.add(JSON.serialize(sortedRecordMap));
        }
        this.hashCode = parsedRecordsJson.hashCode();
    }

    private Boolean haveRecordsAlreadyBeenProcessed() {
        if(!this.getSettings().PreventRecursion__c) return false;

        // This method is a safeguard that checks to see if we have recursion problems and stops if we do
        // It allows each context to occur once for a given hash code

        if(Trigger.operationType == TriggerOperation.BEFORE_INSERT) {
            // BEFORE_INSERT doesn't have record IDs yet, so the hash here will never match the other hashes
            // Since Salesforce makes it impossible to recursively run "insert record", we can let the platform handle it
            return false;
        } else if(!hashCodesForProcessedRecords.containsKey(this.hashCode)) {
            hashCodesForProcessedRecords.put(this.hashCode, new Set<TriggerOperation>{Trigger.operationType});
            return false;
        } else if(!hashCodesForProcessedRecords.get(this.hashCode).contains(Trigger.operationType)) {
            hashCodesForProcessedRecords.get(this.hashCode).add(Trigger.operationType);
            return false;
        } else {
            return true;
        }
    }

    private class SobjectTriggerHandlerException extends Exception {}

}