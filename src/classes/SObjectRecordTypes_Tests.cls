@isTest
private class SObjectRecordTypes_Tests {

    private class LeadRecordTypes extends SObjectRecordTypes {
        // Test subclass that extends SObjectRecordTypes
        public LeadRecordTypes() {
            super(Schema.SObjectType.Lead);
        }
    }

    @isTest
    static void allRecordTypesById() {
        List<RecordType> expectedRecordTypeList = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Lead'];

        Test.startTest();

        System.assertEquals(expectedRecordTypeList.size(), new SObjectRecordTypes_Tests.LeadRecordTypes().ALL_RECORD_TYPES_BY_ID.size());
        for(RecordType recordType : expectedRecordTypeList) {
            System.assert(new SObjectRecordTypes_Tests.LeadRecordTypes().ALL_RECORD_TYPES_BY_ID.containsKey(recordType.Id));
        }

        Test.stopTest();
    }

    @isTest
    static void allRecordTypesByDeveloperName() {
        List<RecordType> expectedRecordTypeList = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Lead'];

        Test.startTest();

        System.assertEquals(expectedRecordTypeList.size(), new SObjectRecordTypes_Tests.LeadRecordTypes().ALL_RECORD_TYPES_BY_DEVELOPER_NAME.size());
        for(RecordType recordType : expectedRecordTypeList) {
            System.assert(new SObjectRecordTypes_Tests.LeadRecordTypes().ALL_RECORD_TYPES_BY_DEVELOPER_NAME.containsKey(recordType.DeveloperName));
        }

        Test.stopTest();
    }

    @isTest
    static void queryIsCached_when_lazyLoadEnabled() {
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
    static void queryIsCached_when_lazyLoadDisabled() {
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