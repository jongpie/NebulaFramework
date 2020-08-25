/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public abstract class SObjectTriggerHandler {

    private static Map<Integer, Set<TriggerContext>> hashCodesForProcessedRecords = new Map<Integer, Set<TriggerContext>>();

    @testVisible private enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
        AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE, AFTER_UNDELETE
    }
    @testVisible private TriggerContext currentTriggerContext; // The current context of the trigger

    private Integer hashCode; // The hash code for the current records
    private Boolean isTestMode;
    private Boolean isTriggerExecuting; // Checks if the code was called by a trigger

    @testVisible private List<SObject> recordList, oldRecordList;
    @testVisible private Map<Id, SObject> recordMap, oldRecordMap;

    public SObjectTriggerHandler() {
        this(false);
    }

    protected SObjectTriggerHandler(Boolean isTestMode) {
        this.isTestMode         = isTestMode;
        this.isTriggerExecuting = Trigger.isExecuting;

        this.recordList    = new List<SObject>();
        this.recordMap     = new Map<Id, SObject>();
        this.oldRecordList = new List<SObject>();
        this.oldRecordMap  = new Map<Id, SObject>();

        this.getClassName();

        Logger.addEntry(this, 'Initializing ' + this.getClassName());
        this.setTriggerContext();
        this.validateTriggerContext();
        this.setTriggerRecords();
    }

    public void execute() {
        Logger.addEntry(this, 'Execute method called for ' + this.getClassName());
        // Check the custom setting. If it's disabled, stop everything, show's over
        // You don't have to go home but you can't stay here
        if(!shouldExecuteTriggers()) {
            Logger.addEntry(this, 'Skipping execution of class ' + this.getClassName());
            return;
        }

        Logger.addEntry(this, this.getClassName() + ' is enabled, proceeding with execution');

        this.setHashCode();

        String sobjectType;
        if(this.isTestMode) sobjectType = String.valueOf(Schema.Lead.SObjectType);
        else sobjectType = Trigger.new == null ? String.valueOf(Trigger.old.getSObjectType()) : String.valueOf(Trigger.new.getSObjectType());

        Logger.addEntry(this, 'Starting execute method for: ' + sobjectType);
        Logger.addEntry(this, 'Hash codes already processed: ' + hashCodesForProcessedRecords);
        Logger.addEntry(this, 'Hash code for current records: ' + this.hashCode);
        Logger.addEntry(this, 'Trigger context for current records: ' + this.currentTriggerContext);
        Logger.addEntry(this, 'Number of current records: ' + Trigger.size);

        if(this.haveRecordsAlreadyBeenProcessed()) {
            Logger.addEntry(this, 'Records already processed for this context, skipping');
            return;
        } else Logger.addEntry(this, 'Records have not been processed for this context, continuing');

        if(this.currentTriggerContext == TriggerContext.BEFORE_INSERT) this.executeBeforeInsert(this.recordList);
        else if(this.currentTriggerContext == TriggerContext.BEFORE_UPDATE) this.executeBeforeUpdate(this.recordList, this.recordMap, this.oldRecordList, this.oldRecordMap);
        else if(this.currentTriggerContext == TriggerContext.BEFORE_DELETE) this.executeBeforeDelete(this.oldRecordList, this.oldRecordMap);
        else if(this.currentTriggerContext == TriggerContext.AFTER_INSERT) this.executeAfterInsert(this.recordList, this.recordMap);
        else if(this.currentTriggerContext == TriggerContext.AFTER_UPDATE) this.executeAfterUpdate(this.recordList, this.recordMap, this.oldRecordList, this.oldRecordMap);
        else if(this.currentTriggerContext == TriggerContext.AFTER_DELETE) this.executeAfterDelete(this.oldRecordList, this.oldRecordMap);
        else if(this.currentTriggerContext == TriggerContext.AFTER_UNDELETE) this.executeAfterUndelete(this.recordList, this.recordMap);

        if(Trigger.isAfter) Logger.saveLogs();
    }

    protected virtual void executeBeforeInsert(List<SObject> newRecordList) {}
    protected virtual void executeBeforeUpdate(List<SObject> updatedRecordList, Map<Id, SObject> updatedRecordMap, List<SObject> oldRecordList, Map<Id, SObject> oldRecordMap) {}
    protected virtual void executeBeforeDelete(List<SObject> deletedRecordList, Map<Id, SObject> deletedRecordMap) {}
    protected virtual void executeAfterInsert(List<SObject> newRecordList, Map<Id, SObject> newRecordMap) {}
    protected virtual void executeAfterUpdate(List<SObject> updatedRecordList, Map<Id, SObject> updatedRecordMap, List<SObject> oldRecordList, Map<Id, SObject> oldRecordMap) {}
    protected virtual void executeAfterDelete(List<SObject> deletedRecordList, Map<Id, SObject> deletedRecordMap) {}
    protected virtual void executeAfterUndelete(List<SObject> undeletedRecordList, Map<Id, SObject> undeletedRecordMap) {}

    private void setTriggerContext() {
        if(this.isTestMode || !this.isTriggerExecuting) return;

        if(Trigger.isBefore && Trigger.isInsert) this.currentTriggerContext = TriggerContext.BEFORE_INSERT;
        else if(Trigger.isBefore && Trigger.isUpdate) this.currentTriggerContext = TriggerContext.BEFORE_UPDATE;
        else if(Trigger.isBefore && Trigger.isDelete) this.currentTriggerContext = TriggerContext.BEFORE_DELETE;
        else if(Trigger.isAfter && Trigger.isInsert) this.currentTriggerContext = TriggerContext.AFTER_INSERT;
        else if(Trigger.isAfter && Trigger.isUpdate) this.currentTriggerContext = TriggerContext.AFTER_UPDATE;
        else if(Trigger.isAfter && Trigger.isDelete) this.currentTriggerContext = TriggerContext.AFTER_DELETE;
        else if(Trigger.isAfter && Trigger.isUndelete) this.currentTriggerContext = TriggerContext.AFTER_UNDELETE;
    }

    private void validateTriggerContext() {
        if(this.isTestMode) return;

        String errorMessage = 'Trigger handler called outside of trigger execution ' + this.isTriggerExecuting;
        if(!this.isTriggerExecuting || this.currentTriggerContext == null) throw new SObjectTriggerHandlerException(errorMessage);
    }

    private void setTriggerRecords() {
        this.recordList    = this.isTestMode ? this.recordList : Trigger.new;
        this.recordMap     = this.isTestMode ? this.recordMap : Trigger.newMap;
        this.oldRecordList = this.isTestMode ? this.oldRecordList : Trigger.old;
        this.oldRecordMap  = this.isTestMode ? this.oldRecordMap : Trigger.oldMap;
    }

    private Boolean shouldExecuteTriggers() {
        Logger.addEntry(this, 'nebulaSettings.triggerHandlerSettings.ExecuteTriggers__c=' + NebulaSettings.triggerHandlerSettings.ExecuteTriggers__c);

        String handlerClassesToSkipString = NebulaSettings.triggerHandlerSettings.HandlerClassesToSkip__c;
        if(handlerClassesToSkipString == null) handlerClassesToSkipString = '';
        Set<String> handlerClassesToSkip = new Set<String>(handlerClassesToSkipString.toLowerCase().split('\n'));
        Logger.addEntry(this, 'nebulaSettings.triggerHandlerSettings.HandlerClassesToSkip__c=' + NebulaSettings.triggerHandlerSettings.HandlerClassesToSkip__c);

        // If ExecuteTriggers == true and the current class isn't in the list of handlers to skip, then execute
        return NebulaSettings.triggerHandlerSettings.ExecuteTriggers__c && !handlerClassesToSkip.contains(this.getClassName().toLowerCase());
    }

    private void setHashCode() {
        List<SObject> recordToParseList;
        if(this.isTestMode) recordToParseList = this.recordList;
        else recordToParseList = Trigger.new != null ? Trigger.new : Trigger.old;

        List<String> parsedRecordsJson = new List<String>();
        for(SObject record : recordToParseList) {
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
        if(!NebulaSettings.triggerHandlerSettings.PreventRecursion__c) return false;

        // This method is a safeguard that checks to see if we have recursion problems and stops if we do
        // It allows each context to occur once for a given hash code

        if(this.currentTriggerContext == TriggerContext.BEFORE_INSERT) {
            // BEFORE_INSERT doesn't have record IDs yet, so the hash here will never match the other hashes
            // Since Salesforce makes it impossible to recursively run "insert record", we can let the platform handle it
            return false;
        } else if(!hashCodesForProcessedRecords.containsKey(this.hashCode)) {
            hashCodesForProcessedRecords.put(this.hashCode, new Set<TriggerContext>{this.currentTriggerContext});
            return false;
        } else if(!hashCodesForProcessedRecords.get(this.hashCode).contains(this.currentTriggerContext)) {
            hashCodesForProcessedRecords.get(this.hashCode).add(this.currentTriggerContext);
            return false;
        } else {
            return true;
        }
    }

    private class SObjectTriggerHandlerException extends Exception {}

}