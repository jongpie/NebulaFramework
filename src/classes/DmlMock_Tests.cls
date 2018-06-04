/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class DmlMock_Tests {

    static IDml contactDmlRepo = new DmlMock.ContactDmlMock();
    static Schema.Contact contact = (Contact)TestSObjectBuilder.getTestContactBuilder().build();

    @isTest
    static void it_should_fake_dml_insert() {
        Test.startTest();
        contactDmlRepo.insertRecords(contact);
        Test.stopTest();

        System.assert(TestingUtils.insertedRecords.size() > 0);
    }

    @isTest
    static void it_should_fake_dml_update() {
        Test.startTest();
        contactDmlRepo.updateRecords(contact);
        Test.stopTest();

        System.assert(!TestingUtils.updatedRecords.isEmpty());
    }

    @isTest
    static void it_should_fake_dml_upsert() {
        Test.startTest();
        contactDmlRepo.upsertRecords(contact);
        Test.stopTest();

        System.assert(!TestingUtils.upsertedRecords.isEmpty());
    }

    @isTest
    static void it_should_fake_dml_delete() {
        Test.startTest();
        contactDmlRepo.deleteRecords(contact);
        Test.stopTest();

        System.assert(!TestingUtils.deletedRecords.isEmpty());
    }

    @isTest
    static void it_should_fake_dml_hard_delete() {
        Test.startTest();
        contactDmlRepo.hardDeleteRecords(contact);
        Test.stopTest();

        System.assert(!TestingUtils.deletedRecords.isEmpty());
    }

    @isTest
    static void it_should_fake_dml_undelete() {
        Test.startTest();
        contactDmlRepo.undeleteRecords(contact);
        Test.stopTest();

        System.assert(!TestingUtils.undeletedRecords.isEmpty());
    }

    @isTest
    static void it_should_mock_updating_read_only_fields_when_updating_data() {
        Schema.Lead l = new Schema.Lead();
        l = (Lead)TestingUtils.setReadOnlyField(l, Schema.Lead.IsConverted, true);

        Test.startTest();
        contactDmlRepo.updateRecords(l);
        Test.stoptest();

        SObject record = TestingUtils.updatedRecords[0];
        System.assert(record instanceof Schema.Lead);
        System.assert(record.get('IsConverted') != null);
    }


}