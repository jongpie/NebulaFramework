@isTest
private class Profiles_Tests {

    @isTest
    static void it_should_return_a_map_of_all_record_types_by_id() {
        List<Profile> expectedProfileList = [SELECT Id, Name, UserLicenseId, UserType FROM Profile];

        Test.startTest();

        System.assertEquals(expectedProfileList.size(), new Profiles().getAllById().size());
        for(Profile profile : expectedProfileList) {
            System.assert(new Profiles().getAllById().containsKey(profile.Id));
        }

        Test.stopTest();
    }

    @isTest
    static void it_should_return_a_map_of_all_record_types_by_name() {
        List<Profile> expectedProfileList = [SELECT Id, Name, UserLicenseId, UserType FROM Profile];

        Test.startTest();

        System.assertEquals(expectedProfileList.size(), new Profiles().getAllById().size());
        for(Profile profile : expectedProfileList) {
            System.assert(new Profiles().getAllByName().containsKey(profile.Name));
        }

        Test.stopTest();
    }

    @isTest
    static void it_should_return_the_system_administrator_profile() {
        Profile expectedProfile = [
            SELECT Id, Name
            FROM Profile
            WHERE UserType = 'Standard'
            AND PermissionsCustomizeApplication = true
        ];

        Test.startTest();
        System.assertEquals(expectedProfile.Id, new Profiles().getSystemAdministrator().Id);
        Test.stopTest();
    }

    @isTest
    static void it_should_cache_the_query_results() {
        Test.startTest();

        System.assertEquals(0, Limits.getQueries());
        for(Integer i = 0; i < 10; i++) {
            System.debug(new Profiles().getAllById());
            System.debug(new Profiles().getAllByName());
            System.debug(new Profiles().getSystemAdministrator());
        }

        System.assertEquals(1, Limits.getQueries());

        Test.stopTest();
    }

}