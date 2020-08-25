/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public abstract class SObjectTriggerOperationHandler implements ISObjectHandler {

    @testVisible
    private Boolean isTriggerExecuting;
    @testVisible
    private List<SObject> recordList, oldRecordList;
    @testVisible
    private Map<Id, SObject> recordMap, oldRecordMap;

    public SObjectTriggerOperationHandler() {
        this.isTriggerExecuting = Trigger.isExecuting;
        this.recordList         = Trigger.new;
        this.recordMap          = Trigger.newMap;
        this.oldRecordList      = Trigger.old;
        this.oldRecordMap       = Trigger.oldMap;
    }

    public abstract Schema.SObjectType getSObjectType();
    public abstract System.TriggerOperation getTriggerOperation();
    public abstract void execute();

    public List<SObject> getRecordList() {
        return this.recordList;
    }

    public Map<Id, SObject> getRecordMap() {
        return this.recordMap;
    }

    public List<SObject> getOldRecordList() {
        return this.oldRecordList;
    }

    public Map<Id, SObject> getOldRecordMap() {
        return this.oldRecordMap;
    }

}