global without sharing class PostUninstallHandler implements System.UninstallHandler {

    global void onUninstall(UninstallContext context) {
        this.sendEmailAlert(context);
    }

    private void sendEmailAlert(UninstallContext context) {
        User user = [SELECT Id, Email, Name, Username FROM User WHERE Id = :context.uninstallerID()];
        String toAddress = 'sf.nebula@jongpie.com';
        String[] toAddresses = new String[] {toAddress};

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setReplyTo(user.Email);
        mail.setSenderDisplayName(user.Name);
        mail.setSubject('Nebula Framework Package (version ' + System.requestVersion() +'): uninstalled successfully');
        mail.setPlainTextBody(user.Username + ' (' + user.Email + ') has uninstalled Nebula Framework from org ID' + context.organizationId());
        Messaging.sendEmail(new Messaging.Email[] { mail });
    }

}