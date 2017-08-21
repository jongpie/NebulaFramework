public interface ISearchQueryBuilder {

    ISearchQueryBuilder setQuerySearchGroup(QuerySearchGroup searchGroup);
    ISearchQueryBuilder addSObjectQueryBuilders(ISObjectQueryBuilder sobjectQueryBuilder);
    ISearchQueryBuilder addSObjectQueryBuilders(List<ISObjectQueryBuilder> sobjectQueryBuilders);

    String getQuery(String searchTerm);

    List<SObject> getFirstQueryResult(String searchTerm);
    List<List<SObject>> getQueryResults(String searchTerm);

}