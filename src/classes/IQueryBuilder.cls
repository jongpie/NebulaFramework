/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface IQueryBuilder {

    // SOQL buildermethods
    IQueryBuilder whereField(Schema.SObjectField field, QueryOperator operator, Object value);

    IQueryBuilder orderBy(Schema.SObjectField orderByField);
    IQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder);
    IQueryBuilder orderBy(Schema.SObjectField orderByField, QuerySortOrder sortOrder, QueryNullSortOrder nullSortOrder);

    IQueryBuilder limitCount(Integer limitCount);
    IQueryBuilder setAsUpdate();

    // Query execution methods
    SObject getFirstQueryResult();
    List<SObject> getQueryResults();
    List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup);

}