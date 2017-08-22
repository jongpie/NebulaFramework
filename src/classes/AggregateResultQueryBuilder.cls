/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.              *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Query Builder
*
* @description A builder class that generates dynamic queries & returns a list of AggregateResult
*
*/
public class AggregateResultQueryBuilder extends QueryBuilder implements IAggregateResultQueryBuilder {

    private Schema.SObjectType sobjectType;
    private List<String> groupByList;
    private List<String> aggregateFunctionList;

    public AggregateResultQueryBuilder() {
        this.aggregateFunctionList = new List<String>();
        this.groupByList           = new List<String>();
    }

    // Setter methods
    public IAggregateResultQueryBuilder setSObjectType(Schema.SObjectType sobjectType) {
        this.sobjectType = sobjectType;
        return this;
    }

    public IAggregateResultQueryBuilder groupBy(QueryDate queryDate) {
        this.groupByList.add(queryDate.getValue());
        return this;
    }

    public IAggregateResultQueryBuilder groupBy(Schema.FieldSet fieldSet) {
        for(Schema.FieldSetMember field : fieldSet.getFields()) this.groupByList.add(field.getFieldPath());
        return this;
    }

    public IAggregateResultQueryBuilder groupBy(QueryField groupByQueryField) {
        return this.groupBy(new List<QueryField>{groupByQueryField});
    }

    public IAggregateResultQueryBuilder groupBy(List<QueryField> groupByQueryFields) {
        for(QueryField queryField : groupByQueryFields) this.groupByList.add(queryField.getValue());
        return this;
    }

    /**
    * @description Adds the average value of the numeric field to the dynamically generated aggregate query
    * @param numericSObjectField The field to use for calculating the average
    * @return The instance of IAggregateResultQueryBuilder, to allow chaining methods
    */
    public IAggregateResultQueryBuilder avg(Schema.SObjectField numericSObjectField) {
        return buildAggregateFunction('AVG', numericSObjectField);
    }

    public IAggregateResultQueryBuilder count(Schema.SObjectField sobjectField) {
        return buildAggregateFunction('COUNT', sobjectField);
    }

    public IAggregateResultQueryBuilder count_distinct(Schema.SObjectField sobjectField) {
        return buildAggregateFunction('COUNT_DISTINCT', sobjectField);
    }

    /**
    * @description Adds the maximum value of the field to the dynamically generated aggregate query
    * @param sobjectField The field to use for calculating the maximum
    * @return The instance of IAggregateResultQueryBuilder, to allow chaining methods
    */
    public IAggregateResultQueryBuilder max(Schema.SObjectField sobjectField) {
        return buildAggregateFunction('MAX', sobjectField);
    }

    /**
    * @description Adds the minimum value of the field to the dynamically generated aggregate query
    * @param sobjectField The field to use for calculating the minimum
    * @return The instance of IAggregateResultQueryBuilder, to allow chaining methods
    */
    public IAggregateResultQueryBuilder min(Schema.SObjectField sobjectField) {
        return buildAggregateFunction('MIN', sobjectField);
    }

    /**
    * @description Sums the values of the supplied numeric field to the dynamically generated aggregate query
    * @param numericSObjectField The field to use for calculating the minimum
    * @return The instance of IAggregateResultQueryBuilder, to allow chaining methods
    */
    public IAggregateResultQueryBuilder sum(Schema.SObjectField numericSObjectField) {
        return buildAggregateFunction('SUM', numericSObjectField);
    }

    public IAggregateResultQueryBuilder filterBy(IQueryFilter queryFilter) {
        super.doFilterBy(queryFilter);
        return this;
    }

    public IAggregateResultQueryBuilder filterBy(List<IQueryFilter> queryFilters) {
        super.doFilterBy(queryFilters);
        return this;
    }

    public IAggregateResultQueryBuilder orderBy(QueryField orderByQueryField) {
        super.doOrderBy(orderByQueryField);
        return this;
    }

    public IAggregateResultQueryBuilder orderBy(QueryField orderByQueryField, QuerySortOrder sortOrder) {
        super.doOrderBy(orderByQueryField, sortOrder);
        return this;
    }

    public IAggregateResultQueryBuilder orderBy(QueryField orderByQueryField, QuerySortOrder sortOrder, QueryNullSortOrder nullsSortOrder) {
        super.doOrderBy(orderByQueryField, sortOrder, nullsSortOrder);
        return this;
    }

    public IAggregateResultQueryBuilder limitCount(Integer limitCount) {
        super.doLimitCount(limitCount);
        return this;
    }

    public AggregateResult getFirstQueryResult() {
        return this.getQueryResults()[0];
    }

    public List<AggregateResult> getQueryResults() {
        return super.doGetQueryResults(this.getQuery());
    }

    @testVisible
    private String getQuery() {
        String queryString = 'SELECT ' + this.getGroupByFieldString() + this.getAggregateFunctionString()
            + '\nFROM ' + this.sobjectType.getDescribe().getName()
            + super.doGetWhereClauseString()
            + '\nGROUP BY ' + this.getGroupByFieldString()
            + super.doGetOrderByString()
            + super.doGetLimitCountString();

        return queryString;
    }

    private String getGroupByFieldString() {
        return String.join(this.groupByList, ', ');
    }

    private String getAggregateFunctionString() {
        this.aggregateFunctionList.sort();
        // The extra delimiter adds a comma when needed for grouping by fields & aggregate functions
        // Example: 'Type, COUNT_DISTINCT(OwnerId)'
        String extraDelimiter = getGroupByFieldString() == null ? '' : ',\n';
        return extraDelimiter + String.join(this.aggregateFunctionList, ', ');
    }

    private IAggregateResultQueryBuilder buildAggregateFunction(String functionName, Schema.SObjectField sobjectField) {
        String fieldName = sobjectField.getDescribe().getName();
        // Alias: MIN(Schema.Lead.MyField__c) is auto-aliased to MIN_MyField__c
        this.aggregateFunctionList.add(functionName + '(' + fieldName + ') ' + functionName + '__' + fieldName);
        return this;
    }

}