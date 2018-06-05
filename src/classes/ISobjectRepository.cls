/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface ISobjectRepository {

    // Setup methods
    Schema.SobjectType getSobjectType();
    Soql getSoql();

    // SOQL methods
    Sobject query(Id recordId);
    List<Sobject> query(Set<Id> recordIdList);
    List<Sobject> query(List<Id> recordIdList);
    List<Sobject> query(Soql.QueryFilter queryFilter);
    List<Sobject> query(List<Soql.QueryFilter> queryFilters);
    List<Sobject> query(Set<Id> idSet, List<Soql.QueryFilter> queryFilters);
    List<Sobject> query(List<Id> idList, List<Soql.QueryFilter> queryFilters);

    // SOSL methods
    List<Sobject> search(String searchTerm);
    List<Sobject> search(String searchTerm, Sosl.SearchGroup searchGroup);
    List<Sobject> search(String searchTerm, Sosl.SearchGroup searchGroup, List<Soql.QueryFilter> queryFilters);

}