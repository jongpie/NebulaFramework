/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface ISobjectRepository {

    // Setup methods
    Schema.SobjectType getSobjectType();
    Soql getSoql();

    // SOQL methods
    Sobject get(Id recordId);
    List<Sobject> get(Set<Id> recordIdList);
    List<Sobject> get(List<Id> recordIdList);
    List<Sobject> get(Soql.QueryFilter queryFilter);
    List<Sobject> get(List<Soql.QueryFilter> queryFilters);
    List<Sobject> get(Set<Id> idSet, List<Soql.QueryFilter> queryFilters);
    List<Sobject> get(List<Id> idList, List<Soql.QueryFilter> queryFilters);

    // SOSL methods
    List<Sobject> search(String searchTerm);
    List<Sobject> search(String searchTerm, Sosl.SearchGroup searchGroup);
    List<Sobject> search(String searchTerm, Sosl.SearchGroup searchGroup, List<Soql.QueryFilter> queryFilters);

}