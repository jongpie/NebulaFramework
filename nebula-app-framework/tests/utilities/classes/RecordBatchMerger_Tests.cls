/********************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.                    *
* See LICENSE file or go to https://github.com/jongpie/NebulaTriggerFramework for full license details. *
********************************************************************************************************/
@isTest
private class RecordBatchMerger_Tests {

    @isTest
    private static void it_should_merge_dupliate_accounts() {
        Account master = new Account(name = 'master');
        new TestDataFactory(master).populateRequiredFields();
        insert master;

        Account duplicate = new Account(name = 'duplicate');
        duplicate.Site = master.Id;
        new TestDataFactory(duplicate).populateRequiredFields();
        insert duplicate;

        Test.startTest();
        RecordBatchMerger batchMerger = new RecordBatchMerger(Schema.Account.SObjectType, Schema.Account.Site);
        Database.executeBatch(batchMerger);
        Test.stopTest();

        master = [SELECT Id, IsDeleted FROM Account WHERE Id = :master.Id ALL ROWS];
        System.assertEquals(false, master.IsDeleted);

        duplicate = [SELECT Id, IsDeleted, MasterRecordId FROM Account WHERE Id = :duplicate.Id ALL ROWS];
        System.assertEquals(true, duplicate.IsDeleted);
        System.assertEquals(master.Id, duplicate.MasterRecordId);
    }

}