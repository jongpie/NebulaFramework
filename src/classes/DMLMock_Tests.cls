/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class DMLMock_Tests {

    static IDML dmlRepo = new DMLMock();
    static Schema.Contact con = createContact();

    @isTest
    static void it_should_fake_dml_insert() {
        Test.startTest();
        dmlRepo.doInsert(con);
        Test.stopTest();

        System.assert(TestingUtils.insertedRecords.size() > 0);
    }

    @isTest
    static void it_should_fake_dml_update() {
        Test.startTest();
        dmlRepo.doUpdate(con);
        Test.stopTest();

        System.assert(!TestingUtils.updatedRecords.isEmpty());
    }

    @isTest
    static void it_should_fake_dml_upsert() {
        Test.startTest();
        dmlRepo.doUpsert(con);
        Test.stopTest();

        System.assert(!TestingUtils.upsertedRecords.isEmpty());
    }

    @isTest
    static void it_should_fake_dml_delete() {
        Test.startTest();
        dmlRepo.doDelete(con);
        Test.stopTest();

        System.assert(!TestingUtils.deletedRecords.isEmpty());
    }

    @isTest
    static void it_should_fake_dml_hard_delete() {
        Test.startTest();
        dmlRepo.doHardDelete(con);
        Test.stopTest();

        System.assert(!TestingUtils.deletedRecords.isEmpty());
    }

    @isTest
    static void it_should_fake_dml_undelete() {
        Test.startTest();
        dmlRepo.doUndelete(con);
        Test.stopTest();

        System.assert(!TestingUtils.undeletedRecords.isEmpty());
    }

    @isTest
    static void it_should_mock_updating_read_only_fields_when_updating_data() {
        Schema.Lead l = new Schema.Lead();
        l = (Lead)TestingUtils.setReadOnlyField(l, Schema.Lead.IsConverted, true);

        Test.startTest();
        dmlRepo.doUpdate(l);
        Test.stoptest();

        SObject record = TestingUtils.updatedRecords[0];
        System.assert(record instanceof Schema.Lead);
        System.assert(record.get('IsConverted') != null);
    }

    private static Contact createContact() {
        con = new Contact();
        con.Email = 'rightHandMan@hamilton.com';
        con.FirstName = 'George';
        con.LastName = 'Washington';
        con.LeadSource = 'Web';

        return con;
    }

}