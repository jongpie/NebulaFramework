/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Query Builder
*
* @description A builder class that generates dynamic SOSL queries & returns a list of SObjects or list of a list of SObjects
*
*/
public class SearchQueryBuilder extends QueryBuilder implements ISearchQueryBuilder {

    private QuerySearchGroup searchGroup;
    private List<String> sobjectQueries;

    public SearchQueryBuilder() {
        this.searchGroup    = QuerySearchGroup.ALL_FIELDS;
        this.sobjectQueries = new List<String>();
    }

    public ISearchQueryBuilder setQuerySearchGroup(QuerySearchGroup searchGroup) {
        this.searchGroup = searchGroup;
        return this;
    }

    public ISearchQueryBuilder addSObjectQueryBuilders(ISObjectQueryBuilder sobjectQueryBuilder) {
        return this.addSObjectQueryBuilders(new List<ISObjectQueryBuilder>{sobjectQueryBuilder});
    }

    public ISearchQueryBuilder addSObjectQueryBuilders(List<ISObjectQueryBuilder> sobjectQueryBuilders) {
        for(ISObjectQueryBuilder sobjectQueryBuilder : sobjectQueryBuilders) this.sobjectQueries.add(sobjectQueryBuilder.getSearchQuery());
        return this;
    }

    public String getQuery(String searchTerm) {
        String query = 'FIND ' + new QueryArgumentFormatter(searchTerm.toLowerCase()).getValue()
            + '\nIN ' + this.searchGroup.name().replace('_', ' ')
            + '\nRETURNING ' + this.getSObjectQueriesString();

        return query;
    }

    public List<SObject> getFirstSearchResult(String searchTerm) {
        return this.getSearchResults(searchTerm)[0];
    }

    public List<List<SObject>> getSearchResults(String searchTerm) {
       return super.doGetSearchResults(this.getQuery(searchTerm));
    }

    private String getSObjectQueriesString() {
        this.sobjectQueries.sort();
        return String.join(this.sobjectQueries, ', ');
    }

}