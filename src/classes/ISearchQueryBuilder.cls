public interface ISearchQueryBuilder {

    ISearchQueryBuilder cacheResults();

    ISearchQueryBuilder inQuerySearchGroup(QuerySearchGroup searchGroup);
    ISearchQueryBuilder withHighlight(Boolean withHighlight);
    ISearchQueryBuilder withSpellCorrection(Boolean withSpellCorrection);

    String getQuery();

    List<SObject> getFirstSearchResult();
    List<List<SObject>> getSearchResults();

}