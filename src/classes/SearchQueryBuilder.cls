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

    private String searchTerm;
    private QuerySearchGroup searchGroup;
    private List<ISObjectQueryBuilder> sobjectQueryBuilders;
    private List<String> sobjectQueries;
    private Boolean withHighlight;
    private Boolean withSpellCorrection;

    public SearchQueryBuilder(String searchTerm, ISObjectQueryBuilder sobjectQueryBuilder) {
        this(searchTerm, new List<ISObjectQueryBuilder>{sobjectQueryBuilder});
    }

    public SearchQueryBuilder(String searchTerm, List<ISObjectQueryBuilder> sobjectQueryBuilders) {
        this.searchTerm           = searchTerm;
        this.sobjectQueryBuilders = sobjectQueryBuilders;

        this.searchGroup         = QuerySearchGroup.ALL_FIELDS;
        this.sobjectQueries      = new List<String>();

        this.parseSObjectQueryBuilders();
    }

    public ISearchQueryBuilder cacheResults() {
        super.doCacheResults();
        return this;
    }

    public ISearchQueryBuilder inQuerySearchGroup(QuerySearchGroup searchGroup) {
        this.searchGroup = searchGroup;
        return this;
    }

    public ISearchQueryBuilder withHighlight(Boolean withHighlight) {
        this.withHighlight = withHighlight;
        return this;
    }

    public ISearchQueryBuilder withSpellCorrection(Boolean withSpellCorrection) {
        this.withHighlight = withSpellCorrection;
        return this;
    }

    public String getQuery() {
        String query = 'FIND ' + new QueryArgumentFormatter(this.searchTerm.toLowerCase()).getValue()
            + '\nIN ' + this.searchGroup.name().replace('_', ' ')
            + '\nRETURNING ' + this.getSObjectQueriesString()
            + this.getWithHighlightString()
            + this.getWithSpellCorrectionString();

        return query;
    }

    public List<SObject> getFirstSearchResult() {
        return this.getSearchResults()[0];
    }

    public List<List<SObject>> getSearchResults() {
       return super.doGetSearchResults(this.getQuery());
    }

    private ISearchQueryBuilder parseSObjectQueryBuilders() {
        for(ISObjectQueryBuilder sobjectQueryBuilder : this.sobjectQueryBuilders) {
            this.sobjectQueries.add(sobjectQueryBuilder.getSearchQuery());
        }
        return this;
    }

    private String getSObjectQueriesString() {
        this.sobjectQueries.sort();
        return String.join(this.sobjectQueries, ', ');
    }

    private String getWithHighlightString() {
        return (this.withHighlight == null || !this.withHighlight) ? '' : '\nWITH HIGHLIGHT';
    }

    private String getWithSpellCorrectionString() {
        return this.withSpellCorrection == null ? '' : '\nWITH SPELL_CORRECTION = ' + this.withSpellCorrection;
    }

}