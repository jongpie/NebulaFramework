global without sharing class PostInstallHandler implements System.InstallHandler {

    global void onInstall(InstallContext context) {
        if(context.isUpgrade()) this.deleteExistingCustomSettings();

        this.createCustomSettings();
        this.sendEmailAlert(context);
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

    private void sendEmailAlert(InstallContext context) {
        User user = [SELECT Id, Email, Name, Username FROM User WHERE Id = :context.installerId()];
        String toAddress = 'sf.nebula@jongpie.com';
        String[] toAddresses = new String[] {toAddress};

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setReplyTo(user.Email);
        mail.setSenderDisplayName(user.Name);
        mail.setSubject('Nebula Framework Package (version ' + System.requestVersion() +'): uninstalled successfully');
        mail.setPlainTextBody(user.Username + ' (' + user.Email + ') has uninstalled Nebula Framework from org ID: ' + context.organizationId());
        Messaging.sendEmail(new Messaging.Email[] { mail });
    }

}