/******************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.                  *
* See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
******************************************************************************************************/
public class Sosl {

    public enum ArticleReporting { TRACKING, VIEWSTAT }
    public enum Clause { HIGHLIGHT, SPELL_CORRECTION }
    public enum DataCategoryLocation { AT, ABOVE, BELOW, ABOVE_OR_BELOW }
    public enum SearchGroup { ALL_FIELDS, NAME_FIELDS, EMAIL_FIELDS, PHONE_FIELDS, SIDEBAR_FIELDS }

    private static Map<Integer, List<List<Sobject>>> cachedSearchResultsByHashCode = new Map<Integer, List<List<Sobject>>>();

    private String searchQuery, searchTerm;
    private ArticleReporting articleReporting;
    private List<String> withClauses, withDataCategoryClauses;
    private SearchGroup searchGroup;
    private List<Soql> searchQueries;
    private Boolean cacheResults, hasChanged;

    public Sosl(String searchTerm, Soql query) {
        this(searchTerm, new List<Soql>{query});
    }

    public Sosl(String searchTerm, List<Soql> queries) {
        this.searchTerm    = searchTerm;
        this.searchQueries = queries;

        this.cacheResults            = false;
        this.searchGroup             = Sosl.SearchGroup.ALL_FIELDS;
        this.withClauses             = new List<String>();
        this.withDataCategoryClauses = new List<String>();
    }

    public Sosl inSearchGroup(SearchGroup searchGroup) {
        this.searchGroup = searchGroup;
        return this.setHasChanged();
    }

    public Sosl withDataCategory(Schema.DataCategory dataCategory, Sosl.DataCategoryLocation dataCategoryLocation, Schema.DataCategory childDataCategory) {
        return this.withDataCategory(dataCategory, dataCategoryLocation, new List<Schema.DataCategory>{childDataCategory});
    }

    public Sosl withDataCategory(Schema.DataCategory dataCategory, Sosl.DataCategoryLocation dataCategoryLocation, List<Schema.DataCategory> childDataCategories) {
        List<String> childDataCategoryApiNames = new List<String>();
        for(Schema.DataCategory childDataCategory : childDataCategories) {
            childDataCategoryApiNames.add(childDataCategory.getName());
        }
        this.withDataCategoryClauses.add(dataCategory.getName() + ' ' + dataCategoryLocation + ' (' + String.join(childDataCategoryApiNames, ', ') + ')');
        return this.setHasChanged();
    }

    public Sosl withHighlight() {
        this.withClauses.add('HIGHLIGHT');
        return this.setHasChanged();
    }

    public Sosl withSnippet(Integer targetLength) {
        this.withClauses.add('SNIPPET (target_length=' + targetLength + ')');
        return this.setHasChanged();
    }

    public Sosl withSpellCorrection() {
        this.withClauses.add('SPELL_CORRECTION = true');
        return this.setHasChanged();
    }

    public Sosl updateArticleReporting(Sosl.ArticleReporting articleReporting) {
        this.articleReporting = articleReporting;
        return this.setHasChanged();
    }

    public Sosl cacheResults() {
        this.cacheResults = true;
        return this.setHasChanged();
    }

    public String getSearchQuery() {
        if(this.searchQuery != null && !this.hasChanged) return this.searchQuery;

        this.searchQuery = 'FIND \'' + this.searchTerm + '\''
            + this.getSearchGroupString()
            + this.getReturningSobjectsString()
            + this.getWithClauseString()
            + this.getUpdateArticleReportingString();

        // Change hasChanged to false so that subsequent calls to getSearchQuery() use the cached search query string
        // If additional builder methods are later called, the builder methods will set hasChanged = true
        this.hasChanged = false;

        System.debug(LoggingLevel.FINEST, this.searchQuery);
        return this.searchQuery;
    }

    public List<Sobject> getFirstSearchResults() {
        return this.getSearchResults()[0];
    }

    public List<List<Sobject>> getSearchResults() {
        if(this.cacheResults) return this.getCachedQuery();
        else return Search.query(this.getSearchQuery());
    }

    private Sosl setHasChanged() {
        this.hasChanged = true;
        return this;
    }

    private List<List<Sobject>> getCachedQuery() {
        String query     = this.getSearchQuery();
        Integer hashCode = query.hashCode();

        Boolean isCached = cachedSearchResultsByHashCode.containsKey(hashCode);
        if(!isCached) cachedSearchResultsByHashCode.put(hashCode, Search.query(query));

        // Always return a deep clone so the original cached version is never modified
        List<List<Sobject>> cachedResults = cachedSearchResultsByHashCode.get(hashCode);
        List<List<Sobject>> deepClonedResults = new List<List<Sobject>>();
        for(List<Sobject> cachedListOfResults : cachedResults) {
            deepClonedResults.add(cachedListOfResults.deepClone(true, true, true));
        }
        return deepClonedResults;
    }

    private String getSearchGroupString() {
        return ' IN ' + this.searchGroup.name().replace('_', ' ');
    }

    private String getReturningSobjectsString() {
        if(this.searchQueries.isEmpty()) return '';

        List<String> queryStrings = new List<String>();
        this.searchQueries.sort();
        for(Soql query : this.searchQueries) {
            queryStrings.add(query.getSearchQuery());
        }
        return ' RETURNING ' + String.join(queryStrings, ', ');
    }

    private String getWithClauseString() {
        List<String> combinedWithClauses = new List<String>(this.withClauses);
        if(!this.withDataCategoryClauses.isEmpty()) {
            String withDataCategoryClausesString = 'DATA CATEGORY ' + String.join(withDataCategoryClauses, ' AND ');
            combinedWithClauses.add(withDataCategoryClausesString);
        }
        this.withClauses.sort();
        return this.withClauses.isEmpty() ? '' : ' WITH ' + String.join(this.withClauses, ' WITH ');
    }

    private String getUpdateArticleReportingString() {
        return this.articleReporting == null ? '' : ' UPDATE ' + this.articleReporting.name();
    }

}