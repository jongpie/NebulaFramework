/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class SObjectRecordTypes_Tests {

    private class LeadRecordTypes extends SObjectRecordTypes {
        // Test subclass that extends SObjectRecordTypes
        public LeadRecordTypes() {
            super(Schema.Lead.SObjectType);
        }
    }

    @isTest
    static void it_should_return_a_map_of_all_record_types_by_id() {
        List<RecordType> expectedRecordTypeList = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Lead'];

        Test.startTest();

        System.assertEquals(expectedRecordTypeList.size(), new SObjectRecordTypes_Tests.LeadRecordTypes().ALL_RECORD_TYPES_BY_ID.size());
        for(RecordType recordType : expectedRecordTypeList) {
            System.assert(new SObjectRecordTypes_Tests.LeadRecordTypes().ALL_RECORD_TYPES_BY_ID.containsKey(recordType.Id));
        }

        Test.stopTest();
    }

    @isTest
    static void it_should_return_a_map_of_all_record_types_by_developer_name() {
        List<RecordType> expectedRecordTypeList = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Lead'];

        Test.startTest();

        System.assertEquals(expectedRecordTypeList.size(), new SObjectRecordTypes_Tests.LeadRecordTypes().ALL_RECORD_TYPES_BY_DEVELOPER_NAME.size());
        for(RecordType recordType : expectedRecordTypeList) {
            System.assert(new SObjectRecordTypes_Tests.LeadRecordTypes().ALL_RECORD_TYPES_BY_DEVELOPER_NAME.containsKey(recordType.DeveloperName));
        }

        Test.stopTest();
    }

    @isTest
    static void it_should_cache_the_query_results_when_lazy_load_is_enabled() {
        NebulaRecordTypesSettings__c recordTypesSettings = NebulaRecordTypesSettings__c.getInstance();
        recordTypesSettings.LazyLoad__c = true;
        upsert recordTypesSettings;

        Test.startTest();

        System.assertEquals(0, Limits.getQueries());
        for(Integer i = 0; i < 10; i++) {
            System.debug(new SObjectRecordTypes_Tests.LeadRecordTypes().ALL_RECORD_TYPES_BY_ID);
        }

        System.assertEquals(1, Limits.getQueries());

        Test.stopTest();
    }

    @isTest
    static void it_should_cache_the_query_results_when_lazy_load_is_disabled() {
        NebulaRecordTypesSettings__c recordTypesSettings = NebulaRecordTypesSettings__c.getInstance();
        recordTypesSettings.LazyLoad__c = false;
        upsert recordTypesSettings;

        Test.startTest();

        System.assertEquals(0, Limits.getQueries());
        for(Integer i = 0; i < 10; i++) {
            System.debug(new SObjectRecordTypes_Tests.LeadRecordTypes().ALL_RECORD_TYPES_BY_ID);
        }

        System.assertEquals(1, Limits.getQueries());

        Test.stopTest();
    }

}