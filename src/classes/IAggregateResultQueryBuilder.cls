
/**
*
* @group Query Builder
* @group-content /ApexDocContent/QueryBuilder.html
*
* @description TODO
*/
public interface IAggregateResultQueryBuilder {

    // Getter methods
    String getQuery();

    // Setter methods
    IAggregateResultQueryBuilder setSObjectType(Schema.SObjectType sobjectType);

    IAggregateResultQueryBuilder groupBy(Schema.FieldSet fieldSet);
    IAggregateResultQueryBuilder groupBy(Schema.SObjectField groupByField);
    IAggregateResultQueryBuilder groupBy(List<Schema.SObjectField> groupByFields);
    //IAggregateResultQueryBuilder groupBy(Schema.SObjectField groupByField, String fieldAlias); // TODO dont impl for now - auto'generate all aliases
    List<AggregateResult> getQueryResults();
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
}