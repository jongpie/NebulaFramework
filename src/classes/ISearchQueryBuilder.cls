public interface ISearchQueryBuilder {

    ISearchQueryBuilder cacheResults();

    ISearchQueryBuilder setQuerySearchGroup(QuerySearchGroup searchGroup);
    ISearchQueryBuilder setWithHighlight(Boolean withHighlight);
    ISearchQueryBuilder setWithSpellCorrection(Boolean withSpellCorrection);

    String getQuery();

    List<SObject> getFirstSearchResult();
    List<List<SObject>> getSearchResults();

}