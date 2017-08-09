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

        public void insertRecords(SObject record) {
            this.insertRecords(new List<SObject>{record});
        }

        public void insertRecords(List<SObject> recordList) {
            TestingUtils.generateIds(recordList);
            TestingUtils.insertedRecords.addAll(recordList);
        }

        public void updateRecords(SObject record) {
            this.updateRecords(new List<SObject>{record});
        }

        public void updateRecords(List<SObject> recordList) {
            TestingUtils.updatedRecords.addAll(recordList);
        }

        public void upsertRecords(SObject record) {
            this.upsertRecords(new List<SObject>{record});
        }

        public void upsertRecords(List<SObject> recordList) {
            TestingUtils.generateIds(recordList);
            TestingUtils.upsertedRecords.addAll(recordList);
        }

        public void undeleteRecords(SObject record) {
            this.undeleteRecords(new List<SObject>{record});
        }

        public void undeleteRecords(List<SObject> recordList) {
            TestingUtils.undeletedRecords.addAll(recordList);
        }

        public void deleteRecords(SObject record) {
            this.deleteRecords(new List<SObject>{record});
        }

        public void deleteRecords(List<SObject> recordList) {
            if(recordList != null) TestingUtils.deletedRecords.addAll(recordList);
        }

        public void hardDeleteRecords(SObject record) {
            this.hardDeleteRecords(new List<SObject>{record});
        }

        public void hardDeleteRecords(List<SObject> recordList) {
            this.deleteRecords(recordList);
        }

    }

}