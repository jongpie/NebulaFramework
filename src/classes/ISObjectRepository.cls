/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface ISObjectRepository {

    // SOQL
    SObject getById(Id recordId);
    List<SObject> getById(List<Id> recordIdList);
    List<SObject> get(QueryFilter queryFilter);
    List<SObject> get(List<QueryFilter> queryFilters);
    List<SObject> getByFieldForIds(Schema.SObjectField field, Object value, List<Id> idList);
    List<SObject> getByFieldForIds(Schema.SObjectField field, Object value, Set<Id> idSet);
    List<SObject> getCreatedSince(Object dateOrDatetime);

    // SOSL
    List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup);

}