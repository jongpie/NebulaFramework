@isTest
private class CrudMock_Tests {
    @isTest
    static void it_should_fake_crud_insert() {
        Contact con = new Contact();

        Test.startTest();

        ICrud crudRepo = new CrudMock();
        crudRepo.doInsert(con);
        Test.stopTest();

        System.assert(TestingUtils.insertedRecords.size() > 0);
    }

    @isTest
    static void it_should_fake_crud_update() {
        Contact con = createContact();

        Test.startTest();

        ICrud crudRepo = new CrudMock();
        crudRepo.doUpdate(con);
        Test.stopTest();

        System.assert(!TestingUtils.updatedRecords.isEmpty());
    }

    @isTest
    static void it_should_fake_crud_upsert() {
        Contact con = createContact();

        Test.startTest();

        ICrud crudRepo = new CrudMock();
        crudRepo.doUpsert(con);
        Test.stopTest();

        System.assert(!TestingUtils.upsertedRecords.isEmpty());
    }

    @isTest
    static void it_should_fake_crud_delete() {
        Contact con = createContact();

        Test.startTest();

        ICrud crudRepo = new CrudMock();
        crudRepo.doDelete(con);
        Test.stopTest();

        System.assert(!TestingUtils.deletedRecords.isEmpty());
    }

    @isTest
    static void it_should_fake_crud_hard_delete() {
        Contact con = createContact();

        Test.startTest();

        ICrud crudRepo = new CrudMock();
        crudRepo.doHardDelete(con);
        Test.stopTest();

        System.assert(!TestingUtils.deletedRecords.isEmpty());
    }

    @isTest
    static void it_should_fake_crud_undelete() {
        Contact con = createContact();

        Test.startTest();

        ICrud crudRepo = new CrudMock();
        crudRepo.doUndelete(con);
        Test.stopTest();

        System.assert(!TestingUtils.undeletedRecords.isEmpty());
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