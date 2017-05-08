/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface IDML {
    // DML
    SObject doInsert(SObject record);
    List<SObject> doInsert(List<SObject> recordList);
    SObject doUpdate(SObject record);
    List<SObject> doUpdate(List<SObject> recordList);
    SObject doUpsert(SObject record);
    List<SObject> doUpsert(List<SObject> recordList);
    SObject doUndelete(SObject record);
    List<SObject> doUndelete(List<SObject> recordList);

    void doDelete(SObject record);
    void doDelete(List<SObject> recordList);
    void doHardDelete(SObject record);
    void doHardDelete(List<SObject> recordList);
}