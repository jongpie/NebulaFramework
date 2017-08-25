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

    public AggregateResultQueryBuilder(Schema.SObjectType sobjectType) {
        this.sobjectType = sobjectType;

        this.aggregateFunctionList = new List<String>();
        this.groupByList           = new List<String>();
    }

    public IAggregateResultQueryBuilder groupBy(QueryField groupByQueryField) {
        return this.groupBy(new List<QueryField>{groupByQueryField});
    }

    public IAggregateResultQueryBuilder groupBy(List<QueryField> groupByQueryFields) {
        for(QueryField groupByQueryField : groupByQueryFields) this.groupByList.add(groupByQueryField.getValue());
        return this;
    }

    public IAggregateResultQueryBuilder groupBy(Schema.FieldSet fieldSet) {
        for(Schema.FieldSetMember field : fieldSet.getFields()) this.groupByList.add(field.getFieldPath());
        return this;
    }

    public IAggregateResultQueryBuilder groupBy(QueryDate groupByQueryDate) {
        this.groupByList.add(groupByQueryDate.getValue());
        return this;
    }

    /**
    * @description Adds the average value of the numeric field to the dynamically generated aggregate query
    * @param numericQueryField The field to use for calculating the average
    * @return The instance of IAggregateResultQueryBuilder, to allow chaining methods
    */
    public IAggregateResultQueryBuilder avg(QueryField numericQueryField) {
        return this.avg(numericQueryField, null);
    }

    public IAggregateResultQueryBuilder avg(QueryField numericQueryField, String fieldAlias) {
        return buildAggregateFunction('AVG', numericQueryField, fieldAlias);
    }

    public IAggregateResultQueryBuilder count(QueryField queryField) {
        return this.count(queryField, null);
    }

    public IAggregateResultQueryBuilder count(QueryField queryField, String fieldAlias) {
        return buildAggregateFunction('COUNT', queryField, fieldAlias);
    }

    public IAggregateResultQueryBuilder count_distinct(QueryField queryField) {
        return this.count_distinct(queryField, null);
    }

    public IAggregateResultQueryBuilder count_distinct(QueryField queryField, String fieldAlias) {
        return buildAggregateFunction('COUNT_DISTINCT', queryField, fieldAlias);
    }

    /**
    * @description Adds the maximum value of the field to the dynamically generated aggregate query
    * @param queryField The field to use for calculating the maximum
    * @return The instance of IAggregateResultQueryBuilder, to allow chaining methods
    */
    public IAggregateResultQueryBuilder max(QueryField queryField) {
        return this.max(queryField, null);
    }

    public IAggregateResultQueryBuilder max(QueryField queryField, String fieldAlias) {
        return buildAggregateFunction('MAX', queryField, fieldAlias);
    }

    /**
    * @description Adds the minimum value of the field to the dynamically generated aggregate query
    * @param queryField The field to use for calculating the minimum
    * @return The instance of IAggregateResultQueryBuilder, to allow chaining methods
    */
    public IAggregateResultQueryBuilder min(QueryField queryField) {
        return this.min(queryField, null);
    }

    public IAggregateResultQueryBuilder min(QueryField queryField, String fieldAlias) {
        return buildAggregateFunction('MIN', queryField, fieldAlias);
    }

    /**
    * @description Sums the values of the supplied numeric field to the dynamically generated aggregate query
    * @param numericQueryField The field to use for calculating the minimum
    * @return The instance of IAggregateResultQueryBuilder, to allow chaining methods
    */
    public IAggregateResultQueryBuilder sum(QueryField numericQueryField) {
        return this.sum(numericQueryField, null);
    }

    public IAggregateResultQueryBuilder sum(QueryField numericQueryField, String fieldAlias) {
        return buildAggregateFunction('SUM', numericQueryField, fieldAlias);
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

    public String getQuery() {
        String queryString = 'SELECT ' + this.getGroupByFieldString() + this.getAggregateFunctionString()
            + '\nFROM ' + this.sobjectType.getDescribe().getName()
            + super.doGetWhereClauseString()
            + '\nGROUP BY ' + this.getGroupByFieldString()
            + super.doGetOrderByString()
            + super.doGetLimitCountString();

        return queryString;
    }

    public AggregateResult getFirstQueryResult() {
        return this.getQueryResults()[0];
    }

    public List<AggregateResult> getQueryResults() {
        return super.doGetQueryResults(this.getQuery());
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

    private IAggregateResultQueryBuilder buildAggregateFunction(String functionName, QueryField queryField) {
        return this.buildAggregateFunction(functionName, queryField, null);
    }

    private IAggregateResultQueryBuilder buildAggregateFunction(String functionName, QueryField queryField, String fieldAlias) {
        if(fieldAlias == null) fieldAlias = functionName + '__' + queryField.getValue();
        // Alias: MIN(Schema.Lead.MyField__c) is auto-aliased to MIN_MyField__c
        this.aggregateFunctionList.add(functionName + '(' + queryField.getValue() + ') ' + fieldAlias);
        return this;
    }

}