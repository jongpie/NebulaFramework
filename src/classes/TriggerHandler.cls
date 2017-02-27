public abstract class TriggerHandler {

    private static Map<Integer, Set<TriggerContext>> hashCodesForProcessedRecords = new Map<Integer, Set<TriggerContext>>();

    public enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
        AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE, AFTER_UNDELETE
    }
    public TriggerContext context; // The current context of the trigger

    private String className;
    private Integer hashCode; // The hash code for the current records
    private Boolean isTriggerExecuting; // Checks if the code was called by a trigger
    private TriggerSettings__c triggerSettings;

    protected TriggerHandler() {
        this.getClassName();
        this.getTriggerSettings();

        this.addDebugStatement('Initializing ' + this.className);
        this.setTriggerContext();
        this.validateTriggerContext();
        this.setHashCode();
    }

    public void execute() {
        this.addDebugStatement('Execute method called for ' + this.className);
        // Check the custom setting. If it's disabled, stop everything, show's over
        // You don't have to go home but you can't stay here
        if(!shouldExecuteTriggers()) {
            this.addDebugStatement('Skipping execution of class ' + this.className);
            return;
        }

        this.addDebugStatement(this.className + ' is enabled, proceeding with execution');

        String sobjectType = Trigger.new == null ? String.valueOf(Trigger.old.getSObjectType()) : String.valueOf(Trigger.new.getSObjectType());
        this.addDebugStatement('Starting execute method for: ' + sobjectType);
        this.addDebugStatement('Hash codes already processed: ' + TriggerHandler.hashCodesForProcessedRecords);
        this.addDebugStatement('Hash code for current records: ' + this.hashCode);
        this.addDebugStatement('Trigger context for current records: ' + this.context);
        this.addDebugStatement('Number of current records: ' + Trigger.size);

        if(this.haveRecordsAlreadyBeenProcessed()) {
            this.addDebugStatement('Records already processed for this context, skipping');
            return;
        } else this.addDebugStatement('Records have not been processed for this context, continuing');

        if(this.context == TriggerContext.BEFORE_INSERT) this.executeBeforeInsert(Trigger.new);
        else if(this.context == TriggerContext.BEFORE_UPDATE) this.executeBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        else if(this.context == TriggerContext.BEFORE_DELETE) this.executeBeforeDelete(Trigger.old, Trigger.oldMap);
        else if(this.context == TriggerContext.AFTER_INSERT) this.executeAfterInsert(Trigger.new, Trigger.newMap);
        else if(this.context == TriggerContext.AFTER_UPDATE) this.executeAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        else if(this.context == TriggerContext.AFTER_DELETE) this.executeAfterDelete(Trigger.old, Trigger.oldMap);
        else if(this.context == TriggerContext.AFTER_UNDELETE) this.executeAfterUndelete(Trigger.new, Trigger.newMap);
    }

    protected virtual void executeBeforeInsert(List<SObject> newRecordList) {}
    protected virtual void executeBeforeUpdate(List<SObject> updatedRecordList, Map<Id, SObject> updatedRecordMap, List<SObject> oldRecordList, Map<Id, SObject> oldRecordMap) {}
    protected virtual void executeBeforeDelete(List<SObject> deletedRecordList, Map<Id, SObject> deletedRecordMap) {}
    protected virtual void executeAfterInsert(List<SObject> newRecordList, Map<Id, SObject> newRecordMap) {}
    protected virtual void executeAfterUpdate(List<SObject> updatedRecordList, Map<Id, SObject> updatedRecordMap, List<SObject> oldRecordList, Map<Id, SObject> oldRecordMap) {}
    protected virtual void executeAfterDelete(List<SObject> deletedRecordList, Map<Id, SObject> deletedRecordMap) {}
    protected virtual void executeAfterUndelete(List<SObject> undeletedRecordList, Map<Id, SObject> undeletedRecordMap) {}

    private void getClassName() {
        this.className = String.valueOf(this).split(':')[0];
    }

    private void getTriggerSettings() {
        this.triggerSettings = TriggerSettings__c.getInstance();

        if(this.triggerSettings.Id == null) {
            // If there's no ID, then there are settings setup for the current user at the user, profile or org level
            // Upsert the org defaults - the default field values will be used
            upsert TriggerSettings__c.getOrgDefaults();
            // Call getInstance() again to get the settings with the field defaults
            this.triggerSettings = TriggerSettings__c.getInstance();
        }
    }

    private void addDebugStatement(String debugStatement) {
        if(!this.triggerSettings.EnableDebugging__c) return;

        System.debug(debugStatement);
    }

    private void setTriggerContext() {
        this.isTriggerExecuting = Trigger.isExecuting;

        if(!this.isTriggerExecuting) return;
        else if(Trigger.isBefore && Trigger.isInsert) this.context = TriggerContext.BEFORE_INSERT;
        else if(Trigger.isBefore && Trigger.isUpdate) this.context = TriggerContext.BEFORE_UPDATE;
        else if(Trigger.isBefore && Trigger.isDelete) this.context = TriggerContext.BEFORE_DELETE;
        else if(Trigger.isAfter && Trigger.isInsert) this.context = TriggerContext.AFTER_INSERT;
        else if(Trigger.isAfter && Trigger.isUpdate) this.context = TriggerContext.AFTER_UPDATE;
        else if(Trigger.isAfter && Trigger.isDelete) this.context = TriggerContext.AFTER_DELETE;
        else if(Trigger.isAfter && Trigger.isUndelete) this.context = TriggerContext.AFTER_UNDELETE;
    }

    private void validateTriggerContext() {
        String errorMessage = 'Trigger handler called outside of trigger execution';
        if(!this.isTriggerExecuting || this.context == null) throw new TriggerHandlerException(errorMessage);
    }

    private Boolean shouldExecuteTriggers() {
        this.addDebugStatement('triggerSettings.ExecuteTriggers__c=' + this.triggerSettings.ExecuteTriggers__c);

        String handlerClassesToSkipString = this.triggerSettings.HandlerClassesToSkip__c;
        if(handlerClassesToSkipString == null) handlerClassesToSkipString = '';
        Set<String> handlerClassesToSkip = new Set<String>(handlerClassesToSkipString.toLowerCase().split('\n'));
        this.addDebugStatement('triggerSettings.HandlerClassesToSkip__c=' + this.triggerSettings.HandlerClassesToSkip__c);

        // If ExecuteTriggers == true and the current class isn't in the list of handlers to skip, then execute
        return this.triggerSettings.ExecuteTriggers__c && !handlerClassesToSkip.contains(this.className.toLowerCase());
    }

    private void setHashCode() {
        List<SObject> recordList = Trigger.new != null ? Trigger.new : Trigger.old;
        List<String> parsedRecordsJson = new List<String>();
        for(SObject record : recordList) {
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
        // This method is a safeguard that checks to see if we have recursion problems and stops if we do
        // It allows each context to occur once for a given hash code
        if(this.context == TriggerContext.BEFORE_INSERT) {
            // BEFORE_INSERT doesn't have record IDs yet, so the hash here will never match the other hashes
            // Since Salesforce makes it impossible to recursively run "insert record", we can let the platform handle it
            return false;
        } else if(!TriggerHandler.hashCodesForProcessedRecords.containsKey(this.hashCode)) {
            TriggerHandler.hashCodesForProcessedRecords.put(this.hashCode, new Set<TriggerContext>{this.context});
            return false;
        } else if(!TriggerHandler.hashCodesForProcessedRecords.get(this.hashCode).contains(this.context)) {
            TriggerHandler.hashCodesForProcessedRecords.get(this.hashCode).add(this.context);
            return false;
        } else {
            return true;
        }
    }

    private class TriggerHandlerException extends Exception {}

}