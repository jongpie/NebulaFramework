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
public abstract class QueryBuilder extends NebulaCore {

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

//TODO deprecate and instead use only OR & AND methods? Might still be needed though
    protected void add_filterBy(IQueryFilter queryFilter) {
        this.add_filterBy(new List<IQueryFilter>{queryFilter});
    }

    protected void add_filterBy(List<IQueryFilter> queryFilters) {
        if(queryFilters == null) return;

        for(IQueryFilter queryFilter : queryFilters) this.whereClauseList.add(queryFilter.getValue());
    }

    protected void add_andFilterBy(List<IQueryFilter> queryFilters) {
        // TODO finish implementing!
        this.filterByWithSeparator(queryFilters, 'AND');
    }

    protected void add_orFilterBy(List<IQueryFilter> queryFilters) {
// TODO finish implementing!
        this.filterByWithSeparator(queryFilters, 'OR');
    }

    protected void add_subquery(Schema.SObjectField sobjectFieldToFilter, Schema.SObjectField lookupFieldOnRelatedSObject, String inOrOut) {
        String sobjectFieldToFilterName = sobjectFieldToFilter.getDescribe().getName();
        String relatedSObjectTypeName = new SObjectFieldDescriber(lookupFieldOnRelatedSObject).SObjectType.getDescribe().getName(); // TODO change SObjectType to getSObjectType()
        String lookupFieldOnRelatedSObjectName = lookupFieldOnRelatedSObject.getDescribe().getName();

        String subselectString = sobjectFieldToFilterName + ' ' + inOrOut + ' (SELECT ' + lookupFieldOnRelatedSObjectName + ' FROM ' + relatedSObjectTypeName + ')';
        this.whereClauseList.add(subselectString);
    }

    protected void add_orderBy(Schema.SObjectField orderByField) {
        this.add_orderBy(orderByField, null, null);
    }

    protected void add_orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder) {
        this.add_orderBy(orderByField, sortOrder, null);
    }

    protected void add_orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder, QueryNullSortOrder nullsSortOrder) {
        // TODO give better name? I dont like it containing 'soql' in it if it can be used for SOSL too?
        String sortOrderSoql = '';
        if(sortOrder == QuerySortOrder.ASCENDING) sortOrderSoql = ' ASC';
        else if(sortOrder == QuerySortOrder.DESCENDING) sortOrderSoql = ' DESC';

        if(nullsSortOrder != null) sortOrderSoql += ' NULLS ' + nullsSortOrder;

        this.orderByList.add(orderByField.getDescribe().getName() + sortOrderSoql);
    }

    protected void add_limitCount(Integer limitCount) {
        this.limitCount = limitCount;
    }

    private void filterByWithSeparator(List<IQueryFilter> queryFilters, String separator) {
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