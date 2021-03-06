/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Configuration
*
* @description TODO
*
*/
public without sharing class NebulaSettings {

    /**
    * @description TODO
    * returns true if it's a sandbox
    */
    public static NebulaLoggerSettings__c LoggerSettings {get; private set;}
    public static NebulaRecordTypesSettings__c RecordTypesSettings {get; private set;}
    public static NebulaSObjectQueryBuilderSettings__c SObjectQueryBuilderSettings {get; private set;}
    public static NebulaTriggerHandlerSettings__c TriggerHandlerSettings {get; private set;}

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
        loadSObjectQueryBuilderSettings();
        loadTriggerHandlerSettings();
    }

    private static void deleteExistingCustomSettings() {
        delete [SELECT Id FROM NebulaLoggerSettings__c];
        delete [SELECT Id FROM NebulaRecordTypesSettings__c];
        delete [SELECT Id FROM NebulaSObjectQueryBuilderSettings__c];
        delete [SELECT Id FROM NebulaTriggerHandlerSettings__c];
    }

    private static void createCustomSettings() {
        upsert NebulaLoggerSettings__c.getOrgDefaults();
        upsert NebulaRecordTypesSettings__c.getOrgDefaults();
        upsert NebulaSObjectQueryBuilderSettings__c.getOrgDefaults();
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

    private static void loadSObjectQueryBuilderSettings() {
        sobjectQueryBuilderSettings = NebulaSObjectQueryBuilderSettings__c.getInstance();

        if(sobjectQueryBuilderSettings.Id == null) {
            upsert NebulaSObjectQueryBuilderSettings__c.getOrgDefaults();
            sobjectQueryBuilderSettings = NebulaSObjectQueryBuilderSettings__c.getInstance();
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