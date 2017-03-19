/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface ISObjectRepository {

    // SOQL
    SObject getById(Id recordId);
    List<SObject> getById(List<Id> recordIdList);

    // SOSL
    List<SObject> searchInAllFields(String searchTerm);
    List<SObject> searchInFieldsBySearchGroup(String searchTerm, QuerySearchGroup searchGroup);

    // DML
    void doInsert(SObject record);
    void doInsert(List<SObject> recordList);
    void doUpdate(SObject record);
    void doUpdate(List<SObject> recordList);
    void doUpsert(SObject record);
    void doUpsert(List<SObject> recordList);
    void doDelete(SObject record);
    void doDelete(List<SObject> recordList);
    void doHardDelete(SObject record);
    void doHardDelete(List<SObject> recordList);
    void doUndelete(SObject record);
    void doUndelete(List<SObject> recordList);
}