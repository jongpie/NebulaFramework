/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface IQueryBuilder {

    // SOQL builder methods
    IQueryBuilder filterBy(QueryPredicate2 queryPredicate);
    IQueryBuilder filterBy(List<QueryPredicate2> queryPredicates);
    IQueryBuilder whereField(List<QueryPredicate> queryPredicates);
    IQueryBuilder whereField(Schema.SobjectField field, QueryOperator operator, Object value);

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