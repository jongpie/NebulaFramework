/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface ISObjectRepository {

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

    // Setter methods
    //void set(SObject record, Schema.SObjectField field, Object value);
    //void set(List<SObject> records, Schema.SObjectField field, Object value);

    // SOSL methods
    List<SObject> search(String searchTerm);
    List<SObject> search(String searchTerm, Sosl.SearchGroup searchGroup);
    List<SObject> search(String searchTerm, Sosl.SearchGroup searchGroup, List<Soql.QueryFilter> queryFilters);

}