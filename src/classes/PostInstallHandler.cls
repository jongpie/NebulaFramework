global without sharing class PostInstallHandler implements InstallHandler {

    global void onInstall(InstallContext context) {
        if(context.previousVersion() == null) {
            this.createCustomSettings();
        }
    }

    private void createCustomSettings() {
        upsert RecordTypesSettings__c.getOrgDefaults();
        upsert RepositorySettings__c.getOrgDefaults();
        upsert TriggerHandlerSettings__c.getOrgDefaults();
    }

}