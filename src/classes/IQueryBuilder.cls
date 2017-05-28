/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface IQueryBuilder {

    // Query builder methods
    IQueryBuilder filterBy(QueryFilter queryFilter);
    IQueryBuilder filterBy(List<QueryFilter> queryFilters);

    IQueryBuilder includeChildRecords(Schema.SObjectField childToParentRelationshipField, IQueryBuilder childSObjectQueryBuilder);
    IQueryBuilder includeChildRecords(Map<Schema.SObjectField, IQueryBuilder> childFieldToChildSObjectQueryBuilderMap);

    IQueryBuilder orderBy(Schema.SObjectField orderByField);
    IQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder);
    IQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder, QueryNullSortOrder nullsSortOrder);

    IQueryBuilder limitCount(Integer limitCount);
    IQueryBuilder setAsUpdate();
    IQueryBuilder usingScope(QueryFilterScope filterScope);

    // Query execution methods
    SObject getFirstQueryResult();
    List<SObject> getQueryResults();
    List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup);

    // Get those fancy dyanmic query strings
    String getQuery();
    String getQuery(Schema.SObjectField sobjectField);

}