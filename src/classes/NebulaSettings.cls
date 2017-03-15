/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public without sharing class NebulaSettings {

    public NebulaRecordTypesSettings__c recordTypesSettings;
    public NebulaRepositorySettings__c repositorySettings;
    public NebulaTriggerHandlerSettings__c triggerHandlerSettings;

    public NebulaSettings() {
        this.loadCustomSettings();
    }

    public void resetAllSettingsToDefaults() {
        this.deleteExistingCustomSettings();
        this.createCustomSettings();
    }

    private void loadCustomSettings() {
        this.loadRecordTypesSettings();
        this.loadRepositorySettings();
        this.loadTriggerHandlerSettings();
    }

    private void deleteExistingCustomSettings() {
        delete [SELECT Id FROM NebulaRecordTypesSettings__c];
        delete [SELECT Id FROM NebulaRepositorySettings__c];
        delete [SELECT Id FROM NebulaTriggerHandlerSettings__c];
    }

    private void createCustomSettings() {
        upsert NebulaRecordTypesSettings__c.getOrgDefaults();
        upsert NebulaRepositorySettings__c.getOrgDefaults();
        upsert NebulaTriggerHandlerSettings__c.getOrgDefaults();
    }

    private void loadRecordTypesSettings() {
        this.recordTypesSettings = NebulaRecordTypesSettings__c.getInstance();

        if(this.recordTypesSettings.Id == null) {
            upsert NebulaRecordTypesSettings__c.getOrgDefaults();
            this.recordTypesSettings = NebulaRecordTypesSettings__c.getInstance();
        }
    }

    private void loadRepositorySettings() {
        this.repositorySettings = NebulaRepositorySettings__c.getInstance();

        if(this.repositorySettings.Id == null) {
            upsert NebulaRepositorySettings__c.getOrgDefaults();
            this.repositorySettings = NebulaRepositorySettings__c.getInstance();
        }
    }

    private void loadTriggerHandlerSettings() {
        this.triggerHandlerSettings = NebulaTriggerHandlerSettings__c.getInstance();

        if(this.triggerHandlerSettings.Id == null) {
            upsert NebulaTriggerHandlerSettings__c.getOrgDefaults();
            this.triggerHandlerSettings = NebulaTriggerHandlerSettings__c.getInstance();
        }
    }

}