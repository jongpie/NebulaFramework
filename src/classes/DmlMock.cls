/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Repository
*
*/
@isTest
public class DmlMock {

    public abstract class Base implements IDml {
    
        private List<SObject> insertRecordList = new List<SObject>();
        private List<SObject> updateRecordList = new List<SObject>();
        private List<SObject> upsertRecordList = new List<SObject>();
        private List<SObject> deleteRecordList = new List<SObject>();
        private List<SObject> undeleteRecordList = new List<SObject>();

        public abstract Schema.SObjectType getSObjectType();
        
        public void registerInsertRecords(List<SObject> recordList) {
            this.insertRecordList.addAll(recordList);
        }
    
        public void registerUpdateRecords(List<SObject> recordList) {
            this.updateRecordList.addAll(recordList);
        }
    
        public void registerUpsertRecords(List<SObject> recordList) {
            this.upsertRecordList.addAll(recordList);
        }
    
        public void registerDeleteRecords(List<SObject> recordList) {
            this.deleteRecordList.addAll(recordList);
        }
    
        public void registerUndeleteRecords(List<SObject> recordList) {
            this.undeleteRecordList.addAll(recordList);
        }
    
        public List<SObject> getInsertRecords() {
            return this.insertRecordList;
        }
    
        public List<SObject> getUpdateRecords() {
            return this.updateRecordList;
        }
    
        public List<SObject> getUpsertRecords() {
            return this.upsertRecordList;
        }
    
        public List<SObject> getDeleteRecords() {
            return this.deleteRecordList;
        }
    
        public List<SObject> getUndeleteRecords() {
            return this.undeleteRecordList;
        }

        // TODO consider changing method name to singular, return type to single Database.SaveResult
        public List<Database.SaveResult> insertRecords(SObject record) {
            return this.insertRecords(new List<SObject>{record});
        }

        public List<Database.SaveResult> insertRecords(List<SObject> recordList) {
            TestingUtils.generateIds(recordList);
            TestingUtils.insertedRecords.addAll(recordList);
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.SaveResult>();
        }

        public List<Database.SaveResult> updateRecords(SObject record) {
            this.updateRecords(new List<SObject>{record});
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.SaveResult>();
        }

        public List<Database.SaveResult> updateRecords(List<SObject> recordList) {
            TestingUtils.updatedRecords.addAll(recordList);
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.SaveResult>();
        }

        public List<Database.UpsertResult> upsertRecords(SObject record) {
            this.upsertRecords(new List<SObject>{record});
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.UpsertResult>();
        }

        public List<Database.UpsertResult> upsertRecords(List<SObject> recordList) {
            TestingUtils.generateIds(recordList);
            TestingUtils.upsertedRecords.addAll(recordList);
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.UpsertResult>();
        }

        public List<Database.UndeleteResult> undeleteRecords(SObject record) {
            this.undeleteRecords(new List<SObject>{record});
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.UndeleteResult>();
        }

        public List<Database.UndeleteResult> undeleteRecords(List<SObject> recordList) {
            TestingUtils.undeletedRecords.addAll(recordList);
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.UndeleteResult>();
        }

        public List<Database.DeleteResult> deleteRecords(SObject record) {
            this.deleteRecords(new List<SObject>{record});
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.DeleteResult>();
        }

        public List<Database.DeleteResult> deleteRecords(List<SObject> recordList) {
            if(recordList != null) TestingUtils.deletedRecords.addAll(recordList);
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.DeleteResult>();
        }

        public List<Database.DeleteResult> hardDeleteRecords(SObject record) {
            this.hardDeleteRecords(new List<SObject>{record});
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.DeleteResult>();
        }

        public List<Database.DeleteResult> hardDeleteRecords(List<SObject> recordList) {
            this.deleteRecords(recordList);
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.DeleteResult>();
        }

    }

    public class ContactDmlMock extends DmlMock.Base {

        public override Schema.SObjectType getSObjectType() {
            return Schema.Contact.SObjectType;
        }

    }

}