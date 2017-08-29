/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class SObjectFieldDescriber_Tests {

    @isTest
    static void it_should_return_the_sobject_type() {
        Schema.SObjectType expectedSObjectType = Schema.Lead.SObjectType;
        Schema.SObjectField sobjectField = Schema.Lead.Id;

        Test.startTest();

        SObjectFieldDescriber sobjectFieldDescriber = new SObjectFieldDescriber(sobjectField);
        System.assertEquals(expectedSObjectType, sobjectFieldDescriber.getSObjectType());

        Test.stopTest();
    }

    @isTest
    static void it_should_validate_the_expected_sobject_type() {
        Schema.SObjectType expectedSObjectType = Schema.Lead.SObjectType;
        Schema.SObjectField sobjectField = Schema.Lead.Id;

        Test.startTest();

        SObjectFieldDescriber sobjectFieldDescriber = new SObjectFieldDescriber(sobjectField);
        System.assert(sobjectFieldDescriber.validateSObjectType(expectedSObjectType));

        Test.stopTest();
    }

    @isTest
    static void it_should_return_the_full_field_name() {
        Schema.SObjectType expectedSObjectType = Schema.Lead.SObjectType;
        Schema.SObjectField sobjectField = Schema.Lead.Id;
        String expectedFullFieldName = String.valueOf(expectedSObjectType) + '.' + String.valueOf(sobjectField);

        Test.startTest();

        SObjectFieldDescriber sobjectFieldDescriber = new SObjectFieldDescriber(sobjectField);
        System.assertEquals(expectedFullFieldName, sobjectFieldDescriber.getFullFieldName());

        Test.stopTest();
    }

    @isTest
    static void it_should_return_the_parent_field_sobject_type() {
        Schema.SObjectField sobjectField = Schema.Lead.ConvertedAccountId;
        Schema.SObjectType expectedParentSObjectType = Schema.Account.SObjectType;

        Test.startTest();

        SObjectFieldDescriber sobjectFieldDescriber = new SObjectFieldDescriber(sobjectField);
        System.assertEquals(expectedParentSObjectType, sobjectFieldDescriber.getParentSObjectType());

        Test.stopTest();
    }

}