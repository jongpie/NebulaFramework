/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class SobjectRepository_Tests {

    private class AccountRepository extends SobjectRepository {
        // Test subclass that extends SobjectRepository
        public override Schema.SobjectType getSobjectType() {
            return Schema.Account.SobjectType;
        }

        public List<Account> getMyRecentAccounts(Integer limitCount) {
            return (List<Account>)new Soql(this.getSobjectType())
                .usingScope(Soql.Scope.MINE)
                .limitCount(limitCount)
                .orderBy(new Soql.QueryField(Schema.Account.LastActivityDate))
                .getQueryResults();
        }

        // TODO reintroduce includeChildrenRecords method
        /*public Account getAccountAndContactsWithEmails(Id accountId) {
            return (Account)new Soql(this.getSobjectType())
                .filterBy(new Soql.QueryFilter(new Soql.QueryField(Schema.Account.Id), '=', accountId))
                .includeChildrenRecords(
                    Schema.Contact.AccountId,
                    new Soql(Schema.Contact.SobjectType)
                        .addAllStandardFields()
                        .filterBy(new Soql.QueryFilter(new Soql.QueryField(Schema.Contact.Email), '!=', null))
                )
                .getFirstQueryResult();
        }*/
    }

    private class UserRepository extends SobjectRepository {
        public override Schema.SobjectType getSobjectType() {
            return Schema.User.SobjectType;
        }

        public override List<Database.UpsertResult> upsertRecords(Sobject record, Schema.SobjectField externalIdField) {
            return super.upsertRecords(record, externalIdField);
        }
    }

    @testSetup
    static void setupData() {
        List<Account> accountList = new List<Account>();
        for(Integer i = 0; i < 5; i++) {
            accountList.add((Account)new TestDataFactory(new Account()).populateRequiredFields());
        }
        insert accountList;
    }

    @isTest
    static void it_should_instantiate_new_instance_with_fieldset() {
        // We don't want to include unnecessary metadata in this project, like custom field sets, but we still want to test functionality
        // We'll pass a null field set to make sure a field set can be used, even though the value is null
        Schema.FieldSet fieldSet;

        Test.startTest();
        SobjectRepository_Tests.AccountRepository accountRepo = new SobjectRepository_Tests.AccountRepository();
        System.assertNotEquals(null, accountRepo);
        Test.stopTest();
    }

    @isTest
    static void it_should_get_by_id_when_id() {
        Account expectedAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Account returnedAccount = (Account)new SobjectRepository_Tests.AccountRepository().get(expectedAccount.Id);
        Test.stopTest();

        System.assertEquals(expectedAccount.Id, returnedAccount.Id);
    }

    @isTest
    static void it_should_get_by_id_using_query_filter() {
        Account expectedAccount = [SELECT Id FROM Account LIMIT 1];
        Soql.QueryFilter queryFilter = new Soql.QueryFilter(new Soql.QueryField(Schema.Account.Id), '=', expectedAccount.Id);

        Test.startTest();
        Account returnedAccount = ((List<Account>)new SobjectRepository_Tests.AccountRepository().get(queryFilter))[0];
        Test.stopTest();

        System.assertEquals(expectedAccount.Id, returnedAccount.Id);
    }

    @isTest
    static void it_should_get_by_id_using_list_of_query_filters() {
        Account expectedAccount = [SELECT Id FROM Account LIMIT 1];
        Soql.QueryFilter queryFilter = new Soql.QueryFilter(new Soql.QueryField(Schema.Account.Id), '=', expectedAccount.Id);

        Test.startTest();
        Account returnedAccount = ((List<Account>)new SobjectRepository_Tests.AccountRepository().get(new List<Soql.QueryFilter>{queryFilter}))[0];
        Test.stopTest();

        System.assertEquals(expectedAccount.Id, returnedAccount.Id);
    }

    @isTest
    static void it_should_get_by_id_when_list_of_id() {
        Map<Id, Account> expectedAccountList = new Map<Id, Account>([SELECT Id FROM Account]);

        Test.startTest();
        List<Account> returnedAccountList = (List<Account>)new SobjectRepository_Tests.AccountRepository().get(new List<Id>(expectedAccountList.keySet()));
        Test.stopTest();

        System.assertNotEquals(null, expectedAccountList);
        System.assert(!expectedAccountList.isEmpty());
        System.assertEquals(expectedAccountList.size(), returnedAccountList.size());
    }

    @isTest
    static void it_should_return_my_recent_accounts() {
        List<Account> expectedAccountList = [SELECT Id FROM Account LIMIT 2];

        Test.startTest();
        List<Account> returnedAccountList = new SobjectRepository_Tests.AccountRepository().getMyRecentAccounts(expectedAccountList.size());
        Test.stopTest();

        System.assertNotEquals(null, expectedAccountList);
        System.assert(!expectedAccountList.isEmpty());
        System.assertEquals(expectedAccountList.size(), returnedAccountList.size());
    }

    @isTest
    static void it_should_return_for_ids_in_set_and_query_filters() {
        Map<Id, Account> expectedAccountMap = new Map<Id, Account>([SELECT Id FROM Account]);
        ISobjectRepository repo = new SobjectRepository_Tests.AccountRepository();

        Test.startTest();
        Soql.QueryFilter queryFilter = new Soql.QueryFilter(new Soql.QueryField(Schema.Account.Name), '=', 'Test string for String');
        List<Soql.QueryFilter> queryFilters = new List<Soql.QueryFilter>{queryFilter};
        List<Account> returnedAccountList = (List<Account>)repo.get(expectedAccountMap.keyset(), queryFilters);
        Test.stopTest();

        System.assertNotEquals(null, expectedAccountMap);
        System.assert(!expectedAccountMap.isEmpty());
        System.assertEquals(expectedAccountMap.size(), returnedAccountList.size());
    }

    @isTest
    static void it_should_return_by_field_for_ids_in_list() {
        Map<Id, Account> expectedAccountMap = new Map<Id, Account>([SELECT Id FROM Account ]);
        List<Schema.SobjectField> accountFields = new List<Schema.SobjectField>{Schema.Account.Id, Schema.Account.Name};
        ISobjectRepository repo = new SobjectRepository_Tests.AccountRepository();

        Test.startTest();
        Soql.QueryFilter queryFilter = new Soql.QueryFilter(Schema.Account.Name, '=', 'Test string for String');
        List<Soql.QueryFilter> queryFilters = new List<Soql.QueryFilter>{queryFilter};
        List<Account> returnedAccountList = (List<Account>)repo.get(new List<Id>(expectedAccountMap.keyset()), queryFilters);
        Test.stopTest();

        System.assertNotEquals(null, expectedAccountMap);
        System.assert(!expectedAccountMap.isEmpty());
        System.assertEquals(expectedAccountMap.size(), returnedAccountList.size());
    }

    /*@isTest //TODO re-add getAccountAndContactsWithEmails method
    static void it_should_return_account_and_contacts_as_children_records() {
        Account account = [SELECT Id FROM Account LIMIT 1];

        Contact contact = (Contact)TestSobjectBuilder.getTestContactBuilder()
            .set(Schema.Contact.AccountId, account.Id)
            .set(Schema.Contact.Email, 'test@email.com')
            .set(Schema.Contact.AccountId, account.Id)
            .build(true);

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

        account = new SobjectRepository_Tests.AccountRepository().getAccountAndContactsWithEmails(account.Id);

        // Make sure that the account & contact query only counts as a singlequery
        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();

        System.assertEquals(expectedAccount.Contacts.size(), account.Contacts.size());
        Contact firstContact = account.Contacts[0];
        System.assertEquals(contact.Id, firstContact.Id);
    }*/

    @isTest
    static void it_should_search_for_search_term() {
        String searchTerm = 'Gillespie';
        Map<Id, Account> soslAccountMap = new Map<Id, Account>([SELECT Id, Name, OwnerId, Owner.Name FROM Account]);
        Test.setFixedSearchResults(new List<Id>(soslAccountMap.keySet()));

        List<Account> expectedAccountList = [FIND :searchTerm IN ALL FIELDS RETURNING Account(Id, Name)][0];
        System.assertNotEquals(0, expectedAccountList.size());

        Test.startTest();
        List<Account> returnedAccountList = (List<Account>)new SobjectRepository_Tests.AccountRepository().search(searchTerm);
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
        List<Account> returnedAccountList = (List<Account>)new SobjectRepository_Tests.AccountRepository().search(searchTerm, Sosl.SearchGroup.NAME_FIELDS);
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
        Soql.QueryFilter queryFilter = new Soql.QueryFilter(new Soql.QueryField(Schema.Account.CreatedDate), '=', new Soql.DateLiteral('TODAY'));
        List<Soql.QueryFilter> queryFilters = new List<Soql.QueryFilter>{queryFilter};
        List<Account> returnedAccountList = (List<Account>)new SobjectRepository_Tests.AccountRepository().search(searchTerm, Sosl.SearchGroup.NAME_FIELDS, queryFilters);
        Test.stopTest();

        System.assertNotEquals(null, expectedAccountList);
        System.assert(!expectedAccountList.isEmpty());
        System.assertEquals(expectedAccountList.size(), returnedAccountList.size());
    }

    @isTest
    static void it_should_insert_a_single_record() {
        Account account = new Account();
        new TestDataFactory(account).populateRequiredFields();
        System.assertEquals(null, account.Id);

        Test.startTest();
        new SobjectRepository_Tests.AccountRepository().insertRecords(account);
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
        new SobjectRepository_Tests.AccountRepository().updateRecords(existingAccount);
        Test.stopTest();

        existingAccount = [SELECT Id, LastModifiedDate FROM Account LIMIT 1];
        System.assert(existingAccount.LastModifiedDate > originalLastModifiedDate, existingAccount);
    }

    @isTest
    static void it_should_upsert_a_single_new_record() {
        Account account = new Account();
        new TestDataFactory(account).populateRequiredFields();
        System.assertEquals(null, account.Id);

        Test.startTest();
        new SobjectRepository_Tests.AccountRepository().upsertRecords(account);
        Test.stopTest();

        System.assertNotEquals(null, account.Id);
    }

    @isTest
    static void it_should_upsert_a_single_existing_record() {
        Account existingAccount = [SELECT Id, LastModifiedDate FROM Account LIMIT 1];
        Datetime originalLastModifiedDate = existingAccount.LastModifiedDate;

        Test.startTest();
        new SobjectRepository_Tests.AccountRepository().upsertRecords(existingAccount);
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
        new SobjectRepository_Tests.UserRepository().upsertRecords(existingUser, Schema.User.Username);
        Test.stopTest();

        existingUser = [SELECT Id, LastModifiedDate FROM User LIMIT 1];
        System.assert(existingUser.LastModifiedDate > originalLastModifiedDate, existingUser);
    }

    @isTest
    static void it_should_delete_a_single_record() {
        Account existingAccount = [SELECT Id, IsDeleted FROM Account LIMIT 1];
        System.assertEquals(false, existingAccount.IsDeleted);

        Test.startTest();
        new SobjectRepository_Tests.AccountRepository().deleteRecords(existingAccount);
        Test.stopTest();

        existingAccount = [SELECT Id, IsDeleted FROM Account WHERE Id = :existingAccount.Id ALL ROWS];
        System.assertEquals(true, existingAccount.IsDeleted);
    }

    @isTest
    static void it_should_hard_delete_a_single_record() {
        Account existingAccount = [SELECT Id, IsDeleted FROM Account LIMIT 1];
        System.assertEquals(false, existingAccount.IsDeleted);

        Test.startTest();
        new SobjectRepository_Tests.AccountRepository().hardDeleteRecords(existingAccount);
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
        new SobjectRepository_Tests.AccountRepository().undeleteRecords(existingAccount);
        Test.stopTest();

        existingAccount = [SELECT Id, IsDeleted FROM Account WHERE Id = :existingAccount.Id ALL ROWS];
        System.assertEquals(false, existingAccount.IsDeleted);
    }

}