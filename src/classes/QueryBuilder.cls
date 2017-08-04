/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Query Builder
*
* @description TODO
*/
public virtual class QueryBuilder extends NebulaCore implements IQueryBuilder {

    protected String query;
    protected Set<String> queryFields; //TODO SObjectQueryBuilder because aggregates need to be a sorted list (impacts group by), not an unsorted set
    protected List<String> childRelationshipQueries;
    protected List<String> whereClauseList;
    @testVisible protected List<String> orderByList;
    protected QueryFilterScope filterScope;
    @testVisible protected Boolean forUpdate;
    protected Integer limitCount;

    protected SObjectType sobjectType;
    protected Map<String, Schema.SObjectField> sobjectTypeFieldMap;

    public QueryBuilder() {
        this.currentModule = NebulaCore.Module.QUERY_BUILDER;

        this.queryFields              = new Set<String>();
        this.childRelationshipQueries = new List<String>();
        this.whereClauseList          = new List<String>();
        this.orderByList              = new List<String>();
        this.forUpdate                = false;
    }

    public IQueryBuilder setSObjectType(Schema.SObjectType sobjectType) {
        // TODO verify/refactor so that this method doesnt have to be called as the first method
        this.sobjectType         = sobjectType;
        this.sobjectTypeFieldMap = sobjectType.getDescribe().fields.getMap();
        this.addCommonQueryFields();
        return this;
    }

    protected void setSObjectTypeDependencies() {
        this.sobjectType         = sobjectType;
        this.sobjectTypeFieldMap = sobjectType.getDescribe().fields.getMap();
        this.addCommonQueryFields();
    }




//TODO deprecate and instead use only OR & AND methods? Might still be needed though
    public IQueryBuilder filterBy(IQueryFilter queryFilter) {
        return this.filterBy(new List<IQueryFilter>{queryFilter});
    }

    public IQueryBuilder filterBy(List<IQueryFilter> queryFilters) {
        if(queryFilters == null) return this;

        for(IQueryFilter queryFilter : queryFilters) this.whereClauseList.add(queryFilter.getValue());
        return this;
    }

    public IQueryBuilder andFilterBy(List<IQueryFilter> queryFilters) {
        // TODO finish implementing!
        return this.filterByWithSeparator(queryFilters, 'AND');
    }

    public IQueryBuilder orFilterBy(List<IQueryFilter> queryFilters) {
// TODO finish implementing!
        return this.filterByWithSeparator(queryFilters, 'OR');
    }

private IQueryBuilder filterByWithSeparator(List<IQueryFilter> queryFilters, String separator) {
// TODO finish implementing!
    if(queryFilters == null) return this;

    List<String> queryFilterValues = new List<String>();
    for(IQueryFilter queryFilter : queryFilters) queryFilterValues.add(queryFilter.getValue());

    String orStatement = '(' + String.join(queryFilterValues, ' ' + separator + ' ') + ')';
    this.whereClauseList.add(orStatement);
    return this;
}

    public IQueryBuilder includeChildrenRecords(Schema.SObjectField childToParentRelationshipField, ISObjectRepository childSObjectRepository) {
        // TODO SObjectQueryBuilder??
        return this.includeChildrenRecords(new Map<Schema.SObjectField, ISObjectRepository>{childToParentRelationshipField => childSObjectRepository});
    }

    public IQueryBuilder includeChildrenRecords(Map<Schema.SObjectField, ISObjectRepository> childFieldToChildSObjectRepositoryMap) {
        // TODO SObjectQueryBuilder??
        // for(Schema.SObjectField sobjectField : childFieldToChildSObjectRepositoryMap.keySet()) {
        //     IQueryBuilder childQueryBuilder = childFieldToChildSObjectRepositoryMap.get(sobjectField).getQueryBuilder();
        //
        //     this.childRelationshipQueries.add(childQueryBuilder.getQuery(sobjectField));
        // }
        return this;
    }

    public IQueryBuilder orderBy(Schema.SObjectField orderByField) {
        return this.orderBy(orderByField, null, null);
    }

    public IQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder) {
        return this.orderBy(orderByField, sortOrder, null);
    }

    public IQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder, QueryNullSortOrder nullsSortOrder) {
        // TODO give better name? I dont like it containing 'soql' in it if it can be used for SOSL too?
        String sortOrderSoql = '';
        if(sortOrder == QuerySortOrder.ASCENDING) sortOrderSoql = ' ASC';
        else if(sortOrder == QuerySortOrder.DESCENDING) sortOrderSoql = ' DESC';

        if(nullsSortOrder != null) sortOrderSoql += ' NULLS ' + nullsSortOrder;

        this.orderByList.add(orderByField.getDescribe().getName() + sortOrderSoql);

        return this;
    }

    public IQueryBuilder limitCount(Integer limitCount) {
        this.limitCount = limitCount;
        return this;
    }

    public IQueryBuilder setAsUpdate() {// TODO - SObjectQueryBuilder??
        this.forUpdate = true;
        return this;
    }

    public IQueryBuilder usingScope(QueryFilterScope filterScope) {
        this.filterScope = filterScope;
        return this;
    }

    // Query execution methods
    public SObject getFirstQueryResult() {// TODO - SObjectQueryBuilder??
        return this.getQueryResults()[0];
    }

    public List<SObject> getQueryResults() {// TODO - SObjectQueryBuilder??
        List<SObject> results = Database.query(this.getQuery());

        this.logEntry(results);

        return results;
    }

    public virtual List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup) {// TODO - SObjectQueryBuilder??
        // TODO SObjectQueryBuilder??
        List<SObject> results = Search.query(this.getSearchQuery(searchTerm, searchGroup))[0];

        this.logEntry(results);

        return results;
    }

    // Query string methods
    public String getQuery() {
        return this.getQuery(String.valueOf(this.sobjectType));
    }
    //TODO i hate this
    public String getQuery(Schema.SObjectField childRelationshipSObjectField) {
        Schema.SObjectType parentSObjectType = new SObjectFieldDescriber(childRelationshipSObjectField).getParentSObjectType();
        String childRelationshipName = new SObjectTypeDescriber(parentSObjectType).getChildRelationshipName(childRelationshipSObjectField);
        return this.getQuery(childRelationshipName);
    }

    private String getQuery(String sobjectQueryName) {// TODO - SObjectQueryBuilder?? Aggregate query needs to be built differently
        this.query = 'SELECT ' + this.getQueryFieldString();

        // Only 1 level of child relationships is allowed, so don't include them if the SObject name isn't the current SObject Type
        if(sobjectQueryName == String.valueOf(this.sobjectType)) this.query += this.getChildRelationshipsQueryString();

        this.query +='\nFROM ' + sobjectQueryName
            + this.getWhereClauseString()
            + this.getOrderByString()
            + this.getLimitCountString()
            + this.getForUpdateString();

        return this.query;
    }

    private String getSearchQuery(String searchTerm, QuerySearchGroup searchGroup) {// TODO - SObjectQueryBuilder??
        this.query = 'FIND ' + NebulaFactory.getQueryArgumentFormatter().getValue(searchTerm.toLowerCase())
            + '\nIN ' + searchGroup.name().replace('_', ' ')
            + '\nRETURNING ' + this.sobjectType + '('
                + this.getQueryFieldString()
                + this.getWhereClauseString()
                + this.getOrderByString()
                + this.getLimitCountString()
            + ')';

        if(this.forUpdate) Logger.addEntry(this, 'SOSL Search Query method flagged as FOR UPDATE. SOSL cannot use FOR UPDATE, ignoring');
        if(this.filterScope != null) Logger.addEntry(this, 'SOSL Search Query method flagged as USING SCOPE ' + this.filterScope + '. SOSL cannot use USING SCOPE, ignoring');

        return this.query;
    }

    private String getQueryFieldString() {// TODO - SObjectQueryBuilder?? Aggregate needs to include aggregate functions (avg, sum, etc) in the query field string
        Set<String> cleanedQueryField = new Set<String>();
        for(String queryField : new List<String>(this.queryFields)) {
            cleanedQueryField.add(queryField.toLowerCase());
        }
        this.queryFields = cleanedQueryField;
        List<String> queryFieldList = new List<String>(this.queryFields);
        queryFieldList.sort();
        return String.join(queryFieldList, ', ');
    }

    private String getChildRelationshipsQueryString() {// TODO - SObjectQueryBuilder?? but i hate this
        if(this.childRelationshipQueries.isEmpty()) return '';

        return ',\n(' + String.join(childRelationshipQueries, '), (') + ')';
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

    private String getForUpdateString() {// TODO - SObjectQueryBuilder??
        return this.orderByList.isEmpty() && this.forUpdate ? '\nFOR UPDATE' : '';
    }

    protected void addCommonQueryFields() {
        // TODO decide if this should be public/work similar to the other addFields methods
        if(!NebulaSettings.RepositorySettings.IncludeCommonFields__c) return;
        // Auto-add the common fields that are available for the SObject Type
        List<String> commonFieldNameList = new List<String>{
            'Id', 'CaseNumber', 'CreatedById', 'CreatedDate', 'IsClosed', 'LastModifiedById', 'LastModifiedDate',
            'Name', 'OwnerId', 'ParentId', 'Subject', 'RecordTypeId', 'SystemModStamp'
        };
        for(String commonFieldName : commonFieldNameList) {
            // TODO this is duplicated from the constructor, need to consolidate
            this.sobjectTypeFieldMap = this.sobjectType.getDescribe().fields.getMap();
            if(!this.sobjectTypeFieldMap.containsKey(commonFieldName)) continue;

            this.queryFields.add(commonFieldName.toLowerCase());
        }
    }

    protected void logEntry(List<Object> results) {
        // TODO give this method a better name - addLogEntry maybe?
        String logEntry = 'Query:\n' + this.query + '\n\nResults:\n' + JSON.serializePretty(results);
        Logger.addEntry(this, logEntry);
    }

}