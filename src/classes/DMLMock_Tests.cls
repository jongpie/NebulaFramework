@isTest
private class DMLMock_Tests {
    @isTest
    static void it_should_fake_dml_insert() {
        Contact con = new Contact();

        Test.startTest();

        IDML dmlRepo = new DMLMock();
        dmlRepo.doInsert(con);
        Test.stopTest();

        System.assert(TestingUtils.insertedRecords.size() > 0);
    }

    @isTest
    static void it_should_fake_dml_update() {
        Contact con = createContact();

        Test.startTest();

        IDML dmlRepo = new DMLMock();
        dmlRepo.doUpdate(con);
        Test.stopTest();

        System.assert(!TestingUtils.updatedRecords.isEmpty());
    }

    @isTest
    static void it_should_fake_dml_upsert() {
        Contact con = createContact();

        Test.startTest();

        IDML dmlRepo = new DMLMock();
        dmlRepo.doUpsert(con);
        Test.stopTest();

        System.assert(!TestingUtils.upsertedRecords.isEmpty());
    }

    @isTest
    static void it_should_fake_dml_delete() {
        Contact con = createContact();

        Test.startTest();

        IDML dmlRepo = new DMLMock();
        dmlRepo.doDelete(con);
        Test.stopTest();

        System.assert(!TestingUtils.deletedRecords.isEmpty());
    }

    @isTest
    static void it_should_fake_dml_hard_delete() {
        Contact con = createContact();

        Test.startTest();

        IDML dmlRepo = new DMLMock();
        dmlRepo.doHardDelete(con);
        Test.stopTest();

        System.assert(!TestingUtils.deletedRecords.isEmpty());
    }

    @isTest
    static void it_should_fake_dml_undelete() {
        Contact con = createContact();

        Test.startTest();

        IDML dmlRepo = new DMLMock();
        dmlRepo.doUndelete(con);
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