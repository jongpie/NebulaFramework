public without sharing class NebulaSettings {

    public RecordTypesSettings__c recordTypesSettings;
    public RepositorySettings__c repositorySettings;
    public TriggerHandlerSettings__c triggerHandlerSettings;

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
        delete [SELECT Id FROM RecordTypesSettings__c];
        delete [SELECT Id FROM RepositorySettings__c];
        delete [SELECT Id FROM TriggerHandlerSettings__c];
    }

    private void createCustomSettings() {
        upsert RecordTypesSettings__c.getOrgDefaults();
        upsert RepositorySettings__c.getOrgDefaults();
        upsert TriggerHandlerSettings__c.getOrgDefaults();
    }

    private void loadRecordTypesSettings() {
        this.recordTypesSettings = RecordTypesSettings__c.getInstance();

        if(this.recordTypesSettings.Id == null) {
            upsert RecordTypesSettings__c.getOrgDefaults();
            this.recordTypesSettings = RecordTypesSettings__c.getInstance();
        }
    }

    private void loadRepositorySettings() {
        this.repositorySettings = RepositorySettings__c.getInstance();

        if(this.repositorySettings.Id == null) {
            upsert RepositorySettings__c.getOrgDefaults();
            this.repositorySettings = RepositorySettings__c.getInstance();
        }
    }

    private void loadTriggerHandlerSettings() {
        this.triggerHandlerSettings = TriggerHandlerSettings__c.getInstance();

        if(this.triggerHandlerSettings.Id == null) {
            upsert TriggerHandlerSettings__c.getOrgDefaults();
            this.triggerHandlerSettings = TriggerHandlerSettings__c.getInstance();
        }
    }

}