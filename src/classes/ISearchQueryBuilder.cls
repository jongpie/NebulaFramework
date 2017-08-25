public interface ISearchQueryBuilder {

    ISearchQueryBuilder setQuerySearchGroup(QuerySearchGroup searchGroup);
    ISearchQueryBuilder addSObjectQueryBuilders(ISObjectQueryBuilder sobjectQueryBuilder);
    ISearchQueryBuilder addSObjectQueryBuilders(List<ISObjectQueryBuilder> sobjectQueryBuilders);

    String getQuery(String searchTerm);

    List<SObject> getFirstSearchResult(String searchTerm);
    List<List<SObject>> getSearchResults(String searchTerm);

}