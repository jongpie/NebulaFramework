/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Repository
*
* @description TODO
*
*/
@isTest
public class DMLMock {

    public virtual class Base implements IDML {

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

}