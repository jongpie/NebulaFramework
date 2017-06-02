/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class DML_Tests {

    static IDML dml = new DML();
    static Contact contact = createContact();

    @isTest
    static void it_should_do_dml_insert() {

        Test.startTest();
        dml.doInsert(contact);
        Test.stopTest();

        System.assert(contact.Id != null);
    }

    @isTest
    static void it_should_do_dml_update() {
        insert contact;

        contact.FirstName = 'Harry';

        Test.startTest();
        dml.doUpdate(contact);
        Test.stopTest();

        System.assert(contact.FirstName == 'Harry');
    }

    @isTest
    static void it_should_do_dml_upsert() {
        insert contact;

        contact.FirstName = 'Harry';

        Test.startTest();
        dml.doUpsert(contact);
        Test.stopTest();

        System.assert(contact.FirstName == 'Harry');
    }

    @isTest
    static void it_should_do_dml_delete() {
        insert contact;

        Test.startTest();
        dml.doDelete(contact);
        List<Contact> deletedContacts = [SELECT Id, IsDeleted FROM Contact ALL ROWS];
        Test.stopTest();

        System.assert(deletedContacts[0].IsDeleted);
    }

    @isTest
    static void it_should_do_dml_hard_delete() {
        insert contact;

        Test.startTest();
        dml.doHardDelete(contact);
        List<Contact> deletedContacts = [SELECT Id, IsDeleted FROM Contact ALL ROWS];
        Test.stopTest();

        System.assert(deletedContacts[0].IsDeleted);
    }

    @isTest
    static void it_should_do_dml_undelete() {
        insert contact;

        Test.startTest();
        dml.doDelete(contact);
        dml.doUndelete(contact);
        Test.stopTest();

        List<Contact> notDeletedContacts = [SELECT Id FROM Contact];
        System.assert(!notDeletedContacts.isEmpty());
    }

    private static Contact createContact() {
        contact = new Contact();
        contact.Email = 'rightHandMan@hamilton.com';
        contact.FirstName = 'George';
        contact.LastName = 'Washington';
        contact.LeadSource = 'Web';

        return contact;
    }

}