/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface IQueryBuilder {

    // Setup methods
    IQueryBuilder setSObjectType(Schema.SObjectType sobjectType);

    // Field methods
    IQueryBuilder addAllFields();
    IQueryBuilder addAllStandardFields();
    IQueryBuilder addAllCustomFields();
    IQueryBuilder addFields(Schema.FieldSet fieldSet);
    IQueryBuilder addFields(List<Schema.SObjectField> fields);

    // Filter methods
    IQueryBuilder filterBy(IQueryFilter queryFilter);
    IQueryBuilder filterBy(List<IQueryFilter> queryFilters);

    // Children query methods
    // TODO I think I hate these - change them since I'm breaking everything anuyway
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