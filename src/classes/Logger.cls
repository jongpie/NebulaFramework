public without sharing class Logger implements ILogger {

    private static Id logId;
    private static Attachment logAttachment;
    private static List<Logger.Message> logMessages;

    public Logger() {
        Logger.logMessages   = Logger.logMessages == null ? new List<Logger.Message>() : Logger.logMessages;
        Logger.logAttachment = Logger.logAttachment == null ? this.createLogAttachment() : Logger.logAttachment;
    }

    public void addEntry(INebulaCore moduleClass, String message) {
        Logger.Message logMessage = new Logger.Message(moduleClass, message);
        Logger.logMessages.add(logMessage);
    }

    public void addEntry(INebulaCore moduleClass, String message, Exception ex) {
        // TODO finish implementing
    }

    public void saveLogs() {
        this.saveTransactionLog();
        this.saveSingleLogFile();
    }

    private void saveTransactionLog() {
        if(Logger.logId != null) return;

        NebulaLog__c newLog = new NebulaLog__c(
            InitialClass__c  = NebulaCore.INITIAL_CLASS,
            InitialModule__c = NebulaCore.INITIAL_MODULE == null ? null : NebulaCore.INITIAL_MODULE.name(),
            TransactionId__c = NebulaCore.TRANSACTION_ID
        );
        insert newLog;
        Logger.logId = newLog.Id;
    }

    private void saveSingleLogFile() {
        String parsedMessageString =
            'NebulaCore.TRANSACTION_ID: ' + NebulaCore.TRANSACTION_ID
            + '\nInitial Class: ' + NebulaCore.INITIAL_CLASS;
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
            Logger.logAttachment.Name = NebulaCore.TRANSACTION_ID;
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
        private NebulaCore.Module classModule;
        private String className;
        private String message;
        private Datetime timestamp;

        public Message(INebulaCore moduleClass, String message) {
            this.classModule = moduleClass.getClassModule();
            this.className   = moduleClass.getClassName();
            this.message     = message;
            this.timestamp   = System.now();
        }
    }

}