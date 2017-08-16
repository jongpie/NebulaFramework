/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Query Builder
* @group-content /ApexDocContent/QueryBuilder.html
*
* @description TODO
*
*/
public interface IAggregateResultQueryBuilder {

    // Setter methods
    IAggregateResultQueryBuilder setSObjectType(Schema.SObjectType sobjectType);

    // Group By methods
    IAggregateResultQueryBuilder groupBy(Schema.FieldSet fieldSet);
    IAggregateResultQueryBuilder groupBy(Schema.SObjectField groupByField);
    IAggregateResultQueryBuilder groupBy(List<Schema.SObjectField> groupByFields);


//methods for all the aggregate functions - https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_agg_functions.htm
    // Aggregate functions
    IAggregateResultQueryBuilder avg(Schema.SObjectField sbojectField);
    IAggregateResultQueryBuilder count_distinct(Schema.SObjectField sbojectField);
    IAggregateResultQueryBuilder count();
    IAggregateResultQueryBuilder count(Schema.SObjectField sbojectField);
    IAggregateResultQueryBuilder max(Schema.SObjectField sbojectField);
    IAggregateResultQueryBuilder min(Schema.SObjectField sbojectField);
    IAggregateResultQueryBuilder sum(Schema.SObjectField sbojectField);
// group by rollup, having(blah), etc support - https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_groupby.htm
//need to research 'GROUP BY CUBE' & 'GROUPING' more https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_groupby_cube.htm

    // Query execution methods
    List<AggregateResult> getQueryResults();

}