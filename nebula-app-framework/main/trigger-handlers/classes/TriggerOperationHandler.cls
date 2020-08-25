/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public abstract class TriggerOperationHandler implements ISObjectHandler {

    public abstract class BeforeInsertHandler extends TriggerOperationHandler {
        public override System.TriggerOperation getTriggerOperation() {
            return System.TriggerOperation.BEFORE_INSERT;
        }
    }

    public abstract class BeforeUpdateHandler extends TriggerOperationHandler {
        public override System.TriggerOperation getTriggerOperation() {
            return System.TriggerOperation.BEFORE_UPDATE;
        }
    }

    public abstract class BeforeDeleteHandler extends TriggerOperationHandler {
        public override System.TriggerOperation getTriggerOperation() {
            return System.TriggerOperation.BEFORE_DELETE;
        }
    }

    public abstract class AfterInsertHandler extends TriggerOperationHandler {
        public override System.TriggerOperation getTriggerOperation() {
            return System.TriggerOperation.AFTER_INSERT;
        }
    }

    public abstract class AfterUpdateHandler extends TriggerOperationHandler {
        public override System.TriggerOperation getTriggerOperation() {
            return System.TriggerOperation.AFTER_UPDATE;
        }
    }

    public abstract class AfterDeleteHandler extends TriggerOperationHandler {
        public override System.TriggerOperation getTriggerOperation() {
            return System.TriggerOperation.AFTER_DELETE;
        }
    }

    public abstract class AfterUndeleteHandler extends TriggerOperationHandler {
        public override System.TriggerOperation getTriggerOperation() {
            return System.TriggerOperation.AFTER_UNDELETE;
        }
    }

    @testVisible
    private Boolean isTriggerExecuting;
    @testVisible
    private List<SObject> recordList, oldRecordList;
    @testVisible
    private Map<Id, SObject> recordMap, oldRecordMap;

    public TriggerOperationHandler() {
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