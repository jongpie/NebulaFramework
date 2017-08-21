@isTest
private class SObjectFieldWrapper_Tests {
    @isTest
    static void it_should_return_string_for_sobject_field_name() {
        System.assertEquals('CreatedDate', new SObjectFieldWrapper(Lead.CreatedDate).VALUE);
    }

    @isTest
    static void it_should_return_string_for_parent_sobject_field_name() {
        System.assertEquals('Account.Name', new SObjectFieldWrapper(new List<SObjectField>{ Contact.AccountId, Account.Name }).VALUE);
    }

    @isTest
    static void it_should_be_callable_multiple_times_without_pop_removing_field_references() {
        SObjectFieldWrapper wrapper = new SObjectFieldWrapper(new List<SObjectField>{ Contact.AccountId, Account.Name });
        String expected = 'Account.Name';
        String actualOne = wrapper.VALUE;
        String actualTwo = wrapper.VALUE;
        System.assertEquals(expected, actualOne);
        System.assertEquals(expected, actualTwo);
    }
}