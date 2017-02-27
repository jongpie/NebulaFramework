@isTest
private class Users_Tests {
    @testSetup
    static void setupData() {
        Profile profile = [SELECT Id FROM Profile WHERE UserType = 'Standard' AND UserLicense.Name = 'Salesforce' LIMIT 1];

        User userWithFederationId = new User(
            Alias                = 'usrFed',
            Email                = 'newuser@testorg.com',
            EmailEncodingKey     = 'UTF-8',
            FederationIdentifier = 'testFedId',
            FirstName            = 'Some',
            IsActive             = true,
            LanguageLocaleKey    = 'en_US',
            LastName             = 'Guy',
            LocaleSidKey         = 'en_US',
            ProfileId            = profile.Id,
            TimeZoneSidKey       = 'America/Los_Angeles',
            UserName             = 'user.with.fedId@testorg.com'
        );

        insert userWithFederationId;
    }

    @isTest
    static void it_should_return_all_users() {
        List<User> expectedListOfUsers = [SELECT Id FROM User];
        System.assertEquals(expectedListOfUsers.size(), Users.ALL_USERS_MAP.size());
    }

    @isTest
    static void it_should_return_active_users() {
        List<User> expectedListOfUsers = [SELECT Id FROM User WHERE IsActive = true];
        System.assertEquals(expectedListOfUsers.size(), Users.ACTIVE_USERS_MAP.size());
    }

    @isTest
    static void it_should_return_inactive_users() {
        List<User> expectedListOfUsers = [SELECT Id FROM User WHERE IsActive = false];
        System.assertEquals(expectedListOfUsers.size(), Users.INACTIVE_USERS_MAP.size());
    }

    @isTest
    static void it_should_return_the_current_user() {
        Id expectedUserId = UserInfo.getUserId();
        System.assertEquals(expectedUserId, Users.CURRENT_USER.Id);
    }

    @isTest
    static void it_should_return_a_user_by_id() {
        Id expectedUserId = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() LIMIT 1].Id;
        System.assertEquals(expectedUserId, Users.getUserById(expectedUserId).Id);
    }

    @isTest
    static void it_should_return_a_user_by_federation_id() {
        User expectedUser = [SELECT Id, FederationIdentifier FROM User WHERE Id != :UserInfo.getUserId() AND FederationIdentifier != null LIMIT 1];
        System.assertEquals(expectedUser.Id, Users.getUserByFederationId(expectedUser.FederationIdentifier).Id);
    }

    @isTest
    static void it_should_return_a_bykk_user_for_a_null_federation_id() {
        User returnedUser = Users.getUserByFederationId(null);
        System.assertEquals(null, returnedUser);
    }

    @isTest
    static void it_should_cache_the_main_query_for_all_variables() {
        Test.startTest();
        System.assertEquals(0, Limits.getQueries());

        System.debug(Users.ACTIVE_USERS_MAP);
        System.debug(Users.ALL_USERS_MAP);
        System.debug(Users.INACTIVE_USERS_MAP);
        System.debug(Users.CURRENT_USER);

        System.assertEquals(1, Limits.getQueries());
        Test.stopTest();
    }

}