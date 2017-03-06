@isTest
private class SObjectTriggerHandler_Tests {

    private class LeadTriggerHandler extends SObjectTriggerHandler {
        public LeadTriggerHandler() {
            super(true);
        }
        public override void executeBeforeInsert(List<SObject> newRecordList) {
            List<Lead> newLeadList = (List<Lead>)newRecordList;

            for(Lead newLead : newLeadList) {
                this.setStatus(newLead);
            }
        }

        private void setStatus(Lead lead) {
            // Add logic here. Methods should be simple & independent from each other (except for overloaded methods)
            lead.Status = 'Open - Not Contacted';
        }
    }

    @testSetup
    static void setupData() {
        List<Lead> leadList = new List<Lead>();
        for(Integer i = 0; i < 5; i++) {
            Lead lead = new Lead(
                Company  = 'My Test Company',
                LastName = 'Gillespie'
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

        List<Lead> leadList = [SELECT Id, Status FROM Lead];

        LeadTriggerHandler leadTriggerHandler = new LeadTriggerHandler();
        leadTriggerHandler.context    = SObjectTriggerHandler.TriggerContext.BEFORE_INSERT;
        leadTriggerHandler.recordList = leadList;

        Test.startTest();

        leadTriggerHandler.execute();

        Test.stopTest();
    }

    @isTest
    static void executeAllContexts() {
        List<Lead> leadList = [SELECT Id, Status FROM Lead];

        LeadTriggerHandler leadTriggerHandler = new LeadTriggerHandler();
        leadTriggerHandler.recordList = leadList;

        Test.startTest();

        for(SObjectTriggerHandler.TriggerContext context : SObjectTriggerHandler.TriggerContext.values()) {
            leadTriggerHandler.context = context;
            leadTriggerHandler.execute();
        }

        Test.stopTest();
    }

    @isTest
    static void executeBeforeInsert() {
        List<Lead> leadList = [SELECT Id, Status FROM Lead];

        LeadTriggerHandler leadTriggerHandler = new LeadTriggerHandler();
        // Set the variables for the relevant context
        leadTriggerHandler.context    = SObjectTriggerHandler.TriggerContext.BEFORE_INSERT;
        leadTriggerHandler.recordList = leadList;

        Test.startTest();

        leadTriggerHandler.execute();

        Test.stopTest();
    }

    @isTest
    static void executeBeforeUpdate() {
        List<Lead> leadList = [SELECT Id, Status FROM Lead];

        LeadTriggerHandler leadTriggerHandler = new LeadTriggerHandler();
        // Set the variables for the relevant context
        leadTriggerHandler.context       = SObjectTriggerHandler.TriggerContext.BEFORE_UPDATE;
        leadTriggerHandler.recordList    = leadList;
        leadTriggerHandler.recordMap     = new Map<Id, Lead>(leadList);
        leadTriggerHandler.oldRecordList = leadList;
        leadTriggerHandler.oldRecordMap  = new Map<Id, Lead>(leadList);

        Test.startTest();

        leadTriggerHandler.execute();

        Test.stopTest();
    }

}