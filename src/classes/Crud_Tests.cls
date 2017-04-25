@isTest
private class Crud_Tests {
    @isTest
    static void it_should_do_crud_insert() {
        Contact contact = createContact();

        ICrud crud = new Crud();

        Test.startTest();
        crud.doInsert(contact);
        Test.stopTest();

        System.assert(contact.Id != null);
    }

    @isTest
    static void it_should_do_crud_update() {
        Contact contact = createContact();
        insert contact;

        contact.FirstName = 'Harry';
        ICrud crud = new Crud();

        Test.startTest();
        crud.doUpdate(contact);
        Test.stopTest();

        System.assert(contact.FirstName == 'Harry');
    }

    @isTest
    static void it_should_do_crud_upsert() {
        Contact contact = createContact();
        insert contact;

        contact.FirstName = 'Harry';
        ICrud crud = new Crud();

        Test.startTest();
        crud.doUpsert(contact);
        Test.stopTest();

        System.assert(contact.FirstName == 'Harry');
    }

    @isTest
    static void it_should_do_crud_delete() {
        Contact contact = createContact();
        insert contact;

        Test.startTest();
        ICrud crud = new Crud();
        crud.doDelete(contact);
        List<Contact> deletedContacts = [SELECT Id, IsDeleted FROM Contact ALL ROWS];
        Test.stopTest();

        System.assert(deletedContacts[0].IsDeleted);
    }

    @isTest
    static void it_should_do_crud_hard_delete() {
        Contact contact = createContact();
        insert contact;

        Test.startTest();
        ICrud crud = new Crud();
        crud.doHardDelete(contact);
        List<Contact> deletedContacts = [SELECT Id, IsDeleted FROM Contact ALL ROWS];
        Test.stopTest();

        System.assert(deletedContacts[0].IsDeleted);
    }

    @isTest
    static void it_should_do_crud_undelete() {
        Contact contact = createContact();
        insert contact;

        Test.startTest();
        ICrud crud = new Crud();
        crud.doDelete(contact);
        crud.doUndelete(contact);
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