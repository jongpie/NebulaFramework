/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface IDml {

    Schema.SobjectType getSobjectType();

    void registerInsertRecords(List<Sobject> recordList);
    void registerUpdateRecords(List<Sobject> recordList);
    void registerUpsertRecords(List<Sobject> recordList);
    void registerDeleteRecords(List<Sobject> recordList);
    void registerUndeleteRecords(List<Sobject> recordList);
    List<Sobject> getInsertRecords();
    List<Sobject> getUpdateRecords();
    List<Sobject> getUpsertRecords();
    List<Sobject> getDeleteRecords();
    List<Sobject> getUndeleteRecords();

    List<Database.SaveResult> insertRecords(Sobject record);
    List<Database.SaveResult> insertRecords(List<Sobject> recordList);
    List<Database.SaveResult> updateRecords(Sobject record);
    List<Database.SaveResult> updateRecords(List<Sobject> recordList);
    List<Database.UpsertResult> upsertRecords(Sobject record);
    List<Database.UpsertResult> upsertRecords(List<Sobject> recordList);
    List<Database.UndeleteResult> undeleteRecords(Sobject record);
    List<Database.UndeleteResult> undeleteRecords(List<Sobject> recordList);
    List<Database.DeleteResult> deleteRecords(Sobject record);
    List<Database.DeleteResult> deleteRecords(List<Sobject> recordList);
    List<Database.DeleteResult> hardDeleteRecords(Sobject record);
    List<Database.DeleteResult> hardDeleteRecords(List<Sobject> recordList);

}