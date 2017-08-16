/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Query Builder
* @group-content /ApexDocContent/QueryBuilder.html
*
* @description TODO A builder class that generates dynamic queries & returns a list of AggregateResult
*
*/
public class AggregateResultQueryBuilder extends QueryBuilder implements IAggregateResultQueryBuilder {//{} //extends QueryBuilder implements IAggregateResultQueryBuilder {

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

    public IAggregateResultQueryBuilder groupBy(Schema.FieldSet fieldSet) {
        for(Schema.FieldSetMember field : fieldSet.getFields()) this.groupByList.add(field.getFieldPath());
        return this;
    }

    public IAggregateResultQueryBuilder groupBy(Schema.SObjectField groupByField) {
        return this.groupBy(new List<Schema.SObjectField>{groupByField});
    }

    public IAggregateResultQueryBuilder groupBy(List<Schema.SObjectField> groupByFields) {
        for(Schema.SobjectField field : groupByFields) this.groupByList.add(field.getDescribe().getName());
        return this;
    }

    /*******************************************************************************************************
   * @description Adds the average value of the numeric field to the dynamically generated aggregate query
   * @param numericSObjectField The field to use for calculating the average
   * @return The instance of IAggregateResultQueryBuilder to allow chaining methods
   * @example
   * TODO
   */
    public IAggregateResultQueryBuilder avg(Schema.SObjectField numericSObjectField) {
        return buildAggregateFunction('AVG', numericSObjectField);
    }

    /*******************************************************************************************************
   * @description Adds the number of distinct values in the field to the dynamically generated aggregate query
   * @param sobjectField The field to use for calculating the average
   * @return The instance of IAggregateResultQueryBuilder to allow chaining methods
   * @example
   * TODO
   */


    // public IAggregateResultQueryBuilder count() {
    //     // TODO remove or finish implementing COUNT() works differently from the other functions
    //     // It doesn't use a field as a parameter, so it builds its own string here
    //     // instead of using the buildAggregateFunction method
    //     this.aggregateFunctionList.add('COUNT() COUNT');
    //     return this;
    // }

    public IAggregateResultQueryBuilder count(Schema.SObjectField sobjectField) {
        return buildAggregateFunction('COUNT', sobjectField);
    }

    public IAggregateResultQueryBuilder count_distinct(Schema.SObjectField sobjectField) {
        return buildAggregateFunction('COUNT_DISTINCT', sobjectField);
    }

    /*******************************************************************************************************
   * @description Adds the maximum value of the field to the dynamically generated aggregate query
   * @param sobjectField The field to use for calculating the maximum
   * @return The instance of IAggregateResultQueryBuilder to allow chaining methods
   * @example
   * TODO
   */
    public IAggregateResultQueryBuilder max(Schema.SObjectField sobjectField) {
        return buildAggregateFunction('MAX', sobjectField);
    }

    /*******************************************************************************************************
   * @description Adds the minimum value of the field to the dynamically generated aggregate query
   * @param sobjectField The field to use for calculating the minimum
   * @return The instance of IAggregateResultQueryBuilder to allow chaining methods
   * @example
   * TODO
   */
    public IAggregateResultQueryBuilder min(Schema.SObjectField sobjectField) {
        return buildAggregateFunction('MIN', sobjectField);
    }

    /*******************************************************************************************************
   * @description Sums the values of the supplied numeric field to the dynamically generated aggregate query
   * @param numericSObjectField The field to use for calculating the minimum
   * @return The instance of IAggregateResultQueryBuilder to allow chaining methods
   * @example
   * TODO
   */
    public IAggregateResultQueryBuilder sum(Schema.SObjectField numericSObjectField) {
        return buildAggregateFunction('SUM', numericSObjectField);
    }

    public IAggregateResultQueryBuilder filterBy(IQueryFilter queryFilter) {
        super.add_filterBy(queryFilter);
        return this;
    }

    public IAggregateResultQueryBuilder filterBy(List<IQueryFilter> queryFilters) {
        super.add_filterBy(queryFilters);
        return this;
    }

    public IAggregateResultQueryBuilder andFilterBy(List<IQueryFilter> queryFilters) {
       super.add_andFilterBy(queryFilters);
       return this;
    }

    public IAggregateResultQueryBuilder orFilterBy(List<IQueryFilter> queryFilters) {
       super.add_orFilterBy(queryFilters);
       return this;
    }

    // TODO finish implementing subselects!, come up with better method name that uses verb for name (get, set, etc)
    public IAggregateResultQueryBuilder inSubquery(Schema.SObjectField lookupFieldOnRelatedSObject) {
        return this.inSubquery(this.sobjectType.getDescribe().fields.getMap().get('Id'), lookupFieldOnRelatedSObject);
    }

    public IAggregateResultQueryBuilder inSubquery(Schema.SObjectField sobjectFieldToFilter, Schema.SObjectField lookupFieldOnRelatedSObject) {
        super.add_subquery(sobjectFieldToFilter, lookupFieldOnRelatedSObject, 'IN');
        return this;
    }

    public IAggregateResultQueryBuilder notInSubquery(Schema.SObjectField lookupFieldOnRelatedSObject) {
        return this.notInSubquery(this.sobjectType.getDescribe().fields.getMap().get('Id'), lookupFieldOnRelatedSObject);
    }

    public IAggregateResultQueryBuilder notInSubquery(Schema.SObjectField sobjectFieldToFilter, Schema.SObjectField lookupFieldOnRelatedSObject) {
        super.add_subquery(sobjectFieldToFilter, lookupFieldOnRelatedSObject, 'NOT IN');
        return this;
    }

    public IAggregateResultQueryBuilder orderBy(Schema.SObjectField orderByField) {
        super.add_orderBy(orderByField);
        return this;
    }

    public IAggregateResultQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder) {
        super.add_orderBy(orderByField, sortOrder);
        return this;
    }

    public IAggregateResultQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder, QueryNullSortOrder nullsSortOrder) {
        super.add_orderBy(orderByField, sortOrder, nullsSortOrder);
        return this;
    }

    public IAggregateResultQueryBuilder limitCount(Integer limitCount) {
        super.add_limitCount(limitCount);
        return this;
    }

    public AggregateResult getFirstQueryResult() {
        return this.getQueryResults()[0];
    }

    public List<AggregateResult> getQueryResults() {
        List<AggregateResult> results = Database.query(this.getQuery());

        this.logEntry(this.getQuery(), results);

        return results;
    }

    @testVisible
    private String getQuery() {
        String queryString = 'SELECT ' + this.getGroupByFieldString() + this.getAggregateFunctionString()
            + '\nFROM ' + this.sobjectType.getDescribe().getName()
            + this.getWhereClauseString()
            + '\nGROUP BY ' + this.getGroupByFieldString()
            + this.getOrderByString()
            + this.getLimitCountString();

        return queryString;
    }

    private String getGroupByFieldString() {
        return String.join(this.groupByList, ', ');
    }

    private String getAggregateFunctionString() {
        this.aggregateFunctionList.sort();
        //TODO make better - adds a comma when needed for 'Type, COUNT_DISTINCT(OwnerId)'
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