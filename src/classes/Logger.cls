public without sharing class Logger implements ILogger {

    private static Id logId;
    private static Attachment logAttachment;
    private static List<Logger.Message> logMessages;

    public Logger() {
        Logger.logMessages   = Logger.logMessages == null ? new List<Logger.Message>() : Logger.logMessages;
        Logger.logAttachment = Logger.logAttachment == null ? this.createLogAttachment() : Logger.logAttachment;
    }

    public void addEntry(ICore moduleClass, String message) {
        Logger.Message logMessage = new Logger.Message(moduleClass, message);
        Logger.logMessages.add(logMessage);
    }

    public void addEntry(ICore moduleClass, String message, Exception ex) {
        // TODO finish implementing
    }

    public void saveLogs() {
        this.saveTransactionLog();
        this.saveSingleLogFile();
    }

    private void saveTransactionLog() {
        if(Logger.logId != null) return;

        Log__c newLog = new Log__c(
            InitialClass__c  = Core.INITIAL_CLASS,
            InitialModule__c = Core.INITIAL_MODULE == null ? null : Core.INITIAL_MODULE.name(),
            TransactionId__c = Core.TRANSACTION_ID
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

        if(Logger.logAttachment.Id == null) {
            Logger.logAttachment.Name = Core.TRANSACTION_ID;
            Logger.logAttachment.ParentId = Logger.logId;
        }

        Logger.logAttachment.Body = Blob.valueOf(parsedMessageString);

        upsert Logger.logAttachment;
    }

    private Attachment createLogAttachment() {
        Attachment attachment = new Attachment(
            ContentType = 'text/plain',
            IsPrivate   = false,
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