/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface IQueryBuilder {

    // Setter methods
    IQueryBuilder setSObjectType(Schema.SObjectType sobjectType); //IQueryBuilder

    // Field methods
    IQueryBuilder addAllFields(); //ISObjectQueryBuilder
    IQueryBuilder addAllStandardFields(); //ISObjectQueryBuilder
    IQueryBuilder addAllCustomFields(); //ISObjectQueryBuilder
    IQueryBuilder addFields(Schema.FieldSet fieldSet); //IQueryBuilder
    IQueryBuilder addFields(List<Schema.SObjectField> fields); //IQueryBuilder

    // Filter methods
    IQueryBuilder filterBy(IQueryFilter queryFilter); //IQueryBuilder
    IQueryBuilder filterBy(List<IQueryFilter> queryFilters); //IQueryBuilder
    IQueryBuilder andFilterBy(List<IQueryFilter> queryFilters); //IQueryBuilder
    IQueryBuilder orFilterBy(List<IQueryFilter> queryFilters); //IQueryBuilder

    // Children query methods
    // TODO I think I hate these - change them since I'm breaking everything anuyway
    IQueryBuilder includeChildrenRecords(Schema.SObjectField childToParentRelationshipField, ISObjectRepository childSObjectRepository); //ISObjectQueryBuilder
    IQueryBuilder includeChildrenRecords(Map<Schema.SObjectField, ISObjectRepository> childFieldToChildSObjectRepositoryrMap); //ISObjectQueryBuilder

    // Order By methods
    IQueryBuilder orderBy(Schema.SObjectField orderByField); //IQueryBuilder
    IQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder); //IQueryBuilder
    IQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder, QueryNullSortOrder nullsSortOrder); //IQueryBuilder?? need to see if nulls sort order supported for aggregates??

    // Additional query option methods
    IQueryBuilder limitCount(Integer limitCount); //IQueryBuilder
    IQueryBuilder setAsUpdate(); //ISObjectQueryBuilder
    IQueryBuilder usingScope(QueryFilterScope filterScope); //ISObjectQueryBuilder??

    // Query execution methods
    SObject getFirstQueryResult(); //ISObjectQueryBuilder
    List<SObject> getQueryResults(); //ISObjectQueryBuilder
    List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup); //ISObjectQueryBuilder

    // // Get the dyanmic query strings
    // String getQuery(); // TODO keep only this??
    // TODO I think I now hate this method
    String getQuery(Schema.SObjectField sobjectField);

}