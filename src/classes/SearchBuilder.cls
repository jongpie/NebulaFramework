/******************************************************************************************************
* This file is part of the Nebula Query & Search project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
******************************************************************************************************/
public class SearchBuilder extends Sosl {

    public SearchBuilder(String searchTerm, SobjectQueryBuilder sobjectQuery) {
        super(searchTerm, sobjectQuery);
    }

    public SearchBuilder(String searchTerm, List<SobjectQueryBuilder> sobjectQueries) {
        super(searchTerm, sobjectQueries);
    }

    public SearchBuilder inSearchGroup(Sosl.SearchGroup searchGroup) {
        this.searchGroup = searchGroup;
        return this.setHasChanged();
    }

    public SearchBuilder withDataCategory(Schema.DataCategory dataCategory, Sosl.DataCategoryLocation dataCategoryLocation, Schema.DataCategory childDataCategory) {
        return this.withDataCategory(dataCategory, dataCategoryLocation, new List<Schema.DataCategory>{childDataCategory});
    }

    public SearchBuilder withDataCategory(Schema.DataCategory dataCategory, Sosl.DataCategoryLocation dataCategoryLocation, List<Schema.DataCategory> childDataCategories) {
        List<String> childDataCategoryApiNames = new List<String>();
        for(Schema.DataCategory childDataCategory : childDataCategories) {
            childDataCategoryApiNames.add(childDataCategory.getName());
        }
        this.withDataCategoryClauses.add(dataCategory.getName() + ' ' + dataCategoryLocation + ' (' + String.join(childDataCategoryApiNames, ', ') + ')');
        return this.setHasChanged();
    }

    public SearchBuilder withHighlight() {
        this.withClauses.add('HIGHLIGHT');
        return this.setHasChanged();
    }

    public SearchBuilder withSnippet(Integer targetLength) {
        this.withClauses.add('SNIPPET (target_length=' + targetLength + ')');
        return this.setHasChanged();
    }

    public SearchBuilder withSpellCorrection() {
        this.withClauses.add('SPELL_CORRECTION = true');
        return this.setHasChanged();
    }

    public SearchBuilder updateArticleReporting(Sosl.ArticleReporting articleReporting) {
        this.articleReporting = articleReporting;
        return this.setHasChanged();
    }

    public SearchBuilder cacheResults() {
        this.cacheResults = true;
        return this.setHasChanged();
    }

    public override String getSearch() {
        if(this.searchQuery != null && !this.hasChanged) return this.searchQuery;

        this.searchQuery = 'FIND \'' + this.searchTerm + '\''
            + super.doGetSearchGroupString()
            + super.doGetReturningSobjectsString()
            + super.doGetWithClauseString()
            + super.doGetUpdateArticleReportingString();

        // Change hasChanged to false so that subsequent calls to getSearchQuery() use the cached search query string
        // If additional builder methods are later called, the builder methods will set hasChanged = true
        this.hasChanged = false;

        System.debug(LoggingLevel.FINEST, this.searchQuery);
        return this.searchQuery;
    }

    public Sobject getFirstResult() {
        return super.doGetFirstResult();
    }

    public List<Sobject> getFirstResults() {
        return super.doGetFirstResults();
    }

    public List<List<Sobject>> getResults() {
        return super.doGetResults();
    }

    private SearchBuilder setHasChanged() {
        this.hasChanged = true;
        return this;
    }

}