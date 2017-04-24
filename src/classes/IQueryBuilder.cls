/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface IQueryBuilder {

    // SOQL buildermethods
    IQueryBuilder whereField(List<QueryPredicate> queryPredicates);
    IQueryBuilder whereField(Schema.SobjectField field, QueryOperator operator, Object value);
    IQueryBuilder whereField(Schema.SObjectField field, QueryOperator operator, List<Object> valueList);

    IQueryBuilder orderBy(Schema.SObjectField orderByField);
    IQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder);
    IQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder, QueryNullSortOrder nullsSortOrder);

    IQueryBuilder limitCount(Integer limitCount);
    IQueryBuilder setAsUpdate();
    IQueryBuilder usingScope();

    // Query execution methods
    SObject getFirstOrDefault();
    List<SObject> getQueryResults();
    List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup);
}