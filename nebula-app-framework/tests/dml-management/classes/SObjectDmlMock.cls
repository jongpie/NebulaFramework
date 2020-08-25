/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
public class SObjectDmlMock {

    public abstract class Base implements ISobjectDml {

        private List<Sobject> insertRecordList = new List<Sobject>();
        private List<Sobject> updateRecordList = new List<Sobject>();
        private List<Sobject> upsertRecordList = new List<Sobject>();
        private List<Sobject> deleteRecordList = new List<Sobject>();
        private List<Sobject> undeleteRecordList = new List<Sobject>();

        public abstract Schema.SobjectType getSobjectType();

        public ISobjectDml setMode(SobjectDml.CrudMode mode) {
            return this;
        }

        public void registerInsertRecords(List<Sobject> recordList) {
            this.insertRecordList.addAll(recordList);
        }

        public void registerUpdateRecords(List<Sobject> recordList) {
            this.updateRecordList.addAll(recordList);
        }

        public void registerUpsertRecords(List<Sobject> recordList) {
            this.upsertRecordList.addAll(recordList);
        }

        public void registerDeleteRecords(List<Sobject> recordList) {
            this.deleteRecordList.addAll(recordList);
        }

        public void registerUndeleteRecords(List<Sobject> recordList) {
            this.undeleteRecordList.addAll(recordList);
        }

        public List<Sobject> getInsertRecords() {
            return this.insertRecordList;
        }

        public List<Sobject> getUpdateRecords() {
            return this.updateRecordList;
        }

        public List<Sobject> getUpsertRecords() {
            return this.upsertRecordList;
        }

        public List<Sobject> getDeleteRecords() {
            return this.deleteRecordList;
        }

        public List<Sobject> getUndeleteRecords() {
            return this.undeleteRecordList;
        }

        // TODO consider changing method name to singular, return type to single Database.SaveResult
        public List<Database.SaveResult> insertRecords(Sobject record) {
            return this.insertRecords(new List<Sobject>{record});
        }

        public List<Database.SaveResult> insertRecords(List<Sobject> recordList) {
            TestUtils.generateIds(recordList);
            TestUtils.insertedRecords.addAll(recordList);
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.SaveResult>();
        }

        public List<Database.SaveResult> updateRecords(Sobject record) {
            this.updateRecords(new List<Sobject>{record});
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.SaveResult>();
        }

        public List<Database.SaveResult> updateRecords(List<Sobject> recordList) {
            TestUtils.updatedRecords.addAll(recordList);
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.SaveResult>();
        }

        public List<Database.UpsertResult> upsertRecords(Sobject record) {
            this.upsertRecords(new List<Sobject>{record});
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.UpsertResult>();
        }

        public List<Database.UpsertResult> upsertRecords(List<Sobject> recordList) {
            TestUtils.generateIds(recordList);
            TestUtils.upsertedRecords.addAll(recordList);
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.UpsertResult>();
        }

        public List<Database.UndeleteResult> undeleteRecords(Sobject record) {
            this.undeleteRecords(new List<Sobject>{record});
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.UndeleteResult>();
        }

        public List<Database.UndeleteResult> undeleteRecords(List<Sobject> recordList) {
            TestUtils.undeletedRecords.addAll(recordList);
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.UndeleteResult>();
        }

        public List<Database.DeleteResult> deleteRecords(Sobject record) {
            this.deleteRecords(new List<Sobject>{record});
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.DeleteResult>();
        }

        public List<Database.DeleteResult> deleteRecords(List<Sobject> recordList) {
            if(recordList != null) TestUtils.deletedRecords.addAll(recordList);
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.DeleteResult>();
        }

        public List<Database.DeleteResult> hardDeleteRecords(Sobject record) {
            this.hardDeleteRecords(new List<Sobject>{record});
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.DeleteResult>();
        }

        public List<Database.DeleteResult> hardDeleteRecords(List<Sobject> recordList) {
            this.deleteRecords(recordList);
            // TODO add logic to try to actually return real results, based on the record list provided
            return new List<Database.DeleteResult>();
        }

    }

    public class ContactDmlMock extends SobjectDmlMock.Base {

        public override Schema.SobjectType getSobjectType() {
            return Schema.Contact.SobjectType;
        }

    }

}