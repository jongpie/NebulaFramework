/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public without sharing class Logger {

    private Logger() {}

    private static Id logId;
    private static Attachment logAttachment;
    @testVisible private static List<Logger.Message> logMessages;

    static {
        Logger.logMessages   = Logger.logMessages == null ? new List<Logger.Message>() : Logger.logMessages;
        Logger.logAttachment = Logger.logAttachment == null ? createLogAttachment() : Logger.logAttachment;
    }

    public static void addEntry(String message) {
        addEntry(null, message);
    }

    public static void addEntry(INebulaCore moduleClass, String message) {
        Logger.Message logMessage = new Logger.Message(moduleClass, message);
        Logger.logMessages.add(logMessage);
    }

    public static void saveLogs() {
        if(!NebulaSettings.loggerSettings.EnableLogging__c) return;

        saveTransactionLog();
        saveSingleLogFile();
    }

    private static void saveTransactionLog() {
        if(Logger.logId != null) return;

        NebulaLog__c newLog = new NebulaLog__c(
            InitialClass__c  = NebulaCore.INITIAL_CLASS,
            TransactionId__c = NebulaCore.TRANSACTION_ID
        );
        insert newLog;
        Logger.logId = newLog.Id;
    }

    private static void saveSingleLogFile() {
        String parsedMessageString =
            'NebulaCore.TRANSACTION_ID: ' + NebulaCore.TRANSACTION_ID
            + '\nInitial Class: ' + NebulaCore.INITIAL_CLASS;
        String divider = '\n______________________________\n';

        for(Logger.Message logMessage : logMessages) {
            parsedMessageString =
                parsedMessageString
                + divider
                + '\nCurrent Module: ' + logMessage.ClassModule
                + '\nCurrent Class: ' + logMessage.ClassName
                + '\nTimestamp: ' + logMessage.Timestamp.format('yyyy-MM-dd_hh:mm:ss.SS')
                + '\n\n' + logMessage.Message;
        }

        if(Logger.logAttachment.Id == null) {
            Logger.logAttachment.Name = NebulaCore.TRANSACTION_ID;
            Logger.logAttachment.ParentId = Logger.logId;
        }

        Logger.logAttachment.Body = Blob.valueOf(parsedMessageString);

        upsert Logger.logAttachment;
    }

    private static Attachment createLogAttachment() {
        Attachment attachment = new Attachment(
            ContentType = 'text/plain',
            IsPrivate   = false,
            ParentId    = Logger.logId
        );

        return attachment;
    }

    private class Message {
        public NebulaCore.Module ClassModule {get; private set;}
        public String ClassName {get; private set;}
        public String Message {get; private set;}
        public Datetime Timestamp {get; private set;}

        public Message(INebulaCore moduleClass, String message) {
            this.ClassModule = moduleClass == null ? null : moduleClass.getClassModule();
            this.ClassName   = moduleClass == null ? null : moduleClass.getClassName();
            this.Message     = message;
            this.Timestamp   = System.now();
        }
    }

}