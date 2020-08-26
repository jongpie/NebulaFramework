/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface IRepository {

    // Setup methods
    Schema.SObjectType getSObjectType();
    Query getQuery();
    RecordSearch getRecordSearch(String searchTerm);

    // SOQL methods
    SObject get(Id recordId);
    List<SObject> get(Set<Id> recordIdList);
    List<SObject> get(List<Id> recordIdList);
    List<SObject> get(Soql.QueryFilter queryFilter);
    List<SObject> get(List<Soql.QueryFilter> queryFilters);
    List<SObject> get(Set<Id> idSet, List<Soql.QueryFilter> queryFilters);
    List<SObject> get(List<Id> idList, List<Soql.QueryFilter> queryFilters);

    // SOSL methods
    List<SObject> search(String searchTerm);
    List<SObject> search(String searchTerm, Sosl.SearchGroup searchGroup);
    List<SObject> search(String searchTerm, Sosl.SearchGroup searchGroup, List<Soql.QueryFilter> queryFilters);

    // DML methods
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