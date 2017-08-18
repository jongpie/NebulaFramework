/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Query Builder
*
* @description Abstract class that provides some shared properties & methods for SObjectQueryBuilder & AggregateResultQueryBuilder
*
*/
public abstract class QueryBuilder extends NebulaCore {

    protected List<String> whereClauseList;
    protected List<String> orderByList;
    protected Integer limitCount;

    protected SObjectType sobjectType;
    protected Map<String, Schema.SObjectField> sobjectTypeFieldMap;

    public QueryBuilder() {
        this.currentModule = NebulaCore.Module.QUERY_BUILDER;

        this.whereClauseList          = new List<String>();
        this.orderByList              = new List<String>();
    }

    protected void doFilterBy(IQueryFilter queryFilter) {
        this.doFilterBy(new List<IQueryFilter>{queryFilter});
    }

    protected void doFilterBy(List<IQueryFilter> queryFilters) {
        if(queryFilters == null) return;

        for(IQueryFilter queryFilter : queryFilters) this.whereClauseList.add(queryFilter.getValue());
    }

    protected void doOrderBy(Schema.SObjectField orderByField) {
        this.doOrderBy(orderByField, null, null);
    }

    protected void doOrderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder) {
        this.doOrderBy(orderByField, sortOrder, null);
    }

    protected void doOrderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder, QueryNullSortOrder nullsSortOrder) {
        String sortOrderString = '';
        if(sortOrder == QuerySortOrder.ASCENDING) sortOrderString = ' ASC';
        else if(sortOrder == QuerySortOrder.DESCENDING) sortOrderString = ' DESC';

        if(nullsSortOrder != null) sortOrderString += ' NULLS ' + nullsSortOrder;

        this.orderByList.add(orderByField.getDescribe().getName() + sortOrderString);
    }

    protected void doLimitCount(Integer limitCount) {
        this.limitCount = limitCount;
    }

    protected String doGetWhereClauseString() {
        return this.whereClauseList.isEmpty() ? '' : '\nWHERE ' + String.join(this.whereClauseList, '\nAND ');
    }

    protected String doGetOrderByString() {
        return this.orderByList.isEmpty() ? '' : '\nORDER BY ' + String.join(new List<String>(orderByList), ', ');
    }

    protected String doGetLimitCountString() {
        return this.limitCount != null ? '\nLIMIT '+ this.limitCount : '';
    }

    protected List<SObject> doGetQueryResults(String query) {
        List<SObject> results = Database.query(query);

        this.logResults(query, results);

        return results;
    }

    protected List<List<SObject>> doGetSearchResults(String query) {
        List<List<SObject>> results = Search.query(query);

        this.logResults(query, results);

        return results;
    }

    private void filterByWithSeparator(List<IQueryFilter> queryFilters, String separator) {
        if(queryFilters == null) return;

        List<String> queryFilterValues = new List<String>();
        for(IQueryFilter queryFilter : queryFilters) queryFilterValues.add(queryFilter.getValue());

        String orStatement = '(' + String.join(queryFilterValues, ' ' + separator + ' ') + ')';
        this.whereClauseList.add(orStatement);
    }

    private void logResults(String query, List<Object> results) {
        String logEntry = 'Query:\n' + query + '\n\nResults:\n' + JSON.serializePretty(results);
        Logger.addEntry(this, logEntry);
    }

}