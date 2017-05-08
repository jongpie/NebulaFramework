@isTest
private class DML_Tests {
    @isTest
    static void it_should_do_dml_insert() {
        Contact contact = createContact();

        IDML dml = new DML();

        Test.startTest();
        dml.doInsert(contact);
        Test.stopTest();

        System.assert(contact.Id != null);
    }

    @isTest
    static void it_should_do_dml_update() {
        Contact contact = createContact();
        insert contact;

        contact.FirstName = 'Harry';
        IDML dml = new DML();

        Test.startTest();
        dml.doUpdate(contact);
        Test.stopTest();

        System.assert(contact.FirstName == 'Harry');
    }

    @isTest
    static void it_should_do_dml_upsert() {
        Contact contact = createContact();
        insert contact;

        contact.FirstName = 'Harry';
        IDML dml = new DML();

        Test.startTest();
        dml.doUpsert(contact);
        Test.stopTest();

        System.assert(contact.FirstName == 'Harry');
    }

    @isTest
    static void it_should_do_dml_delete() {
        Contact contact = createContact();
        insert contact;

        Test.startTest();
        IDML dml = new DML();
        dml.doDelete(contact);
        List<Contact> deletedContacts = [SELECT Id, IsDeleted FROM Contact ALL ROWS];
        Test.stopTest();

        System.assert(deletedContacts[0].IsDeleted);
    }

    @isTest
    static void it_should_do_dml_hard_delete() {
        Contact contact = createContact();
        insert contact;

        Test.startTest();
        IDML dml = new DML();
        dml.doHardDelete(contact);
        List<Contact> deletedContacts = [SELECT Id, IsDeleted FROM Contact ALL ROWS];
        Test.stopTest();

        System.assert(deletedContacts[0].IsDeleted);
    }

    @isTest
    static void it_should_do_dml_undelete() {
        Contact contact = createContact();
        insert contact;

        Test.startTest();
        IDML dml = new DML();
        dml.doDelete(contact);
        dml.doUndelete(contact);
        Test.stopTest();

        List<Contact> notDeletedContacts = [SELECT Id FROM Contact];
        System.assert(!notDeletedContacts.isEmpty());
    }

    private static Contact createContact() {
        Contact contact = new Contact();
        contact.Email = 'rightHandMan@hamilton.com';
        contact.FirstName = 'George';
        contact.LastName = 'Washington';
        contact.LeadSource = 'Web';

        return contact;
    }
}