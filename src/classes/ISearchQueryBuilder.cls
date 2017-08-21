public interface ISearchQueryBuilder {

    ISearchQueryBuilder setQuerySearchGroup(QuerySearchGroup searchGroup);
    ISearchQueryBuilder addSObjectQueryBuilder(ISObjectQueryBuilder sobjectQueryBuilder);

    String getQuery(String searchTerm);

    List<SObject> getFirstQueryResult(String searchTerm);
    List<List<SObject>> getQueryResults(String searchTerm);

}