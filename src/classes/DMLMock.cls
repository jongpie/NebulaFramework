/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public virtual class DMLMock implements IDML {

    public SObject doInsert(SObject record) { return this.doInsert(new List<SObject>{record})[0]; }
    public List<SObject> doInsert(List<SObject> recordList) {
        TestingUtils.generateIds(recordList);
        TestingUtils.insertedRecords.addAll(recordList);
        return recordList;
    }

    public SObject doUpdate(SObject record) { return this.doUpdate(new List<SObject>{record})[0]; }
    public List<SObject> doUpdate(List<SObject> recordList) {
        TestingUtils.updatedRecords.addAll(recordList);
        return recordList;
    }

    public SObject doUpsert(SObject record) { return this.doUpsert(new List<SObject>{record})[0]; }
    public List<SObject> doUpsert(List<SObject> recordList) {
        TestingUtils.generateIds(recordList);
        TestingUtils.upsertedRecords.addAll(recordList);
        return recordList;
    }

    public SObject doUndelete(SObject record) { return this.doUndelete(new List<SObject>{record})[0]; }
    public List<SObject> doUndelete(List<SObject> recordList) {
        TestingUtils.undeletedRecords.addAll(recordList);
        return recordList;
    }

    public void doDelete(SObject record) { this.doDelete(new List<SObject>{record}); }
    public void doDelete(List<SObject> recordList) {
        if(recordList != null) TestingUtils.deletedRecords.addAll(recordList);
    }

    public void doHardDelete(SObject record) { this.doHardDelete(new List<SObject>{record}); }
    public void doHardDelete(List<SObject> recordList) { this.doDelete(recordList); }

}