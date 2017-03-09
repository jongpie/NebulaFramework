public without sharing class Logger implements ILogger {

    private static Id logId;
    private static Attachment logAttachment;
    private static List<Logger.Message> logMessages;
    private static Integer loopCount = 0; //TODO eliminate pls ohgawd im sorry

    public Logger() {
        Logger.logMessages = Logger.logMessages == null ? new List<Logger.Message>() : Logger.logMessages;
        Logger.logAttachment = Logger.logAttachment == null ? this.createLogAttachment() : Logger.logAttachment;
        System.debug('Logger intialized');

        //this.saveTransactionLog();
    }

/*    public void addMessage(ICore moduleClass, String message) {
        this.addMessage(moduleClass, message, null);
    }*/

    public void addEntry(ICore moduleClass, String message) {
        if(moduleClass.getClassName() == 'LogTriggerHandler') return;

        Logger.Message logMessage = new Logger.Message(moduleClass, message);
        Logger.logMessages.add(logMessage);
    }

    public void addEntry(ICore moduleClass, String message, Exception ex) {

    }

    public void saveLogs() {
        System.debug('Logger.loopCount =' + Logger.loopCount);
        //if(Logger.loopCount == 2) return;
        if(Logger.logMessages.isEmpty()) return;
        if(Logger.logAttachment == null) return;

        this.saveTransactionLog();
        this.saveSingleLogFile();

        Logger.loopCount++;
        //system.assert(false, Logger.log);
        //this.saveSingleLogFile();
    }

    private void saveTransactionLog() {
        if(Logger.logId != null) return;

        //String repositorySettingsJson = JSON.serialize(RepositorySettings__c.getInstance()).replace(',', ', ').replace(':', ': ');

        Log__c newLog = new Log__c(
            InitialClass__c       = Core.INITIAL_CLASS,
            //RepositorySettings__c = repositorySettingsJson,
            TransactionId__c      = Core.TRANSACTION_ID
        );
        insert newLog;
        Logger.logId = newLog.Id;
    }

    private void saveSingleLogFile() {
        String parsedMessageString =
            'Core.TRANSACTION_ID: ' + Core.TRANSACTION_ID
            + '\nInitial Class: ' + Core.INITIAL_CLASS;
        String divider = '\n______________________________\n';

        for(Logger.Message logMessage : logMessages) {
            parsedMessageString =
                parsedMessageString
                + divider
                + '\nCurrent Module: ' + logMessage.classModule
                + '\nCurrent Class: ' + logMessage.className
                + '\nTimestamp: ' + logMessage.timestamp.format('yyyy-MM-dd_hh:mm:ss.SS')
                + '\n\n' + logMessage.message;
        }

        //if(Logger.log != null && Logger.log.Id == null) insert Logger.log;

        //Attachment singleAttachment = this.createLogAttachment(parsedMessageString);
        if(Logger.logAttachment.Id == null) {
            Logger.logAttachment.Name = Core.TRANSACTION_ID;
            Logger.logAttachment.ParentId = Logger.logId;
        }
        Logger.logAttachment.Body = Blob.valueOf(parsedMessageString);
//System.debug('derp');
//system.assert(false, Logger.log);
        upsert Logger.logAttachment;
    }

    private Attachment createLogAttachment() {
        //String filenamePrefix = timestamp.format('yyyy-MM-dd_hh:mm:ss.SS') + '_' + moduleClass.getClassName();

        String contentType = 'text/plain';
        //String filename = filenamePrefix + '.log';

        Attachment attachment = new Attachment(
            //Body        = Blob.valueOf(message),
            ContentType = contentType,
            IsPrivate   = false,
            //Name        = filename,
            ParentId    = Logger.logId
        );

        return attachment;
    }

    private class Message {
        private Core.Module classModule;
        private String className;
        private String message;
        private Datetime timestamp;

        public Message(ICore moduleClass, String message) {
            this.classModule = moduleClass.getClassModule();
            this.className   = moduleClass.getClassName();
            this.message     = message;
            this.timestamp   = System.now();
        }
    }

}