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
public interface ISObjectQueryBuilder {

    ISObjectQueryBuilder cacheResults();

    // Field methods
    ISObjectQueryBuilder addAllFields();
    ISObjectQueryBuilder addAllStandardFields();
    ISObjectQueryBuilder addAllCustomFields();
    ISObjectQueryBuilder addAllReadableFields();
    ISObjectQueryBuilder addAllEditableFields();
    ISObjectQueryBuilder addFields(List<IQueryField> queryFields);
    ISObjectQueryBuilder addFields(Schema.FieldSet fieldSet);

    // Parent-to-child relationship query methods
    ISObjectQueryBuilder includeChildrenRecords(Schema.SObjectField childToParentRelationshipField, ISObjectQueryBuilder sobjectQueryBuilder);

    // Filter methods
    ISObjectQueryBuilder filterBy(IQueryFilter queryFilter);
    ISObjectQueryBuilder filterBy(List<IQueryFilter> queryFilters);

    // Order By methods
    ISObjectQueryBuilder orderBy(IQueryField orderByQueryField);
    ISObjectQueryBuilder orderBy(IQueryField orderByQueryField, QuerySortOrder sortOrder);
    ISObjectQueryBuilder orderBy(IQueryField orderByQueryField, QuerySortOrder sortOrder, QueryNullSortOrder nullsSortOrder);

    // Additional query option methods
    ISObjectQueryBuilder limitCount(Integer limitCount);
    ISObjectQueryBuilder offset(Integer numberOfRowsToSkip);
    ISObjectQueryBuilder forReference();
    ISObjectQueryBuilder forUpdate();
    ISObjectQueryBuilder forView();
    ISObjectQueryBuilder usingScope(QueryFilterScope filterScope);

    // Query string methods
    Database.QueryLocator getQueryLocator();
    String getQuery();
    String getSearchQuery();
    String getChildQuery(Schema.SObjectField childToParentRelationshipField);

    // Query execution methods
    SObject getFirstQueryResult();
    List<SObject> getQueryResults();

}