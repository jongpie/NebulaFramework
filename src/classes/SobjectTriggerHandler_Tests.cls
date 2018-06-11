/********************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.                    *
* See LICENSE file or go to https://github.com/jongpie/NebulaTriggerFramework for full license details. *
********************************************************************************************************/
@isTest
private class SobjectTriggerHandler_Tests {

    private class LeadTriggerHandlerTest extends SobjectTriggerHandler {

        public LeadTriggerHandlerTest() {
            super(true);
        }

        public override void executeBeforeInsert(List<Sobject> newRecordList) {
            List<Lead> newLeadList = (List<Lead>)this.recordList;

            for(Lead newLead : newLeadList) {
                this.setStatus(newLead);
            }
        }

        private void setStatus(Lead lead) {
            // Add logic here. Methods should be simple & independent from each other (except for overloaded methods)
            lead.Status = 'Open - Not Contacted';
        }

    }

    static List<Lead> leadList = new List<Lead>();

    @testSetup
    static void setupData() {
        upsert SobjectTriggerHandlerSettings__c.getInstance();

        for(Integer i = 0; i < 5; i++) {
            Lead lead = (Lead)new TestDataFactory(new Lead()).populateRequiredFields();
            leadList.add(lead);
        }
        insert leadList;
    }

    @isTest
    static void it_should_not_execute_triggers_when_disabled() {
        SobjectTriggerHandlerSettings__c triggerHandlerSettings = SobjectTriggerHandlerSettings__c.getInstance();
        triggerHandlerSettings.ExecuteTriggers__c = false;
        upsert triggerHandlerSettings;

        LeadTriggerHandlerTest leadTriggerHandler = new LeadTriggerHandlerTest();
        leadTriggerHandler.currentTriggerOperation = TriggerOperation.BEFORE_INSERT;
        leadTriggerHandler.recordList = leadList;

        Test.startTest();

        leadTriggerHandler.execute();

        Test.stopTest();
    }

    @isTest
    static void it_should_execute_all_trigger_operations_when_enabled() {
        setupData();
        LeadTriggerHandlerTest leadTriggerHandler = new LeadTriggerHandlerTest();
        leadTriggerHandler.recordList = leadList;

        Test.startTest();
        for(TriggerOperation triggerOperation : TriggerOperation.values()) {
            leadTriggerHandler.currentTriggerOperation = triggerOperation;
            leadTriggerHandler.execute();
        }
        Test.stopTest();
    }

}