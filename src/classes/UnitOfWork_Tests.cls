@isTest
private class UnitOfWork_Tests {

    private class TestAccountRepository extends SObjectRepository {
        public override Schema.SObjectType getSObjectType() {
            return Schema.Account.SObjectType;
        }
    }

    private class TestContactRepository extends SObjectRepository {
        public override Schema.SObjectType getSObjectType() {
            return Schema.Contact.SObjectType;
        }
    }

    @isTest
    static void it_should_relate_records() {
        // When to save
        UnitOfWork uow = new UnitOfWork(new List<Schema.SObjectType>{Schema.Account.SObjectType, Schema.Contact.SObjectType});

        // How to save
        IDML accountRepository = new TestAccountRepository();
        uow.add(accountRepository);
        IDML contactRepository = new TestContactRepository();
        uow.add(contactRepository);

        // What to save
        Account account = new Account(Name = 'Derp, Inc');
        accountRepository.registerInsertRecords(new List<SObject>{account});
        Contact contact = new Contact(LastName = 'Derp');
        contactRepository.registerInsertRecords(new List<SObject>{contact});
        uow.relate(contact, Schema.Contact.AccountId, account);

        uow.commitChanges();
        System.assertNotEquals(null, contact.Id);
        System.assertNotEquals(null, contact.AccountId);
        // TODO finish writing tests!
    }

    @isTest
    static void it_should_rollback_all_changes() {
        System.assertEquals(0, [SELECT COUNT() FROM Account]);
        System.assertEquals(0, [SELECT COUNT() FROM Contact]);

        // When to save
        UnitOfWork uow = new UnitOfWork(new List<Schema.SObjectType>{Schema.Account.SObjectType, Schema.Contact.SObjectType});

        // How to save
        TestAccountRepository accountRepository = new TestAccountRepository();
        uow.add(accountRepository);
        TestContactRepository contactRepository = new TestContactRepository();
        uow.add(contactRepository);

        // What to save
        Account account = new Account(Name = 'Derp, Inc');
        accountRepository.registerInsertRecords(new List<SObject>{account});
        Contact contact = new Contact(LastName = null); // null lastname will result in an error on insert
        contactRepository.registerInsertRecords(new List<SObject>{contact});
        uow.relate(contact, Schema.Contact.AccountId, account);
        try {
            uow.commitChanges();
            System.assert(false, 'Exception expected here');
        } catch(Exception e) {
            System.assertEquals(null, account.Id); // TODO add code to set IDs to null for insertRecords
            // https://salesforce.stackexchange.com/questions/121467/invalid-cross-reference-id-error-due-to-rollback
            System.assertEquals(null, contact.Id);
            System.assertEquals(null, contact.AccountId);
            System.assertEquals(0, [SELECT COUNT() FROM Account]);
            System.assertEquals(0, [SELECT COUNT() FROM Contact]);
            //throw e;
        }

        // TODO finish writing tests!
    }

}