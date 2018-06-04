/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface ISobjectRepository {

    // Setup methods
    Schema.SobjectType getSobjectType();

    // SOQL
    Sobject getById(Id recordId);
    List<Sobject> getById(List<Id> recordIdList);
    List<Sobject> get(Soql.QueryFilter queryFilter);
    List<Sobject> get(List<Soql.QueryFilter> queryFilters);
    List<Sobject> getByIdAndQueryFilters(Set<Id> idSet, List<Soql.QueryFilter> queryFilters);
    List<Sobject> getByIdAndQueryFilters(List<Id> idList, List<Soql.QueryFilter> queryFilters);

    // SOSL
    List<Sobject> getSearchResults(String searchTerm);
    List<Sobject> getSearchResults(String searchTerm, Sosl.SearchGroup searchGroup);
    List<Sobject> getSearchResults(String searchTerm, Sosl.SearchGroup searchGroup, List<Soql.QueryFilter> queryFilters);

}