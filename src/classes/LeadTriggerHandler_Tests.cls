@isTest
private class LeadTriggerHandler_Tests {

    @isTest
    static void setStatus_Test() {
        // All methods within the handler class (LeadTriggerHandler()) are protected or private, except for the exceute(), inherited from TriggerHandler.cls
        // Your unit tests should test the outcome of your handler's classes methods.
        // This lets you refactor your handler class at any point without any major dependencies since no variables or methods are public or global
        // As long as your unit tests are THOROUGH, you can refactor your handler class as you see fit with confidence (as long as the tests still pass after you refactor)

        // Create test data that should trigger (ha!) your method to run
        Lead lead = new Lead(
            Company    = 'My Test Company',
            LastName   = 'Gillespie',
            LeadSource = 'Web',
            Status     = 'Closed'
        );
        // The test never calls LeadTriggerHandler - we let the Force.com platform handle executing the handler class
        insert lead;

        Test.startTest();

        // If we setup our test correctly, then the handler class's setStatus() method should have updated the test lead
        // Let's requery the lead so we can assert that the desired changes occurred
        lead = [SELECT Id, LeadSource, Status FROM Lead WHERE Id = :lead.Id];
        // Add asserts liberally like your life depends on it
        System.assertEquals('Web', lead.LeadSource);
        System.assertEquals('Open - Not Contacted', lead.Status);

        Test.stopTest();
    }

}