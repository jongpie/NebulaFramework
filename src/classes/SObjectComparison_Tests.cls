@isTest
private class SObjectComparison_Tests {

    static Account createAccount() {
        return new Account(
            Name  = 'My Test Company'
        );
    }

    static Contact createContact() {
        return new Contact(
            Email    = 'test@contact.com',
            LastName = 'Gillespie'
        );
    }

    @isTest
    static void it_should_throw_an_exception_for_different_sobject_types() {
        Account account = createAccount();
        Contact contact = createContact();

        try {
            new SObjectComparison(account, contact);
            System.assert(false, 'An exception is expected here');
        } catch(Exception e) {
            System.assert(e instanceOf SObjectComparison.SObjectComparisonException);
            String expectedErrorMessage = 'Records must be the same type of SObject';
            System.assert(e.getMessage().contains(expectedErrorMessage));
        }
    }

    @isTest
    static void it_should_throw_an_exception_for_different_records() {
        Account account1 = createAccount();
        account1.Id = TestingUtils.generateId(Schema.Account.SObjectType);
        Account account2 = (Account)TestSObjectBuilder.getTestAccountBuilder().build();
        account2.Id = TestingUtils.generateId(Schema.Account.SObjectType);

        // Verify that the test IDs have been set and are different
        System.assertNotEquals(null, account1.Id);
        System.assertNotEquals(null, account2.Id);
        System.assertNotEquals(account1.Id, account2.Id);

        try {
            new SObjectComparison(account1, account2);
            System.assert(false, 'An exception is expected here');
        } catch(Exception e) {
            System.assert(e instanceOf SObjectComparison.SObjectComparisonException);
            String expectedErrorMessage = 'Records must have the same ID';
            System.assert(e.getMessage().contains(expectedErrorMessage));
        }
    }

    @isTest
    static void it_should_return_a_set_of_changed_fields_when_a_field_has_changed() {
        Account account = createAccount();
        Account originalAccount = account.clone(true, true, true, true);

        // Change the name
        account.Name = 'My New Name';
        System.assertNotEquals(account.Name, originalAccount.Name);

        // Change the account number
        account.AccountNumber = '123';
        System.assertNotEquals(account.AccountNumber, originalAccount.AccountNumber);

        SObjectComparison sobjectComparison = new SObjectComparison(account, originalAccount);

        Test.startTest();

        // Verify that the 2 changed fields are the only fields included in the returned set
        Set<Schema.SObjectField> changedFields = sobjectComparison.getChangedFields();
        System.assertEquals(2, changedFields.size());
        System.assert(changedFields.contains(Schema.Account.AccountNumber));
        System.assert(changedFields.contains(Schema.Account.Name));

        Test.stopTest();
    }

    @isTest
    static void it_should_return_an_empty_set_of_changed_fields_when_no_field_has_changed() {
        Account account = createAccount();
        Account originalAccount = account.clone(true, true, true, true);

        SObjectComparison sobjectComparison = new SObjectComparison(account, originalAccount);

        Test.startTest();

        // Verify that the 2 changed fields are the only fields included in the returned set
        Set<Schema.SObjectField> changedFields = sobjectComparison.getChangedFields();
        System.assertNotEquals(null, changedFields);
        System.assert(changedFields.isEmpty());

        Test.stopTest();
    }

    @isTest
    static void it_should_return_true_when_any_populated_field_has_changed() {
        Account account = createAccount();
        Account originalAccount = account.clone(true, true, true, true);
        account.Name = 'My New Name';
        System.assertNotEquals(account.Name, originalAccount.Name);

        SObjectComparison sobjectComparison = new SObjectComparison(account, originalAccount);

        Test.startTest();

        Boolean hasAnyFieldChanged = sobjectComparison.hasAnyFieldChanged();
        System.assertEquals(true, hasAnyFieldChanged);

        Test.stopTest();
    }

    @isTest
    static void it_should_return_false_when_no_populated_field_has_changed() {
        Account account = createAccount();
        Account originalAccount = account.clone(true, true, true, true);

        SObjectComparison sobjectComparison = new SObjectComparison(account, originalAccount);

        Test.startTest();

        Boolean hasAnyFieldChanged = sobjectComparison.hasAnyFieldChanged();
        System.assertEquals(false, hasAnyFieldChanged);

        Test.stopTest();
    }

    @isTest
    static void it_should_return_true_when_any_field_in_set_has_changed() {
        Set<Schema.SObjectField> fieldsToChange = new Set<Schema.SObjectField>{
            Schema.Account.AccountNumber, Schema.Account.AccountSource, Schema.Account.Name
        };

        Account account = createAccount();
        Account originalAccount = account.clone(true, true, true, true);

        account.Name = 'My New Name';
        System.assert(fieldsToChange.contains(Schema.Account.Name));
        System.assertNotEquals(account.Name, originalAccount.Name);

        SObjectComparison sobjectComparison = new SObjectComparison(account, originalAccount);

        Test.startTest();

        // Verify that a field in the set causes it to return true
        Boolean hasAnyFieldChanged = sobjectComparison.hasAnyFieldChanged(fieldsToChange);
        System.assertEquals(true, hasAnyFieldChanged);

        Test.stopTest();
    }


    @isTest
    static void it_should_return_false_when_no_field_in_set_has_changed() {
        Set<Schema.SObjectField> fieldsToChange = new Set<Schema.SObjectField>{
            Schema.Account.AccountNumber, Schema.Account.AccountSource, Schema.Account.Name
        };

        Account account = createAccount();
        Account originalAccount = account.clone(true, true, true, true);

        SObjectComparison sobjectComparison = new SObjectComparison(account, originalAccount);

        Test.startTest();

        // Verify that a field in the set causes it to return true
        Boolean hasAnyFieldChanged = sobjectComparison.hasAnyFieldChanged(fieldsToChange);
        System.assertEquals(false, hasAnyFieldChanged);

        Test.stopTest();
    }

    @isTest
    static void it_should_return_true_when_any_field_in_list_has_changed() {
        List<Schema.SObjectField> fieldsToChange = new List<Schema.SObjectField>{
            Schema.Account.AccountNumber, Schema.Account.AccountSource, Schema.Account.Name
        };

        Account account = createAccount();
        Account originalAccount = account.clone(true, true, true, true);

        account.Name = 'My New Name';
        System.assertNotEquals(account.Name, originalAccount.Name);

        Test.startTest();

        // Verify that a field in the set causes it to return true
        SObjectComparison sobjectComparison = new SObjectComparison(account, originalAccount);
        Boolean hasAnyFieldChanged = sobjectComparison.hasAnyFieldChanged(fieldsToChange);
        System.assertEquals(true, hasAnyFieldChanged);

        Test.stopTest();
    }

    @isTest
    static void it_should_return_false_when_no_field_in_list_has_changed() {
        List<Schema.SObjectField> fieldsToChange = new List<Schema.SObjectField>{
            Schema.Account.AccountNumber, Schema.Account.AccountSource, Schema.Account.Name
        };

        Account account = createAccount();
        Account originalAccount = account.clone(true, true, true, true);

        SObjectComparison sobjectComparison = new SObjectComparison(account, originalAccount);

        Test.startTest();

        // Verify that a field in the set causes it to return true
        Boolean hasAnyFieldChanged = sobjectComparison.hasAnyFieldChanged(fieldsToChange);
        System.assertEquals(false, hasAnyFieldChanged);

        Test.stopTest();
    }

}