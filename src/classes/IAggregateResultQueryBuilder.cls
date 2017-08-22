/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Query Builder
*
* @description TODO
*
*/
public interface IAggregateResultQueryBuilder {

    // Setter methods
    IAggregateResultQueryBuilder setSObjectType(Schema.SObjectType sobjectType);

    // Group By methods
    IAggregateResultQueryBuilder groupBy(QueryField groupByQueryField);
    IAggregateResultQueryBuilder groupBy(List<QueryField> groupByQueryFields);
    IAggregateResultQueryBuilder groupBy(Schema.FieldSet fieldSet);
    IAggregateResultQueryBuilder groupBy(QueryDate queryDate);
    // TODO add support for other features, like 'having count(id) > 1', etc support
    // https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_groupby.htm
    // TODO need to research 'GROUP BY CUBE' & 'GROUPING' more https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_groupby_cube.htm

    // Aggregate functions
    IAggregateResultQueryBuilder avg(QueryField queryField);
    IAggregateResultQueryBuilder avg(QueryField queryField, String fieldAlias);
    IAggregateResultQueryBuilder count(QueryField queryField);
    IAggregateResultQueryBuilder count(QueryField queryField, String fieldAlias);
    IAggregateResultQueryBuilder count_distinct(QueryField queryField);
    IAggregateResultQueryBuilder count_distinct(QueryField queryField, String fieldAlias);
    IAggregateResultQueryBuilder max(QueryField queryField);
    IAggregateResultQueryBuilder max(QueryField queryField, String fieldAlias);
    IAggregateResultQueryBuilder min(QueryField queryField);
    IAggregateResultQueryBuilder min(QueryField queryField, String fieldAlias);
    IAggregateResultQueryBuilder sum(QueryField queryField);
    IAggregateResultQueryBuilder sum(QueryField queryField, String fieldAlias);

    // Filter methods
    IAggregateResultQueryBuilder filterBy(IQueryFilter queryFilter);
    IAggregateResultQueryBuilder filterBy(List<IQueryFilter> queryFilters);

    // Order By methods
    IAggregateResultQueryBuilder orderBy(QueryField orderByQueryField);
    IAggregateResultQueryBuilder orderBy(QueryField orderByQueryField, QuerySortOrder sortOrder);
    IAggregateResultQueryBuilder orderBy(QueryField orderByQueryField, QuerySortOrder sortOrder, QueryNullSortOrder nullsSortOrder);

    // Additional query option methods
    IAggregateResultQueryBuilder limitCount(Integer limitCount);

    // Query execution methods
    List<AggregateResult> getQueryResults();

}