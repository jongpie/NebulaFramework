/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class SObjectRepository_Tests {
// TODO finish tests
    private class AccountRepository extends SObjectRepository {
        // Test subclass that extends SObjectRepository
        public override Schema.SObjectType getSObjectType() {
            return Schema.Account.SObjectType;
        }

        public List<Account> getMyRecentAccounts(Integer limitCount) {
            return (List<Account>)this.Query
                .usingScope(QueryFilterScope.MINE)
                .limitCount(limitCount)
                .orderBy(Schema.Account.LastActivityDate)
                .getQueryResults();
        }

        public Account getAccountAndContactsWithEmails(Id accountId) {
            return (Account)this.Query
                .andFilterBy(NebulaFactory.getQueryFilter().setValue(Schema.Account.Id, QueryOperator.EQUALS, accountId))
                .includeChildrenRecords(
                    Schema.Contact.AccountId,
                    new List<Schema.SObjectField>{Schema.Contact.Id, Schema.Contact.Name},
                    new List<IQueryFilter>{new QueryFilter().setValue(Schema.Contact.Email, QueryOperator.NOT_EQUAL_TO, null)}
                )
                .getFirstQueryResult();
        }
    }

    private class UserRepository extends SObjectRepository {
        public override Schema.SObjectType getSObjectType() {
            return Schema.User.SObjectType;
        }

        public override void upsertRecords(SObject record, Schema.SObjectField externalIdField) {
            super.upsertRecords(record, externalIdField);
        }
    }

    static Account createAccount() {
        Account account = new Account(
            Name  = 'My Test Company'
        );
        return account;
    }

    static Contact createContact(Id accountId) {
        Contact contact = new Contact(
            AccountId = accountId,
            LastName  = 'Gillespie'
        );
        return contact;
    }

    @testSetup
    static void setupData() {
        List<Account> accountList = new List<Account>();
        for(Integer i = 0; i < 5; i++) {
            accountList.add(createAccount());
        }
        insert accountList;
    }

    @isTest
    static void it_should_instantiate_new_instance_with_fieldset() {
        // We don't want to include unnecessary metadata in this project, like custom field sets, but we still want to test functionality
        // We'll pass a null field set to make sure a field set can be used, even though the value is null
        Schema.FieldSet fieldSet;

        Test.startTest();
        SObjectRepository_Tests.AccountRepository accountRepo = new SObjectRepository_Tests.AccountRepository();
        System.assertNotEquals(null, accountRepo);
        Test.stopTest();
    }

    @isTest
    static void it_should_get_by_id_when_id() {
        Account expectedAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Account returnedAccount = (Account)new SObjectRepository_Tests.AccountRepository().getById(expectedAccount.Id);
        Test.stopTest();

        System.assertEquals(expectedAccount.Id, returnedAccount.Id);
    }

    @isTest
    static void it_should_get_by_id_using_query_filter() {
        Account expectedAccount = [SELECT Id FROM Account LIMIT 1];
        IQueryFilter queryFilter = NebulaFactory.getQueryFilter().setValue(Schema.Account.Id, QueryOperator.EQUALS, expectedAccount.Id);

        Test.startTest();
        Account returnedAccount = ((List<Account>)new SObjectRepository_Tests.AccountRepository().get(queryFilter))[0];
        Test.stopTest();

        System.assertEquals(expectedAccount.Id, returnedAccount.Id);
    }

    @isTest
    static void it_should_get_by_id_using_list_of_query_filters() {
        Account expectedAccount = [SELECT Id FROM Account LIMIT 1];
        IQueryFilter queryFilter = NebulaFactory.getQueryFilter().setValue(Schema.Account.Id, QueryOperator.EQUALS, expectedAccount.Id);

        Test.startTest();
        Account returnedAccount = ((List<Account>)new SObjectRepository_Tests.AccountRepository().get(new List<IQueryFilter>{queryFilter}))[0];
        Test.stopTest();

        System.assertEquals(expectedAccount.Id, returnedAccount.Id);
    }

    @isTest
    static void it_should_get_by_id_when_list_of_id() {
        Map<Id, Account> expectedAccountList = new Map<Id, Account>([SELECT Id FROM Account]);

        Test.startTest();
        List<Account> returnedAccountList = (List<Account>)new SObjectRepository_Tests.AccountRepository().getById(new List<Id>(expectedAccountList.keySet()));
        Test.stopTest();

        System.assertNotEquals(null, expectedAccountList);
        System.assert(!expectedAccountList.isEmpty());
        System.assertEquals(expectedAccountList.size(), returnedAccountList.size());
    }

    @isTest
    static void it_should_return_my_recent_accounts() {
        List<Account> expectedAccountList = [SELECT Id FROM Account LIMIT 2];

        Test.startTest();
        List<Account> returnedAccountList = new SObjectRepository_Tests.AccountRepository().getMyRecentAccounts(expectedAccountList.size());
        Test.stopTest();

        System.assertNotEquals(null, expectedAccountList);
        System.assert(!expectedAccountList.isEmpty());
        System.assertEquals(expectedAccountList.size(), returnedAccountList.size());
    }

    @isTest
    static void it_should_return_for_ids_in_set_and_query_filters() {
        Map<Id, Account> expectedAccountMap = new Map<Id, Account>([SELECT Id FROM Account]);
        ISObjectRepository repo = new SObjectRepository_Tests.AccountRepository();

        Test.startTest();
        IQueryFilter queryFilter = NebulaFactory.getQueryFilter().setValue(Schema.Account.Name, QueryOperator.EQUALS, 'My Test Company');
        List<IQueryFilter> queryFilters = new List<IQueryFilter>{queryFilter};
        List<Account> returnedAccountList = (List<Account>)repo.getByIdAndQueryFilters(expectedAccountMap.keyset(), queryFilters);
        Test.stopTest();

        System.assertNotEquals(null, expectedAccountMap);
        System.assert(!expectedAccountMap.isEmpty());
        System.assertEquals(expectedAccountMap.size(), returnedAccountList.size());
    }

    @isTest
    static void it_should_return_by_field_for_ids_in_list() {
        Map<Id, Account> expectedAccountMap = new Map<Id, Account>([SELECT Id FROM Account]);
        List<Schema.SObjectField> accountFields = new List<Schema.SObjectField>{Schema.Account.Id, Schema.Account.Name};
        ISObjectRepository repo = new SObjectRepository_Tests.AccountRepository();

        Test.startTest();
        IQueryFilter queryFilter = NebulaFactory.getQueryFilter().setValue(Schema.Account.Name, QueryOperator.EQUALS, 'My Test Company');
        List<IQueryFilter> queryFilters = new List<IQueryFilter>{queryFilter};
        List<Account> returnedAccountList = (List<Account>)repo.getByIdAndQueryFilters(new List<Id>(expectedAccountMap.keyset()), queryFilters);
        Test.stopTest();

        System.assertNotEquals(null, expectedAccountMap);
        System.assert(!expectedAccountMap.isEmpty());
        System.assertEquals(expectedAccountMap.size(), returnedAccountList.size());
    }

    @isTest
    static void it_should_return_account_and_contacts_as_children_records() {
        Account account = [SELECT Id FROM Account LIMIT 1];

        Contact contact = createContact(account.Id);
        contact.Email = 'test@email.com';
        insert contact;
        contact = [SELECT Id, AccountId FROM Contact WHERE Id = :contact.Id];
        System.assertEquals(account.Id, contact.AccountId);

        Account expectedAccount = [
            SELECT Id, (SELECT Id, AccountId FROM Contacts WHERE Email != null)
            FROM Account
            WHERE Id = :account.Id
        ];
        System.assertEquals(1, expectedAccount.Contacts.size());

        Test.startTest();
        // Make sure that we have 0 queries used so far
        System.assertEquals(0, Limits.getQueries());

        account = new SObjectRepository_Tests.AccountRepository().getAccountAndContactsWithEmails(account.Id);

        // Make sure that the account & contact query only counts as a singlequery
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

        System.assertEquals(expectedAccount.Contacts.size(), account.Contacts.size());
        Contact firstContact = account.Contacts[0];
        System.assertEquals(contact.Id, firstContact.Id);
    }

    @isTest
    static void it_should_search_for_search_term() {
        String searchTerm = 'Gillespie';
        Map<Id, Account> soslAccountMap = new Map<Id, Account>([SELECT Id, Name, OwnerId, Owner.Name FROM Account]);
        Test.setFixedSearchResults(new List<Id>(soslAccountMap.keySet()));

        List<Account> expectedAccountList = [FIND :searchTerm IN ALL FIELDS RETURNING Account(Id, Name)][0];
        System.assertNotEquals(0, expectedAccountList.size());

        Test.startTest();
        List<Account> returnedAccountList = (List<Account>)new SObjectRepository_Tests.AccountRepository().getSearchResults(searchTerm);
        Test.stopTest();

        System.assertNotEquals(null, expectedAccountList);
        System.assert(!expectedAccountList.isEmpty());
        System.assertEquals(expectedAccountList.size(), returnedAccountList.size());
    }

    @isTest
    static void it_should_search_for_search_term_and_search_group() {
        String searchTerm = 'Gillespie';
        Map<Id, Account> soslAccountMap = new Map<Id, Account>([SELECT Id, Name, OwnerId, Owner.Name FROM Account]);
        Test.setFixedSearchResults(new List<Id>(soslAccountMap.keySet()));

        List<Account> expectedAccountList = [FIND :searchTerm IN ALL FIELDS RETURNING Account(Id, Name)][0];
        System.assertNotEquals(0, expectedAccountList.size());

        Test.startTest();
        List<Account> returnedAccountList = (List<Account>)new SObjectRepository_Tests.AccountRepository().getSearchResults(searchTerm, QuerySearchGroup.NAME_FIELDS);
        Test.stopTest();

        System.assertNotEquals(null, expectedAccountList);
        System.assert(!expectedAccountList.isEmpty());
        System.assertEquals(expectedAccountList.size(), returnedAccountList.size());
    }

    @isTest
    static void it_should_search_for_search_term_and_search_group_and_query_filters() {
        String searchTerm = 'Gillespie';
        Map<Id, Account> soslAccountMap = new Map<Id, Account>([SELECT Id, Name, OwnerId, Owner.Name FROM Account]);
        Test.setFixedSearchResults(new List<Id>(soslAccountMap.keySet()));

        List<Account> expectedAccountList = [FIND :searchTerm IN ALL FIELDS RETURNING Account(Id, Name)][0];
        System.assertNotEquals(0, expectedAccountList.size());

        Test.startTest();
        IQueryFilter queryFilter = NebulaFactory.getQueryFilter().setValue(Schema.Account.CreatedDate, QueryOperator.EQUALS, QueryDateLiteral.TODAY);
        List<IQueryFilter> queryFilters = new List<IQueryFilter>{queryFilter};
        List<Account> returnedAccountList = (List<Account>)new SObjectRepository_Tests.AccountRepository().getSearchResults(searchTerm, QuerySearchGroup.NAME_FIELDS, queryFilters);
        Test.stopTest();

        System.assertNotEquals(null, expectedAccountList);
        System.assert(!expectedAccountList.isEmpty());
        System.assertEquals(expectedAccountList.size(), returnedAccountList.size());
    }

    @isTest
    static void it_should_insert_a_single_record() {
        Account account = createAccount();
        System.assertEquals(null, account.Id);

        Test.startTest();
        new SObjectRepository_Tests.AccountRepository().insertRecords(account);
        Test.stopTest();

        System.assertNotEquals(null, account.Id);

        List<Account> queriedAccountList = [SELECT Id FROM Account WHERE Id = :account.Id];
        System.assertEquals(1, queriedAccountList.size());
        System.assertEquals(queriedAccountList[0].Id, account.Id);
    }

    @isTest
    static void it_should_update_a_single_record() {
        Account existingAccount = [SELECT Id, LastModifiedDate FROM Account LIMIT 1];
        Datetime originalLastModifiedDate = existingAccount.LastModifiedDate;

        Test.startTest();
        new SObjectRepository_Tests.AccountRepository().updateRecords(existingAccount);
        Test.stopTest();

        existingAccount = [SELECT Id, LastModifiedDate FROM Account LIMIT 1];
        System.assert(existingAccount.LastModifiedDate > originalLastModifiedDate, existingAccount);
    }

    @isTest
    static void it_should_upsert_a_single_new_record() {
        Account newAccount = createAccount();
        System.assertEquals(null, newAccount.Id);

        Test.startTest();
        new SObjectRepository_Tests.AccountRepository().upsertRecords(newAccount);
        Test.stopTest();

        System.assertNotEquals(null, newAccount.Id);
    }

    @isTest
    static void it_should_upsert_a_single_existing_record() {
        Account existingAccount = [SELECT Id, LastModifiedDate FROM Account LIMIT 1];
        Datetime originalLastModifiedDate = existingAccount.LastModifiedDate;

        Test.startTest();
        new SObjectRepository_Tests.AccountRepository().upsertRecords(existingAccount);
        Test.stopTest();

        existingAccount = [SELECT Id, LastModifiedDate FROM Account LIMIT 1];
        System.assert(existingAccount.LastModifiedDate > originalLastModifiedDate, existingAccount);
    }

    @isTest
    static void it_should_upsert_a_single_existing_record_with_external_id() {
        User existingUser = [SELECT Id, LastModifiedDate, Username FROM User WHERE Id = :UserInfo.getUserId()];
        Datetime originalLastModifiedDate = existingUser.LastModifiedDate;
        System.assertNotEquals(null, existingUser.Username);

        Test.startTest();
        new SObjectRepository_Tests.UserRepository().upsertRecords(existingUser, Schema.User.Username);
        Test.stopTest();

        existingUser = [SELECT Id, LastModifiedDate FROM User LIMIT 1];
        System.assert(existingUser.LastModifiedDate > originalLastModifiedDate, existingUser);
    }

    @isTest
    static void it_should_delete_a_single_record() {
        Account existingAccount = [SELECT Id, IsDeleted FROM Account LIMIT 1];
        System.assertEquals(false, existingAccount.IsDeleted);

        Test.startTest();
        new SObjectRepository_Tests.AccountRepository().deleteRecords(existingAccount);
        Test.stopTest();

        existingAccount = [SELECT Id, IsDeleted FROM Account WHERE Id = :existingAccount.Id ALL ROWS];
        System.assertEquals(true, existingAccount.IsDeleted);
    }

    @isTest
    static void it_should_hard_delete_a_single_record() {
        Account existingAccount = [SELECT Id, IsDeleted FROM Account LIMIT 1];
        System.assertEquals(false, existingAccount.IsDeleted);

        Test.startTest();
        new SObjectRepository_Tests.AccountRepository().hardDeleteRecords(existingAccount);
        Test.stopTest();

        List<Account> existingAccountList = [SELECT Id, IsDeleted FROM Account WHERE Id = :existingAccount.Id ALL ROWS];
        System.assert(existingAccountList[0].IsDeleted);
    }

    @isTest
    static void it_should_undelete_a_single_record() {
        Account existingAccount = [SELECT Id, IsDeleted FROM Account LIMIT 1];
        System.assertEquals(false, existingAccount.IsDeleted);

        delete existingAccount;

        existingAccount = [SELECT Id, IsDeleted FROM Account WHERE Id = :existingAccount.Id ALL ROWS];
        System.assertEquals(true, existingAccount.IsDeleted);

        Test.startTest();
        new SObjectRepository_Tests.AccountRepository().undeleteRecords(existingAccount);
        Test.stopTest();

        existingAccount = [SELECT Id, IsDeleted FROM Account WHERE Id = :existingAccount.Id ALL ROWS];
        System.assertEquals(false, existingAccount.IsDeleted);
    }

}