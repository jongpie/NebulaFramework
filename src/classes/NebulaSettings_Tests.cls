/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class NebulaSettings_Tests {

    @isTest
    static void it_should_return_recordTypesSettings() {
        List<NebulaRecordTypesSettings__c> existingSettings = [SELECT Id FROM NebulaRecordTypesSettings__c];
        System.assert(existingSettings.isEmpty());

        Test.startTest();
        System.assertNotEquals(null, NebulaSettings.recordTypesSettings);
        Test.stopTest();
    }

    @isTest
    static void it_should_return_loggerSettings() {
        List<NebulaLoggerSettings__c> existingSettings = [SELECT Id FROM NebulaLoggerSettings__c];
        System.assert(existingSettings.isEmpty());

        Test.startTest();
        System.assertNotEquals(null, NebulaSettings.loggerSettings);
        Test.stopTest();
    }

    @isTest
    static void it_should_return_repositorySettings() {
        List<NebulaRepositorySettings__c> existingSettings = [SELECT Id FROM NebulaRepositorySettings__c];
        System.assert(existingSettings.isEmpty());

        Test.startTest();
        System.assertNotEquals(null, NebulaSettings.repositorySettings);
        Test.stopTest();
    }

    @isTest
    static void it_should_return_triggerHandlerSettings() {
        List<NebulaTriggerHandlerSettings__c> existingSettings = [SELECT Id FROM NebulaTriggerHandlerSettings__c];
        System.assert(existingSettings.isEmpty());

        Test.startTest();
        System.assertNotEquals(null, NebulaSettings.triggerHandlerSettings);
        Test.stopTest();
    }

    @isTest
    static void it_should_reset_all_settings_to_defaults() {
        NebulaLoggerSettings__c nebulaLoggerSettings = NebulaLoggerSettings__c.getInstance();
        upsert nebulaLoggerSettings;
        Id originalLoggerSettingsId = NebulaLoggerSettings__c.getInstance().Id;

        NebulaRecordTypesSettings__c nebulaRecordTypesSettings = NebulaRecordTypesSettings__c.getInstance();
        upsert nebulaRecordTypesSettings;
        Id originalRecordTypesSettingsId = NebulaRecordTypesSettings__c.getInstance().Id;

        NebulaRepositorySettings__c nebulaRepositorySettings = NebulaRepositorySettings__c.getInstance();
        upsert nebulaRepositorySettings;
        Id originalRepositorySettingsId = NebulaRepositorySettings__c.getInstance().Id;

        NebulaTriggerHandlerSettings__c nebulaTriggerHandlerSettings = NebulaTriggerHandlerSettings__c.getInstance();
        upsert nebulaTriggerHandlerSettings;
        Id originalTriggerHandlerSettingsId = NebulaTriggerHandlerSettings__c.getInstance().Id;

        Test.startTest();
        NebulaSettings.resetAllSettingsToDefaults();
        Test.stopTest();

        System.assertNotEquals(originalLoggerSettingsId, NebulaLoggerSettings__c.getInstance().Id);
        System.assertNotEquals(originalRecordTypesSettingsId, NebulaRecordTypesSettings__c.getInstance().Id);
        System.assertNotEquals(originalRepositorySettingsId, NebulaRepositorySettings__c.getInstance().Id);
        System.assertNotEquals(originalTriggerHandlerSettingsId, NebulaTriggerHandlerSettings__c.getInstance().Id);
    }

}