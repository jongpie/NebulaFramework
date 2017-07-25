/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface IQueryBuilder {

    // Setup methods
    //TODO
    //IQueryBuilder initialize(Schema.SObjectType sobjectType);
    IQueryBuilder setSObjectType(Schema.SObjectType sobjectType);

    // Field methods
    IQueryBuilder addFields(Schema.FieldSet fieldSet);
    IQueryBuilder addFields(List<Schema.SObjectField> fields);
    IQueryBuilder addAllFields();
    IQueryBuilder addAllStandardFields();
    IQueryBuilder addAllCustomFields();

    // Filter methods
    IQueryBuilder filterBy(IQueryFilter queryFilter);
    IQueryBuilder filterBy(List<IQueryFilter> queryFilters);

    // Children query methods
    IQueryBuilder includeChildrenRecords(Schema.SObjectField childToParentRelationshipField, ISObjectRepository childSObjectRepository);
    IQueryBuilder includeChildrenRecords(Map<Schema.SObjectField, ISObjectRepository> childFieldToChildSObjectRepositoryrMap);

    // Order By methods
    IQueryBuilder orderBy(Schema.SObjectField orderByField);
    IQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder);
    IQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder, QueryNullSortOrder nullsSortOrder);

    // Additional query option methods
    IQueryBuilder limitCount(Integer limitCount);
    IQueryBuilder setAsUpdate();
    IQueryBuilder usingScope(QueryFilterScope filterScope);

    // Query execution methods
    SObject getFirstQueryResult();
    List<SObject> getQueryResults();
    List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup);

    // Get the dyanmic query strings
    String getQuery();
    // TODO I think I now hate this method
    String getQuery(Schema.SObjectField sobjectField);

}