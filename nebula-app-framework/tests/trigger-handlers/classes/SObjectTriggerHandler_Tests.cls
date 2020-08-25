/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class SObjectTriggerHandler_Tests {

    private class LeadTriggerHandlerTest extends SObjectTriggerHandler {
        public LeadTriggerHandlerTest() {
            super(true);
        }
        public override void executeBeforeInsert(List<SObject> newRecordList) {
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

    static void setupData() {
        for(Integer i = 0; i < 5; i++) {
            Lead lead = new Lead(
                Company  = 'My Test Company',
                LastName = 'Gillespie',
                Status = ''
            );
            leadList.add(lead);
        }
        insert leadList;
    }

    @isTest
    static void shouldNotExecuteTriggers() {
        TriggerHandlerSettings__c triggerHandlerSettings = TriggerHandlerSettings__c.getInstance();
        triggerHandlerSettings.ExecuteTriggers__c = false;
        upsert triggerHandlerSettings;

        LeadTriggerHandlerTest leadTriggerHandler = new LeadTriggerHandlerTest();
        leadTriggerHandler.currentTriggerContext  = SObjectTriggerHandler.TriggerContext.BEFORE_INSERT;
        leadTriggerHandler.recordList = leadList;

        Test.startTest();

        leadTriggerHandler.execute();

        Test.stopTest();
    }

    // @isTest
    // static void executeAllContexts() {
    //     setupData();
    //     LeadTriggerHandlerTest leadTriggerHandler = new LeadTriggerHandlerTest();
    //     leadTriggerHandler.recordList = leadList;

    //     Test.startTest();
    //     for(SObjectTriggerHandler.TriggerContext context : SObjectTriggerHandler.TriggerContext.values()) {
    //         leadTriggerHandler.currentTriggerContext = context;
    //         leadTriggerHandler.execute();
    //     }
    //     Test.stopTest();
    // }

    // @isTest
    // static void executeBeforeInsert() {
    //     LeadTriggerHandlerTest leadTriggerHandler = new LeadTriggerHandlerTest();
    //     // Set the variables for the relevant context
    //     leadTriggerHandler.currentTriggerContext = SObjectTriggerHandler.TriggerContext.BEFORE_INSERT;
    //     leadTriggerHandler.recordList = leadList;

    //     Test.startTest();

    //     leadTriggerHandler.execute();

    //     Test.stopTest();
    // }

    // @isTest
    // static void executeBeforeUpdate() {
    //     LeadTriggerHandlerTest leadTriggerHandler = new LeadTriggerHandlerTest();
    //     // Set the variables for the relevant context
    //     leadTriggerHandler.currentTriggerContext = SObjectTriggerHandler.TriggerContext.BEFORE_UPDATE;
    //     leadTriggerHandler.recordList            = leadList;
    //     leadTriggerHandler.recordMap             = new Map<Id, Lead>(leadList);
    //     leadTriggerHandler.oldRecordList         = leadList;
    //     leadTriggerHandler.oldRecordMap          = new Map<Id, Lead>(leadList);

    //     Test.startTest();

    //     leadTriggerHandler.execute();

    //     Test.stopTest();
    // }

}