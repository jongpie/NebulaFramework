@isTest
private class QueryField_Tests {

    @isTest
    static void it_should_return_string_for_sobject_field_name() {
        System.assertEquals('CreatedDate', new QueryField(Schema.Lead.CreatedDate).getValue());
    }

    @isTest
    static void it_should_return_string_for_parent_sobject_field_name() {
        List<SObjectField> fieldChain = new List<SObjectField>{
            Schema.Contact.AccountId, Schema.Account.CreatedById, Schema.User.Name
        };
        System.assertEquals('Account.CreatedBy.Name', new QueryField(fieldChain).getValue());
    }

    @isTest
    static void it_should_be_callable_multiple_times_without_pop_removing_field_references() {
        List<SObjectField> fieldChain = new List<SObjectField>{
            Schema.Contact.AccountId, Schema.Account.Name
        };
        QueryField queryField = new QueryField(fieldChain);
        String expected = 'Account.Name';
        for(Integer i = 0; i < 5; i++) {
            System.assertEquals(expected, queryField.getValue());
        }
    }

}