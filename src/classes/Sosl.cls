/******************************************************************************************************
* This file is part of the Nebula Query & Search project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
******************************************************************************************************/
public abstract class Sosl {

    public enum ArticleReporting { TRACKING, VIEWSTAT }
    public enum DataCategoryLocation { AT, ABOVE, BELOW, ABOVE_OR_BELOW }
    public enum SearchGroup { ALL_FIELDS, NAME_FIELDS, EMAIL_FIELDS, PHONE_FIELDS, SIDEBAR_FIELDS }

    private static Map<Integer, List<List<Sobject>>> cachedSearchResultsByHashCode = new Map<Integer, List<List<Sobject>>>();

    protected String searchQuery, searchTerm;
    protected List<SobjectQueryBuilder> sobjectQueries;
    protected Set<Schema.SobjectType> sobjectTypes;
    protected Boolean cacheResults, hasChanged;
    protected Sosl.ArticleReporting articleReporting;
    protected List<String> withClauses, withDataCategoryClauses;
    protected Sosl.SearchGroup searchGroup;

    protected Sosl(String searchTerm, SobjectQueryBuilder sobjectQuery) {
        this(searchTerm, new List<SobjectQueryBuilder>{sobjectQuery});
    }

    protected Sosl(String searchTerm, List<SobjectQueryBuilder> sobjectQueries) {
        this.searchTerm     = String.escapeSingleQuotes(searchTerm);
        this.sobjectQueries = sobjectQueries;

        this.cacheResults            = false;
        this.hasChanged              = false;
        this.searchGroup             = Sosl.SearchGroup.ALL_FIELDS;
        this.withClauses             = new List<String>();
        this.withDataCategoryClauses = new List<String>();
    }

    public Set<Schema.SobjectType> getSobjectTypes() {
        if(this.sobjectTypes != null) return this.sobjectTypes;

        this.sobjectTypes = new Set<Schema.SobjectType>();
        for(SobjectQueryBuilder query : this.sobjectQueries) {
            this.sobjectTypes.add(query.getSobjectType());
        }
        return this.sobjectTypes;
    }

    public abstract String getSearch();

    protected Sobject doGetFirstResult() {
        List<List<Sobject>> results = this.doGetResults();
        return results.isEmpty() || results[0].isEmpty() ? null : results[0][0];
    }

    protected List<Sobject> doGetFirstResults() {
        List<List<Sobject>> results = this.doGetResults();
        return results.isEmpty() ? null : results[0];
    }

    protected List<List<Sobject>> doGetResults() {
        if(this.cacheResults) return this.getCachedResults();
        else return Search.query(this.getSearch());
    }

    protected String doGetSearchGroupString() {
        return ' IN ' + this.searchGroup.name().replace('_', ' ');
    }

    protected String doGetReturningSobjectsString() {
        if(this.sobjectQueries.isEmpty()) return '';

        List<String> queryStrings = new List<String>();
        this.sobjectQueries.sort();
        for(SobjectQueryBuilder query : this.sobjectQueries) {
            queryStrings.add(query.getSearchQuery());
        }
        return ' RETURNING ' + String.join(queryStrings, ', ');
    }

    protected String doGetWithClauseString() {
        List<String> combinedWithClauses = new List<String>(this.withClauses);
        if(!this.withDataCategoryClauses.isEmpty()) {
            String withDataCategoryClausesString = 'DATA CATEGORY ' + String.join(withDataCategoryClauses, ' AND ');
            combinedWithClauses.add(withDataCategoryClausesString);
        }
        this.withClauses.sort();
        return this.withClauses.isEmpty() ? '' : ' WITH ' + String.join(this.withClauses, ' WITH ');
    }

    protected String doGetUpdateArticleReportingString() {
        return this.articleReporting == null ? '' : ' UPDATE ' + this.articleReporting.name();
    }

    private List<List<Sobject>> getCachedResults() {
        String searchQuery = this.getSearch();
        Integer hashCode   = searchQuery.hashCode();

        Boolean isCached = cachedSearchResultsByHashCode.containsKey(hashCode);
        if(!isCached) cachedSearchResultsByHashCode.put(hashCode, Search.query(searchQuery));

        // Always return a deep clone so the original cached version is never modified
        List<List<Sobject>> cachedResults = cachedSearchResultsByHashCode.get(hashCode);
        List<List<Sobject>> deepClonedResults = new List<List<Sobject>>();
        for(List<Sobject> cachedListOfResults : cachedResults) {
            deepClonedResults.add(cachedListOfResults.deepClone(true, true, true));
        }
        return deepClonedResults;
    }

}