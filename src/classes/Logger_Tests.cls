/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class Logger_Tests {

    private class FakeNebulaClass extends NebulaCore {}

    @isTest
    static void it_should_add_entry_for_a_message_string() {
        String message = 'my test message';
        System.assert(Logger.logMessages.isEmpty());

        Test.startTest();
        Logger.addEntry(message);
        Test.stopTest();

        System.assertEquals(null, Logger.logMessages[0].ClassModule);
        System.assertEquals(null, Logger.logMessages[0].ClassName);
        System.assertEquals(message, Logger.logMessages[0].Message);
    }

    @isTest
    static void it_should_add_entry_for_a_module_class_and_a_message_string() {
        FakeNebulaClass moduleClass = new FakeNebulaClass();
        String message = 'my test message';
        System.assert(Logger.logMessages.isEmpty());

        Test.startTest();
        Logger.addEntry(moduleClass, message);
        Test.stopTest();

        System.assertEquals(moduleClass.getClassModule(), Logger.logMessages[0].ClassModule);
        System.assertEquals(moduleClass.getClassName(), Logger.logMessages[0].ClassName);
        System.assertEquals(message, Logger.logMessages[0].Message);
    }

    @isTest
    static void it_should_add_entry_for_a_module_class_and_an_exception_and_a_message_string() {
        FakeNebulaClass moduleClass = new FakeNebulaClass();
        String message = 'my test message';
        System.assert(Logger.logMessages.isEmpty());

        Test.startTest();
        Logger.addEntry(moduleClass, message);
        Test.stopTest();

        System.assertEquals(moduleClass.getClassModule(), Logger.logMessages[0].ClassModule);
        System.assertEquals(moduleClass.getClassName(), Logger.logMessages[0].ClassName);
        System.assertEquals(message, Logger.logMessages[0].Message);
    }

    @isTest
    static void it_should_save_logs_when_logging_is_enabled() {
        FakeNebulaClass moduleClass = new FakeNebulaClass();
        String message = 'my test message';
        System.assert(Logger.logMessages.isEmpty());
        List<NebulaLog__c> existingLogs = [SELECT Id FROM NebulaLog__c];
        System.assert(existingLogs.isEmpty());

        // Enable logging
        NebulaLoggerSettings__c nebulaLoggerSettings = NebulaLoggerSettings__c.getInstance();
        nebulaLoggerSettings.EnableLogging__c = true;
        upsert nebulaLoggerSettings;

        Logger.addEntry(moduleClass, message);

        Test.startTest();
        String transactionId = NebulaCore.TRANSACTION_ID;
        Logger.saveLogs();
        Test.stopTest();

        List<NebulaLog__c> logs = [SELECT Id, TransactionId__c FROM NebulaLog__c];
        System.assertEquals(1, logs.size());
        System.assertEquals(transactionId, logs[0].TransactionId__c);

        List<Attachment> logAttachments = [SELECT Id, Name, ParentId, ContentType, IsPrivate, Body FROM Attachment WHERE ParentId = :logs[0].Id];
        System.assertEquals(1, logAttachments.size());
        System.assertEquals(transactionId, logAttachments[0].Name);
        System.assertEquals('text/plain', logAttachments[0].ContentType);
        System.assertEquals(false, logAttachments[0].IsPrivate);
        String attachmentBody = logAttachments[0].Body.toString();
        System.assert(attachmentBody.contains(message), attachmentBody);
    }

    @isTest
    static void it_should_not_save_logs_when_logging_is_disabled() {
        FakeNebulaClass moduleClass = new FakeNebulaClass();
        String message = 'my test message';
        System.assert(Logger.logMessages.isEmpty());
        List<NebulaLog__c> existingLogs = [SELECT Id FROM NebulaLog__c];
        System.assert(existingLogs.isEmpty());

        // Disable logging
        NebulaLoggerSettings__c nebulaLoggerSettings = NebulaLoggerSettings__c.getInstance();
        nebulaLoggerSettings.EnableLogging__c = false;
        upsert nebulaLoggerSettings;

        Logger.addEntry(moduleClass, message);

        Test.startTest();
        String transactionId = NebulaCore.TRANSACTION_ID;
        Logger.saveLogs();
        Test.stopTest();

        List<NebulaLog__c> logs = [SELECT Id, TransactionId__c FROM NebulaLog__c];
        System.assertEquals(0, logs.size());
    }

}