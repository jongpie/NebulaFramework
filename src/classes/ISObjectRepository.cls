/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface ISObjectRepository {

    // Setup methods
    Schema.SObjectType getSObjectType();

    // SOQL
    SObject getById(Id recordId);
    List<SObject> getById(List<Id> recordIdList);
    List<SObject> get(IQueryFilter queryFilter);
    List<SObject> get(List<IQueryFilter> queryFilters);
    List<SObject> getByIdAndQueryFilters(Set<Id> idSet, List<IQueryFilter> queryFilters);
    List<SObject> getByIdAndQueryFilters(List<Id> idList, List<IQueryFilter> queryFilters);

    // SOSL
    List<SObject> getSearchResults(String searchTerm);
    List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup);
    List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup, List<IQueryFilter> queryFilters);

    // Additional methods
    ISObjectQueryBuilder getQueryBuilder();

}