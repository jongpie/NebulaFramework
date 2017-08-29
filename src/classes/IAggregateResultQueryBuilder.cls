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

    // Group By methods
    IAggregateResultQueryBuilder groupBy(IQueryField groupByQueryField);
    IAggregateResultQueryBuilder groupBy(List<IQueryField> groupByQueryFields);
    IAggregateResultQueryBuilder groupBy(Schema.FieldSet fieldSet);
    IAggregateResultQueryBuilder groupBy(QueryDate queryDate);
    // TODO add support for other features, like 'having count(id) > 1', etc support
    // https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_groupby.htm
    // TODO need to research 'GROUP BY CUBE' & 'GROUPING' more https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_groupby_cube.htm

    // Aggregate functions
    IAggregateResultQueryBuilder avg(IQueryField queryField);
    IAggregateResultQueryBuilder avg(IQueryField queryField, String fieldAlias);
    IAggregateResultQueryBuilder count(IQueryField queryField);
    IAggregateResultQueryBuilder count(IQueryField queryField, String fieldAlias);
    IAggregateResultQueryBuilder countDistinct(IQueryField queryField);
    IAggregateResultQueryBuilder countDistinct(IQueryField queryField, String fieldAlias);
    IAggregateResultQueryBuilder max(IQueryField queryField);
    IAggregateResultQueryBuilder max(IQueryField queryField, String fieldAlias);
    IAggregateResultQueryBuilder min(IQueryField queryField);
    IAggregateResultQueryBuilder min(IQueryField queryField, String fieldAlias);
    IAggregateResultQueryBuilder sum(IQueryField queryField);
    IAggregateResultQueryBuilder sum(IQueryField queryField, String fieldAlias);

    // Filter methods
    IAggregateResultQueryBuilder filterBy(IQueryFilter queryFilter);
    IAggregateResultQueryBuilder filterBy(List<IQueryFilter> queryFilters);

    // Order By methods
    IAggregateResultQueryBuilder orderBy(IQueryField orderByQueryField);
    IAggregateResultQueryBuilder orderBy(IQueryField orderByQueryField, QuerySortOrder sortOrder);
    IAggregateResultQueryBuilder orderBy(IQueryField orderByQueryField, QuerySortOrder sortOrder, QueryNullSortOrder nullsSortOrder);

    // Additional query option methods
    IAggregateResultQueryBuilder limitCount(Integer limitCount);

    // Query string methods
    String getQuery();

    // Query execution methods
    AggregateResult getFirstQueryResult();
    List<AggregateResult> getQueryResults();

}