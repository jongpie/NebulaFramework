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
    IAggregateResultQueryBuilder groupBy(QueryDate queryDate);
    IAggregateResultQueryBuilder groupBy(Schema.FieldSet fieldSet);
    IAggregateResultQueryBuilder groupBy(Schema.SObjectField groupByField);
    IAggregateResultQueryBuilder groupBy(List<Schema.SObjectField> groupByFields);
    // TODO add support for other features, like 'having count(id) > 1', etc support
    // https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_groupby.htm
    // TODO need to research 'GROUP BY CUBE' & 'GROUPING' more https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_groupby_cube.htm

    // Aggregate functions
    IAggregateResultQueryBuilder avg(Schema.SObjectField sbojectField);
    IAggregateResultQueryBuilder count(Schema.SObjectField sbojectField);
    IAggregateResultQueryBuilder count_distinct(Schema.SObjectField sbojectField);
    IAggregateResultQueryBuilder max(Schema.SObjectField sbojectField);
    IAggregateResultQueryBuilder min(Schema.SObjectField sbojectField);
    IAggregateResultQueryBuilder sum(Schema.SObjectField sbojectField);

    // Filter methods
    IAggregateResultQueryBuilder filterBy(IQueryFilter queryFilter);
    IAggregateResultQueryBuilder filterBy(List<IQueryFilter> queryFilters);

    // Order By methods
    IAggregateResultQueryBuilder orderBy(Schema.SObjectField orderByField);
    IAggregateResultQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder);
    IAggregateResultQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder, QueryNullSortOrder nullsSortOrder);

    // Additional query option methods
    IAggregateResultQueryBuilder limitCount(Integer limitCount);

    // Query execution methods
    List<AggregateResult> getQueryResults();

}