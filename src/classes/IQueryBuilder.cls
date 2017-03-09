public interface IQueryBuilder {

    // SOQL buildermethods
    IQueryBuilder whereField(Schema.SObjectField field, String operator, Object value);
    IQueryBuilder whereField(Schema.SObjectField field, String operator, List<Object> valueList);

    IQueryBuilder orderBy(Schema.SObjectField orderByField);
    IQueryBuilder orderBy(Schema.SObjectField orderByField, QueryBuilder.SortOrder sortOrder);
    IQueryBuilder orderBy(Schema.SObjectField orderByField, QueryBuilder.SortOrder sortOrder, QueryBuilder.NullsSortOrder nullsSortOrder);

    IQueryBuilder limitCount(Integer limitCount);
    IQueryBuilder setAsUpdate();

    // Query execution methods
    SObject getFirstQueryResult();
    List<SObject> getQueryResults();
    List<SObject> getSearchResults(String searchTerm, QueryBuilder.SearchGroup searchGroup);

}