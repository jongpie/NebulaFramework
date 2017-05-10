/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public without sharing class NebulaSettings {

    public static NebulaLoggerSettings__c loggerSettings;
    public static NebulaRecordTypesSettings__c recordTypesSettings;
    public static NebulaRepositorySettings__c repositorySettings;
    public static NebulaTriggerHandlerSettings__c triggerHandlerSettings;

    static {
        loadCustomSettings();
    }

    public static void resetAllSettingsToDefaults() {
        deleteExistingCustomSettings();
        createCustomSettings();
    }

    private static void loadCustomSettings() {
        loadLoggerSettings();
        loadRecordTypesSettings();
        loadRepositorySettings();
        loadTriggerHandlerSettings();
    }

    private static void deleteExistingCustomSettings() {
        delete [SELECT Id FROM NebulaLoggerSettings__c];
        delete [SELECT Id FROM NebulaRecordTypesSettings__c];
        delete [SELECT Id FROM NebulaRepositorySettings__c];
        delete [SELECT Id FROM NebulaTriggerHandlerSettings__c];
    }

    private static void createCustomSettings() {
        upsert NebulaLoggerSettings__c.getOrgDefaults();
        upsert NebulaRecordTypesSettings__c.getOrgDefaults();
        upsert NebulaRepositorySettings__c.getOrgDefaults();
        upsert NebulaTriggerHandlerSettings__c.getOrgDefaults();
    }

    private static void loadLoggerSettings() {
        loggerSettings = NebulaLoggerSettings__c.getInstance();

        if(loggerSettings.Id == null) {
            upsert NebulaLoggerSettings__c.getOrgDefaults();
            loggerSettings = NebulaLoggerSettings__c.getInstance();
        }
    }

    private static void loadRecordTypesSettings() {
        recordTypesSettings = NebulaRecordTypesSettings__c.getInstance();

        if(recordTypesSettings.Id == null) {
            upsert NebulaRecordTypesSettings__c.getOrgDefaults();
            recordTypesSettings = NebulaRecordTypesSettings__c.getInstance();
        }
    }

    private static void loadRepositorySettings() {
        repositorySettings = NebulaRepositorySettings__c.getInstance();

        if(repositorySettings.Id == null) {
            upsert NebulaRepositorySettings__c.getOrgDefaults();
            repositorySettings = NebulaRepositorySettings__c.getInstance();
        }
    }

    private static void loadTriggerHandlerSettings() {
        triggerHandlerSettings = NebulaTriggerHandlerSettings__c.getInstance();

        if(triggerHandlerSettings.Id == null) {
            upsert NebulaTriggerHandlerSettings__c.getOrgDefaults();
            triggerHandlerSettings = NebulaTriggerHandlerSettings__c.getInstance();
        }
    }

}