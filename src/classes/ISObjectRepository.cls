/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface ISObjectRepository {

    // Manipulate queries without executing them
    ISObjectRepository filterBy(IQueryFilter queryFilter);
    ISObjectRepository filterBy(List<IQueryFilter> queryFilters);

    // SOQL
    SObject getById(Id recordId);
    List<SObject> getById(List<Id> recordIdList);
    List<SObject> get(IQueryFilter queryFilter);
    List<SObject> get(List<IQueryFilter> queryFilters);
    List<SObject> getByFieldForIds(Schema.SObjectField field, Object value, List<Id> idList);
    List<SObject> getByFieldForIds(Schema.SObjectField field, Object value, Set<Id> idSet);

    // SOSL
    List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup);

    // Additional methods
    IQueryBuilder getQueryBuilder();

}