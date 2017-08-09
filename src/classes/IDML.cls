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
public interface IDML {

    void insertRecords(SObject record);
    void insertRecords(List<SObject> recordList);
    void updateRecords(SObject record);
    void updateRecords(List<SObject> recordList);
    void upsertRecords(SObject record);
    void upsertRecords(List<SObject> recordList);
    void undeleteRecords(SObject record);
    void undeleteRecords(List<SObject> recordList);
    void deleteRecords(SObject record);
    void deleteRecords(List<SObject> recordList);
    void hardDeleteRecords(SObject record);
    void hardDeleteRecords(List<SObject> recordList);

}