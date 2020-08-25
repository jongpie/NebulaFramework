/********************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.                    *
* See LICENSE file or go to https://github.com/jongpie/NebulaTriggerFramework for full license details. *
********************************************************************************************************/
@isTest
private class RecordBatchAssigner_Tests {

    private static final String ACCOUNT_PREFIX      = 'Account #';
    private static final Integer ACCOUNTS_TO_CREATE = 200;
    private static final String USER_PREFIX         = 'User #';
    private static final Integer USERS_TO_CREATE    = 10;

    @testSetup
    private static void setupData() {
        Id currentUserId = UserInfo.getUserId();

        List<User> users = new List<User>();
        for(Integer i = 0; i < USERS_TO_CREATE; i++) {
            User user = new User(
                IsActive          = true,
                CommunityNickname = 'usr' + i,
                LastName          = USER_PREFIX + i,
                ProfileId         = UserInfo.getProfileId(),
                Username          = 'user.number.' + i + '@example.com'
            );
            new TestDataFactory(user).populateRequiredFields();

            users.add(user);
        }
        insert users;

        // To avoid mixed-DML operations, run account insert as a separate user
        System.runAs(users.get(0)) {
            List<Account> accounts = new List<Account>();
            for(Integer i = 0; i < ACCOUNTS_TO_CREATE; i++) {
                Account account = new Account(
                    Name    = ACCOUNT_PREFIX + i,
                    OwnerId = currentUserId
                );
                new TestDataFactory(account).populateRequiredFields();

                accounts.add(account);
            }
            insert accounts;
        }
    }

    @isTest
    private static void it_should_evenly_assign_records_for_all_accounts() {
        Set<Id> userIds = new Map<Id, User>([SELECT Id FROM User WHERE LastName LIKE :USER_PREFIX + '%']).keySet();

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
        Set<Id> userIds = new Map<Id, User>([SELECT Id FROM User WHERE LastName LIKE :USER_PREFIX + '%']).keySet();

        List<Id> accountIdsToAssign = new List<Id>();
        for(Account account : [SELECT Id, OwnerId FROM Account]) {
            accountIdsToAssign.add(account.Id);
        }

        Integer expectedNumberOfAssignedRecords = accountIdsToAssign.size() / userIds.size();

        Test.startTest();

        RecordBatchAssigner batchAssigner = new RecordBatchAssigner(accountIdsToAssign, userIds);
        Database.executeBatch(batchAssigner);

        Test.stopTest();

        for(AggregateResult result : [SELECT OwnerId, COUNT(Id) recordCount FROM Account WHERE Id IN :accountIdsToAssign GROUP BY OwnerId]) {
            Id ownerId = (Id)result.get('ownerId');
            Integer assignedRecordCount = Integer.valueOf(result.get('recordCount'));

            System.assertEquals(expectedNumberOfAssignedRecords, assignedRecordCount);
        }
    }

}