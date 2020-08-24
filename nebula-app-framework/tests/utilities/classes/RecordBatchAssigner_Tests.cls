/********************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.                    *
* See LICENSE file or go to https://github.com/jongpie/NebulaTriggerFramework for full license details. *
********************************************************************************************************/
@isTest
private class RecordBatchAssigner_Tests {

    @testSetup
    private static void setupData() {
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < 200; i++) {
            Account account = new Account(name = 'Account #' + i);
            new TestDataFactory(account).populateRequiredFields();

            accounts.add(account);
        }
        insert accounts;
    }

    @isTest
    private static void it_should_evenly_assign_records_for_all_accounts() {
        Set<Id> userIds = new Map<Id, User>([SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND UserType = 'Standard']).keySet();

        for(Account account : [SELECT Id, OwnerId FROM Account]) {
            System.assertEquals(UserInfo.getUserId(), account.OwnerId);
        }

        Test.startTest();

        RecordBatchAssigner batchAssigner = new RecordBatchAssigner(Schema.Account.SObjectType, userIds);
        Database.executeBatch(batchAssigner);

        Test.stopTest();

        for(Account account : [SELECT Id, OwnerId FROM Account]) {
            System.assertNotEquals(UserInfo.getUserId(), account.OwnerId);
        }
    }

    @isTest
    private static void it_should_evenly_assign_records_for_specified_accounts() {
        Set<Id> userIds = new Map<Id, User>([SELECT Id FROM User WHERE Id = :UserInfo.getUserId() OR UserType = 'Standard' LIMIT 3]).keySet();

        List<Id> accountIdsToAssign = new List<Id>();
        for(Account account : [SELECT Id, OwnerId FROM Account LIMIT 75]) {
            accountIdsToAssign.add(account.Id);
        }

        Test.startTest();

        RecordBatchAssigner batchAssigner = new RecordBatchAssigner(accountIdsToAssign, userIds);
        Database.executeBatch(batchAssigner);

        Test.stopTest();

        for(AggregateResult result : [SELECT OwnerId, COUNT(Id) recordCount FROM Account WHERE Id IN :accountIdsToAssign GROUP BY OwnerId]) {
            Id ownerId = (Id)result.get('ownerId');
            Integer assignedRecordCount = Integer.valueOf(result.get('recordCount'));

            System.assertEquals(25, assignedRecordCount);
        }
    }

}