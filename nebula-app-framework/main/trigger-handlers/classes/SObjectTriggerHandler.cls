/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public abstract class SObjectTriggerHandler implements ISObjectHandler {

    private static Map<Integer, Set<System.TriggerOperation>> hashCodesForProcessedRecords    = new Map<Integer, Set<System.TriggerOperation>>();
    private static Map<String, SObjectTriggerOperationHandler> triggerOperationHandlersByName = new Map<String, SObjectTriggerOperationHandler>();

    @testVisible
    private Boolean isTestMode;

    @testVisible
    private Boolean isTriggerExecuting; // Checks if the code was called by a trigger
    @testVisible
    private System.TriggerOperation currentTriggerOperation;
    @testVisible
    private List<SObject> recordList, oldRecordList;
    @testVisible
    private Map<Id, SObject> recordMap, oldRecordMap;

    private Integer hashCode; // The hash code for the current records

    public SObjectTriggerHandler() {
        this.isTestMode         = false;

        this.isTriggerExecuting = Trigger.isExecuting;
        this.recordList         = Trigger.new;
        this.recordMap          = Trigger.newMap;
        this.oldRecordList      = Trigger.old;
        this.oldRecordMap       = Trigger.oldMap;

    }

    public abstract Schema.SObjectType getSObjectType();

    public SObjectTriggerHandler setTriggerOperationHandler(SObjectTriggerOperationHandler triggerOperationHandler) {
        String triggerOperationHandlerName = this.getTriggerOperationHandlerName(this.getSObjectType(), triggerOperationHandler.getTriggerOperation());
        triggerOperationHandlersByName.put(triggerOperationHandlerName, triggerOperationHandler);

        return this;
    }

    public void execute() {
        System.debug('Execute method called');

        this.validateTriggerContext();

        if(!this.isTestMode) this.currentTriggerOperation = Trigger.operationType;

        // Check the custom setting. If it's disabled, stop everything, show's over
        // You don't have to go home but you can't stay here
        if(!shouldExecuteTriggers()) {
            System.debug('Skipping execution of class');
            return;
        }

        System.debug('Handler is enabled, proceeding with execution');

        this.setTriggerRecords();
        this.setHashCode();

        System.debug('Starting execute method for: ' + this.getSObjectType());
        System.debug('Hash codes already processed: ' + hashCodesForProcessedRecords);
        System.debug('Hash code for current records: ' + this.hashCode);
        System.debug('Trigger context for current records: ' + this.currentTriggerOperation);
        System.debug('Number of current records: ' + Trigger.size);

        if(this.haveRecordsAlreadyBeenProcessed()) {
            System.debug('Records already processed for this context, skipping');
            return;
        } else {
            System.debug('Records have not been processed for this context, continuing');
        }

        SObjectTriggerOperationHandler triggerOperationHandler = getTriggerOperationHandler(this.currentTriggerOperation);
        if(triggerOperationHandler != null) {
            triggerOperationHandler.execute();
            return;
        }

        switch on this.currentTriggerOperation {
            when BEFORE_INSERT  { this.executeBeforeInsert(this.recordList); }
            when BEFORE_UPDATE  { this.executeBeforeUpdate(this.recordList, this.recordMap, this.oldRecordList, this.oldRecordMap); }
            when BEFORE_DELETE  { this.executeBeforeDelete(this.oldRecordList, this.oldRecordMap); }
            when AFTER_INSERT   { this.executeAfterInsert(this.recordList, this.recordMap); }
            when AFTER_UPDATE   { this.executeAfterUpdate(this.recordList, this.recordMap, this.oldRecordList, this.oldRecordMap); }
            when AFTER_DELETE   { this.executeAfterDelete(this.oldRecordList, this.oldRecordMap); }
            when AFTER_UNDELETE { this.executeAfterUndelete(this.recordList, this.recordMap); }
        }

        // if(Trigger.isAfter) Logger.saveLogs();
    }

    protected virtual void executeBeforeInsert(List<SObject> newRecordList) {}
    protected virtual void executeBeforeUpdate(List<SObject> updatedRecordList, Map<Id, SObject> updatedRecordMap, List<SObject> oldRecordList, Map<Id, SObject> oldRecordMap) {}
    protected virtual void executeBeforeDelete(List<SObject> deletedRecordList, Map<Id, SObject> deletedRecordMap) {}
    protected virtual void executeAfterInsert(List<SObject> newRecordList, Map<Id, SObject> newRecordMap) {}
    protected virtual void executeAfterUpdate(List<SObject> updatedRecordList, Map<Id, SObject> updatedRecordMap, List<SObject> oldRecordList, Map<Id, SObject> oldRecordMap) {}
    protected virtual void executeAfterDelete(List<SObject> deletedRecordList, Map<Id, SObject> deletedRecordMap) {}
    protected virtual void executeAfterUndelete(List<SObject> undeletedRecordList, Map<Id, SObject> undeletedRecordMap) {}

    private String getHandlerName() {
        return String.valueOf(this).split(':')[0];
    }

    private SObjectTriggerOperationHandler getTriggerOperationHandler(System.TriggerOperation triggerOperation) {
        String triggerOperationHandlerName = this.getTriggerOperationHandlerName(this.getSObjectType(), triggerOperation);
        return triggerOperationHandlersByName.get(triggerOperationHandlerName);
    }

    private String getTriggerOperationHandlerName(Schema.SObjectType sobjectType, System.TriggerOperation triggerOperation) {
        return sobjectType + '.' + triggerOperation.name();
    }

    private void validateTriggerContext() {
        if(this.isTestMode) return;

        String errorMessage = 'Trigger handler called outside of trigger execution ' + this.isTriggerExecuting;
        if(!this.isTriggerExecuting) throw new SObjectTriggerHandlerException(errorMessage);
    }

    private void setTriggerRecords() {
        this.recordList    = this.isTestMode ? this.recordList : Trigger.new;
        this.recordMap     = this.isTestMode ? this.recordMap : Trigger.newMap;
        this.oldRecordList = this.isTestMode ? this.oldRecordList : Trigger.old;
        this.oldRecordMap  = this.isTestMode ? this.oldRecordMap : Trigger.oldMap;
    }

    private Boolean shouldExecuteTriggers() {
        System.debug('SObjectTriggerHandlerSettings__c.getInstance().ExecuteTriggers__c=' + SObjectTriggerHandlerSettings__c.getInstance().ExecuteTriggers__c);

        String handlerClassesToSkipString = SObjectTriggerHandlerSettings__c.getInstance().HandlerClassesToSkip__c;
        if(handlerClassesToSkipString == null) handlerClassesToSkipString = '';
        Set<String> handlerClassesToSkip = new Set<String>(handlerClassesToSkipString.toLowerCase().split('\n'));
        System.debug('SObjectTriggerHandlerSettings__c.getInstance().HandlerClassesToSkip__c=' + SObjectTriggerHandlerSettings__c.getInstance().HandlerClassesToSkip__c);

        // If ExecuteTriggers == true and the current class isn't in the list of handlers to skip, then execute
        return SObjectTriggerHandlerSettings__c.getInstance().ExecuteTriggers__c && !handlerClassesToSkip.contains(this.getHandlerName().toLowerCase());
    }

    private void setHashCode() {
        List<SObject> recordToParseList = Trigger.new != null ? Trigger.new : Trigger.old;

        if(this.isTestMode) recordToParseList = this.recordList;

        this.hashCode = System.hashCode(recordToParseList);
    }

    private Boolean haveRecordsAlreadyBeenProcessed() {
        if(!SObjectTriggerHandlerSettings__c.getInstance().PreventRecursion__c) return false;

        // This method is a safeguard that checks to see if we have recursion problems and stops if we do
        // It allows each context to occur once for a given hash code

        if(this.currentTriggerOperation == System.TriggerOperation.BEFORE_INSERT) {
            // BEFORE_INSERT doesn't have record IDs yet, so the hash here will never match the other hashes
            // Since Salesforce makes it impossible to recursively run "insert record", we can let the platform handle it
            return false;
        } else if(!hashCodesForProcessedRecords.containsKey(this.hashCode)) {
            hashCodesForProcessedRecords.put(this.hashCode, new Set<System.TriggerOperation>{this.currentTriggerOperation});
            return false;
        } else if(!hashCodesForProcessedRecords.get(this.hashCode).contains(this.currentTriggerOperation)) {
            hashCodesForProcessedRecords.get(this.hashCode).add(this.currentTriggerOperation);
            return false;
        } else {
            return true;
        }
    }

    private class SObjectTriggerHandlerException extends Exception {}

}