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

    List<Database.SaveResult> insertRecords(SObject record);
    List<Database.SaveResult> insertRecords(List<SObject> recordList);
    List<Database.SaveResult> updateRecords(SObject record);
    List<Database.SaveResult> updateRecords(List<SObject> recordList);
    List<Database.UpsertResult> upsertRecords(SObject record);
    List<Database.UpsertResult> upsertRecords(List<SObject> recordList);
    List<Database.UndeleteResult> undeleteRecords(SObject record);
    List<Database.UndeleteResult> undeleteRecords(List<SObject> recordList);
    List<Database.DeleteResult> deleteRecords(SObject record);
    List<Database.DeleteResult> deleteRecords(List<SObject> recordList);
    List<Database.DeleteResult> hardDeleteRecords(SObject record);
    List<Database.DeleteResult> hardDeleteRecords(List<SObject> recordList);

}