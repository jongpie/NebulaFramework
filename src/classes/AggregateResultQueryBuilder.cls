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
    private List<String> queryFields;
    private List<String> aggregateFunctionList;
    private List<String> groupByList;
    private List<String> groupByRollupList;

    public AggregateResultQueryBuilder() {
        this.aggregateFunctionList = new List<String>();
        this.groupByList           = new List<String>();
    }

    // Setter methods
    public IAggregateResultQueryBuilder setSObjectType(Schema.SObjectType sobjectType) {
        this.sobjectType = sobjectType;
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
    public IAggregateResultQueryBuilder count_distinct(Schema.SObjectField sobjectField) {
        return buildAggregateFunction('COUNT_DISTINCT', sobjectField);
    }

    public IAggregateResultQueryBuilder count() {
        // COUNT() works differently from the other functions
        // It doesn't use a field as a parameter, so it builds its own string here
        // instead of using the buildAggregateFunction method
        this.aggregateFunctionList.add('COUNT() COUNT');
        return this;
    }

    public IAggregateResultQueryBuilder count(Schema.SObjectField sobjectField) {
        return buildAggregateFunction('COUNT', sobjectField);
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

    public IAggregateResultQueryBuilder groupBy(Schema.FieldSet fieldSet) {
        // TODO
        for(Schema.FieldSetMember field : fieldSet.getFields()) this.groupByList.add(field.getFieldPath().toLowerCase());
        return this;
    }

    public IAggregateResultQueryBuilder groupBy(Schema.SObjectField groupByField) {
        this.groupByList.add(groupByField.getDescribe().getName());
        return this;
    }

    public IAggregateResultQueryBuilder groupBy(List<Schema.SObjectField> groupByRollupFields) {
        for(Schema.SobjectField field : groupByRollupFields) groupByRollupList.add(field.getDescribe().getName());
        return this;
    }

    public List<AggregateResult> getQueryResults() {
        return new List<AggregateResult>();
    }

    public String getQuery() { // TODO make it inherit & override from IQueryBuilder
        String queryString = 'SELECT ' + this.getGroupByFieldString() + this.getAggregateFunctionString()
            + '\nFROM ' + this.sobjectType.getDescribe().getName()
            + this.getWhereClauseString()
            + this.getGroupByFieldString()
            + this.getOrderByString()
            + this.getLimitCountString();

        return queryString;
    }

    private String getGroupByFieldString() {
        //this.groupByList.sort(); TODO dont sort because that could change the results
        return '\nGROUP BY ' + String.join(this.groupByList, ', ');
    }

    private String getAggregateFunctionString() {
        this.aggregateFunctionList.sort();
        //TODO make better - adds a comma when needed for 'Type, COUNT_DISTINCT(OwnerId)'
        String extraDelimiter = getGroupByFieldString() == null ? '' : ', ';
        return extraDelimiter + String.join(this.aggregateFunctionList, ', ');
    }

    // private String getWhereClauseString() {
    //     //return this.whereClauseList.isEmpty() ? '' : '\nWHERE ' + String.join(this.whereClauseList, '\nAND ');
    //     return '';
    // }

/**
 * [fieldName description]
 * @type {[type]}
 */
    private IAggregateResultQueryBuilder buildAggregateFunction(String functionName, Schema.SObjectField sobjectField) {
        String fieldName = sobjectField.getDescribe().getName();
        // Alias: MIN(Schema.Lead.MyField__c) is auto-aliased to MIN_MyField__c
        this.aggregateFunctionList.add(functionName + '(' + fieldName + ') ' + functionName + '_' +fieldName);
        return this;
    }

}