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

    private static Map<Integer, List<SObject>> cachedQueryResultsByHashCode        = new Map<Integer, List<SObject>>();
    private static Map<Integer, List<List<SObject>>> cachedSearchResultsByHashCode = new Map<Integer, List<List<SObject>>>();

    protected List<String> whereClauseList;
    protected List<String> orderByList;
    protected Integer limitCount;

    protected SObjectType sobjectType;
    protected Map<String, Schema.SObjectField> sobjectTypeFieldMap;

    private Boolean cacheResults;

    public QueryBuilder() {
        this.currentModule = NebulaCore.Module.QUERY_BUILDER;

        this.whereClauseList = new List<String>();
        this.orderByList     = new List<String>();
        this.cacheResults    = false;
    }

    protected void doCacheResults() {
        this.cacheResults = true;
    }

    protected void doFilterBy(IQueryFilter queryFilter) {
        this.doFilterBy(new List<IQueryFilter>{queryFilter});
    }

    protected void doFilterBy(List<IQueryFilter> queryFilters) {
        if(queryFilters == null) return;

        for(IQueryFilter queryFilter : queryFilters) this.whereClauseList.add(queryFilter.getValue());
    }

    protected void doOrderBy(IQueryField orderByQueryField) {
        this.doOrderBy(orderByQueryField, null, null);
    }

    protected void doOrderBy(IQueryField orderByQueryField, QuerySortOrder sortOrder) {
        this.doOrderBy(orderByQueryField, sortOrder, null);
    }

    protected void doOrderBy(IQueryField orderByQueryField, QuerySortOrder sortOrder, QueryNullSortOrder nullsSortOrder) {
        String sortOrderString = '';
        if(sortOrder == QuerySortOrder.ASCENDING) sortOrderString = ' ASC';
        else if(sortOrder == QuerySortOrder.DESCENDING) sortOrderString = ' DESC';

        if(nullsSortOrder != null) sortOrderString += ' NULLS ' + nullsSortOrder;

        this.orderByList.add(orderByQueryField.getValue() + sortOrderString);
    }

    protected void doLimitCount(Integer limitCount) {
        this.limitCount = limitCount;
    }

    protected String doGetWhereClauseString() {
        if(this.whereClauseList.isEmpty()) return '';

        // Dedupe
        this.whereClauseList = new List<String>(new Set<String>(this.whereClauseList));

        this.whereClauseList.sort();
        return '\nWHERE ' + String.join(this.whereClauseList, '\nAND ');
    }

    protected String doGetOrderByString() {
        if(this.orderByList.isEmpty()) return '';

        // Dedupe
        this.orderByList = new List<String>(new Set<String>(this.orderByList));

        this.orderByList.sort();
        return '\nORDER BY ' + String.join(new List<String>(orderByList), ', ');
    }

    protected String doGetLimitCountString() {
        return this.limitCount != null ? '\nLIMIT '+ this.limitCount : '';
    }

    protected List<SObject> doGetQueryResults(String query) {
        if(this.cacheResults) return this.getCachedQuery(query);
        else return this.executeQuery(query);
    }

    protected List<List<SObject>> doGetSearchResults(String query) {
        if(this.cacheResults) return this.getCachedSearch(query);
        else return this.executeSearch(query);
    }

    private void filterByWithSeparator(List<IQueryFilter> queryFilters, String separator) {
        if(queryFilters == null) return;

        List<String> queryFilterValues = new List<String>();
        for(IQueryFilter queryFilter : queryFilters) queryFilterValues.add(queryFilter.getValue());

        String orStatement = '(' + String.join(queryFilterValues, ' ' + separator + ' ') + ')';
        this.whereClauseList.add(orStatement);
    }

    private List<SObject> getCachedQuery(String query) {
        Integer hashCode = query.hashCode();

        Boolean isCached = cachedQueryResultsByHashCode.containsKey(hashCode);
        if(!isCached) cachedQueryResultsByHashCode.put(hashCode, this.executeQuery(query));

        // Always return a deep clone so the original cached version is never modified
        return cachedQueryResultsByHashCode.get(hashCode).deepClone(true, true, true);
    }

    private List<SObject> executeQuery(String query) {
        List<SObject> results = Database.query(query);
        this.logResults(query, results);
        return results;
    }

    private List<List<SObject>> getCachedSearch(String query) {
        Integer hashCode = query.hashCode();

        Boolean isCached = cachedSearchResultsByHashCode.containsKey(hashCode);
        if(!isCached) cachedSearchResultsByHashCode.put(hashCode, this.executeSearch(query));

        // Always return a deep clone so the original cached version is never modified
        List<List<SObject>> cachedResults = cachedSearchResultsByHashCode.get(hashCode);
        List<List<SObject>> deepClonedResults = new List<List<SObject>>();
        for(List<SObject> cachedListOfResults : cachedResults) deepClonedResults.add(cachedListOfResults.deepClone(true, true, true));
        return deepClonedResults;
    }

    private List<List<SObject>> executeSearch(String query) {
        List<List<SObject>> results = Search.query(query);
        this.logResults(query, results);
        return results;
    }

    private void logResults(String query, List<Object> results) {
        String logEntry = 'Query:\n' + query + '\n\nResults:\n' + JSON.serializePretty(results);
        Logger.addEntry(this, logEntry);
    }

}