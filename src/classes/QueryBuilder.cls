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
public abstract class QueryBuilder extends NebulaCore implements IQueryBuilder {

    protected List<String> whereClauseList;
    @testVisible protected List<String> orderByList;
    protected Integer limitCount;

    protected SObjectType sobjectType;
    protected Map<String, Schema.SObjectField> sobjectTypeFieldMap;

    public QueryBuilder() {
        this.currentModule = NebulaCore.Module.QUERY_BUILDER;

        this.whereClauseList          = new List<String>();
        this.orderByList              = new List<String>();
    }

    public IQueryBuilder add_setSObjectType(Schema.SObjectType sobjectType) {
        // TODO verify/refactor so that this method doesnt have to be called as the first method
        this.sobjectType         = sobjectType;
        this.sobjectTypeFieldMap = sobjectType.getDescribe().fields.getMap();
        return this;
    }

    protected void setSObjectTypeDependencies() {
        this.sobjectType         = sobjectType;
        this.sobjectTypeFieldMap = sobjectType.getDescribe().fields.getMap();
    }

//TODO deprecate and instead use only OR & AND methods? Might still be needed though
    protected IQueryBuilder add_filterBy(IQueryFilter queryFilter) {
        return this.add_filterBy(new List<IQueryFilter>{queryFilter});
    }

    protected IQueryBuilder add_filterBy(List<IQueryFilter> queryFilters) {
        if(queryFilters == null) return this;

        for(IQueryFilter queryFilter : queryFilters) this.whereClauseList.add(queryFilter.getValue());
        return this;
    }

    protected IQueryBuilder add_andFilterBy(List<IQueryFilter> queryFilters) {
        // TODO finish implementing!
        return this.add_filterByWithSeparator(queryFilters, 'AND');
    }

    protected IQueryBuilder add_orFilterBy(List<IQueryFilter> queryFilters) {
// TODO finish implementing!
        return this.add_filterByWithSeparator(queryFilters, 'OR');
    }

    private IQueryBuilder add_filterByWithSeparator(List<IQueryFilter> queryFilters, String separator) {
    // TODO finish implementing!
        if(queryFilters == null) return this;

        List<String> queryFilterValues = new List<String>();
        for(IQueryFilter queryFilter : queryFilters) queryFilterValues.add(queryFilter.getValue());

        String orStatement = '(' + String.join(queryFilterValues, ' ' + separator + ' ') + ')';
        this.whereClauseList.add(orStatement);
        return this;
    }

    protected IQueryBuilder add_orderBy(Schema.SObjectField orderByField) {
        return this.add_orderBy(orderByField, null, null);
    }

    protected IQueryBuilder add_orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder) {
        return this.add_orderBy(orderByField, sortOrder, null);
    }

    protected IQueryBuilder add_orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder, QueryNullSortOrder nullsSortOrder) {
        // TODO give better name? I dont like it containing 'soql' in it if it can be used for SOSL too?
        String sortOrderSoql = '';
        if(sortOrder == QuerySortOrder.ASCENDING) sortOrderSoql = ' ASC';
        else if(sortOrder == QuerySortOrder.DESCENDING) sortOrderSoql = ' DESC';

        if(nullsSortOrder != null) sortOrderSoql += ' NULLS ' + nullsSortOrder;

        this.orderByList.add(orderByField.getDescribe().getName() + sortOrderSoql);

        return this;
    }

    protected void add_limitCount(Integer limitCount) {
        this.limitCount = limitCount;
    }

    protected void filterByWithSeparator(List<IQueryFilter> queryFilters, String separator) {
 // TODO finish implementing!
        if(queryFilters == null) return;

        List<String> queryFilterValues = new List<String>();
        for(IQueryFilter queryFilter : queryFilters) queryFilterValues.add(queryFilter.getValue());

        String orStatement = '(' + String.join(queryFilterValues, ' ' + separator + ' ') + ')';
        this.whereClauseList.add(orStatement);
    }

    protected String getWhereClauseString() {
        return this.whereClauseList.isEmpty() ? '' : '\nWHERE ' + String.join(this.whereClauseList, '\nAND ');
    }

    protected String getOrderByString() {
        return this.orderByList.isEmpty() ? '' : '\nORDER BY ' + String.join(new List<String>(orderByList), ', ');
    }

    protected String getLimitCountString() {
        return this.limitCount != null ? '\nLIMIT '+ this.limitCount : '';
    }

    protected void logEntry(String query, List<Object> results) {
        // TODO give this method a better name - addLogEntry maybe?
        String logEntry = 'Query:\n' + query + '\n\nResults:\n' + JSON.serializePretty(results);
        Logger.addEntry(this, logEntry);
    }

}