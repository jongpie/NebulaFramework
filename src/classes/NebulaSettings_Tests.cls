/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class NebulaSettings_Tests {

    @isTest
    static void it_should_return_logger_settings() {
        List<LoggerSettings__c> existingSettings = [SELECT Id FROM LoggerSettings__c];
        System.assert(existingSettings.isEmpty());

        Test.startTest();
        System.assertNotEquals(null, NebulaSettings.LoggerSettings);
        Test.stopTest();
    }

    @isTest
    static void it_should_return_trigger_handler_settings() {
        List<TriggerHandlerSettings__c> existingSettings = [SELECT Id FROM TriggerHandlerSettings__c];
        System.assert(existingSettings.isEmpty());

        Test.startTest();
        System.assertNotEquals(null, NebulaSettings.TriggerHandlerSettings);
        Test.stopTest();
    }

    @isTest
    static void it_should_reset_all_settings_to_defaults() {
        LoggerSettings__c loggerSettings = LoggerSettings__c.getInstance();
        upsert loggerSettings;
        Id originalLoggerSettingsId = LoggerSettings__c.getInstance().Id;

        TriggerHandlerSettings__c triggerHandlerSettings = TriggerHandlerSettings__c.getInstance();
        upsert triggerHandlerSettings;
        Id originalTriggerHandlerSettingsId = TriggerHandlerSettings__c.getInstance().Id;

        Test.startTest();
        NebulaSettings.resetAllSettingsToDefaults();
        Test.stopTest();

        System.assertNotEquals(originalLoggerSettingsId, LoggerSettings__c.getInstance().Id);
        System.assertNotEquals(originalTriggerHandlerSettingsId, TriggerHandlerSettings__c.getInstance().Id);
    }

}