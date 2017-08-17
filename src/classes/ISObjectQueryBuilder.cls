/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Query Builder
* @group-content /ApexDocContent/QueryBuilder.html
*
* @description TODO
*
*/
public interface ISObjectQueryBuilder {


        // TODO create diagram to show the pieces needed for using query Builder
        //      1. set sobject Type
        //      2. add some fields
        //      3. Optional: filters
        //      4. Optional: order by
        //      5. Optional: limitCount, setAsUpdate & usingScope methods
        //      6. Get results: getQueryResults, getFirstQueryResult, getSearchResults
        //      7. Optional: getQuery to get the dynamically generated query string


    // Setter methods
    ISObjectQueryBuilder setSObjectType(Schema.SObjectType sobjectType);

    // Field methods
    ISObjectQueryBuilder addAllFields();
    ISObjectQueryBuilder addAllStandardFields();
    ISObjectQueryBuilder addAllCustomFields();
    ISObjectQueryBuilder addAllReadableFields();
    ISObjectQueryBuilder addAllEditableFields();
    ISObjectQueryBuilder addFields(Schema.FieldSet fieldSet);
    ISObjectQueryBuilder addFields(List<Schema.SObjectField> fields);

    // Parent-to-child relationship query methods
    ISObjectQueryBuilder includeChildrenRecords(Schema.SObjectField childToParentRelationshipField, List<Schema.SObjectField> fields, List<IQueryFilter> filters);

    // Filter methods
    ISObjectQueryBuilder andFilterBy(IQueryFilter queryFilter);
    ISObjectQueryBuilder andFilterBy(List<IQueryFilter> queryFilters);
    ISObjectQueryBuilder orFilterBy(List<IQueryFilter> queryFilters);

    // Order By methods
    ISObjectQueryBuilder orderBy(Schema.SObjectField orderByField);
    ISObjectQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder);
    ISObjectQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder, QueryNullSortOrder nullsSortOrder);

    // Additional query option methods
    ISObjectQueryBuilder limitCount(Integer limitCount);
    ISObjectQueryBuilder setAsUpdate();
    ISObjectQueryBuilder usingScope(QueryFilterScope filterScope);

    // Query execution methods
    SObject getFirstQueryResult();
    List<SObject> getQueryResults();
    List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup);

}