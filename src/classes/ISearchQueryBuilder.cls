public interface ISearchQueryBuilder {

    ISearchQueryBuilder setQuerySearchGroup(QuerySearchGroup searchGroup);

    String getQuery();

    List<SObject> getFirstSearchResult();
    List<List<SObject>> getSearchResults();

}