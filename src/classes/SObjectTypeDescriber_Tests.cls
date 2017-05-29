@isTest
private class SObjectTypeDescriber_Tests {

    @testSetup
    static void setupData() {
        Lead lead = new Lead(
            Company  = 'My Test Company',
            LastName = 'Gillespie'
        );

        insert lead;
    }

    @isTest
    static void it_should_return_the_sobject_type_for_id() {
        Id leadId = [SELECT Id FROM Lead LIMIT 1].Id;
        Schema.SObjectType expectedSObjectType = leadId.getSobjectType();

        Test.startTest();

        SObjectTypeDescriber sobjectTypeDescriber = new SObjectTypeDescriber(leadId);
        System.assertEquals(expectedSObjectType, sobjectTypeDescriber.SObjectType);

        Test.stopTest();
    }

    @isTest
    static void it_should_return_the_sobject_type_for_record() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Schema.SObjectType expectedSObjectType = lead.getSobjectType();

        Test.startTest();

        SObjectTypeDescriber sobjectTypeDescriber = new SObjectTypeDescriber(lead);
        System.assertEquals(expectedSObjectType, sobjectTypeDescriber.SObjectType);

        Test.stopTest();
    }

    @isTest
    static void it_should_return_the_sobject_type_for_sobject_type() {
        Schema.SObjectType expectedSObjectType = Schema.Lead.SObjectType;

        Test.startTest();

        SObjectTypeDescriber sobjectTypeDescriber = new SObjectTypeDescriber(expectedSObjectType);
        System.assertEquals(expectedSObjectType, sobjectTypeDescriber.SObjectType);

        Test.stopTest();
    }

    @isTest
    static void it_should_validate_sobject_field_exists() {
        SObjectTypeDescriber sobjectTypeDescriber = new SObjectTypeDescriber(Schema.Lead.SObjectType);

        Test.startTest();

        System.assert(sobjectTypeDescriber.validateSObjectFieldExists(Schema.Lead.Id));

        Test.stopTest();
    }

    @isTest
    static void it_should_validate_sobject_field_does_not_exist() {
        SObjectTypeDescriber sobjectTypeDescriber = new SObjectTypeDescriber(Schema.Lead.SObjectType);

        Test.startTest();

        System.assert(sobjectTypeDescriber.validateSObjectFieldExists(Schema.Task.Id));

        Test.stopTest();
    }

}