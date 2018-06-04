/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public without sharing class NebulaSettings {

    public static LoggerSettings__c LoggerSettings {get; private set;}
    public static TriggerHandlerSettings__c TriggerHandlerSettings {get; private set;}

    static {
        loadCustomSettings();
    }

    public static void resetAllSettingsToDefaults() {
        deleteExistingCustomSettings();
        createCustomSettings();
    }

    private static void loadCustomSettings() {
        loadLoggerSettings();
        loadTriggerHandlerSettings();
    }

    private static void deleteExistingCustomSettings() {
        delete [SELECT Id FROM LoggerSettings__c];
        delete [SELECT Id FROM TriggerHandlerSettings__c];
    }

    private static void createCustomSettings() {
        upsert LoggerSettings__c.getOrgDefaults();
        upsert TriggerHandlerSettings__c.getOrgDefaults();
    }

    private static void loadLoggerSettings() {
        loggerSettings = LoggerSettings__c.getInstance();

        if(loggerSettings.Id == null) {
            upsert LoggerSettings__c.getOrgDefaults();
            loggerSettings = LoggerSettings__c.getInstance();
        }
    }

    private static void loadTriggerHandlerSettings() {
        triggerHandlerSettings = TriggerHandlerSettings__c.getInstance();

        if(triggerHandlerSettings.Id == null) {
            upsert TriggerHandlerSettings__c.getOrgDefaults();
            triggerHandlerSettings = TriggerHandlerSettings__c.getInstance();
        }
    }

}