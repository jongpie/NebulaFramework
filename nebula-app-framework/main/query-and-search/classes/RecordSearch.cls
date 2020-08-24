/******************************************************************************************************
* This file is part of the Nebula Query & Search project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
******************************************************************************************************/
public class RecordSearch extends Sosl {

    public RecordSearch(String searchTerm, Query sobjectQuery) {
        super(searchTerm, sobjectQuery);
    }

    public RecordSearch(String searchTerm, List<Query> sobjectQueries) {
        super(searchTerm, sobjectQueries);
    }

    public RecordSearch inSearchGroup(Sosl.SearchGroup searchGroup) {
        if(searchGroup == null) return this;

        this.searchGroup = searchGroup;
        return this.setHasChanged();
    }

    public RecordSearch withDataCategory(Schema.DataCategory dataCategory, Sosl.DataCategoryLocation dataCategoryLocation, Schema.DataCategory childDataCategory) {
        return this.withDataCategory(dataCategory, dataCategoryLocation, new List<Schema.DataCategory>{childDataCategory});
    }

    public RecordSearch withDataCategory(Schema.DataCategory dataCategory, Sosl.DataCategoryLocation dataCategoryLocation, List<Schema.DataCategory> childDataCategories) {
        List<String> childDataCategoryApiNames = new List<String>();
        for(Schema.DataCategory childDataCategory : childDataCategories) {
            childDataCategoryApiNames.add(childDataCategory.getName());
        }
        this.withDataCategoryClauses.add(dataCategory.getName() + ' ' + dataCategoryLocation + ' (' + String.join(childDataCategoryApiNames, ', ') + ')');
        return this.setHasChanged();
    }

    public RecordSearch withHighlight() {
        this.withClauses.add('HIGHLIGHT');
        return this.setHasChanged();
    }

    public RecordSearch withSnippet(Integer targetLength) {
        this.withClauses.add('SNIPPET (target_length=' + targetLength + ')');
        return this.setHasChanged();
    }

    public RecordSearch withSpellCorrection() {
        this.withClauses.add('SPELL_CORRECTION = true');
        return this.setHasChanged();
    }

    public RecordSearch updateArticleReporting(Sosl.ArticleReporting articleReporting) {
        this.articleReporting = articleReporting;
        return this.setHasChanged();
    }

    public RecordSearch cacheResults() {
        this.cacheResults = true;
        return this.setHasChanged();
    }

    public override String getSearch() {
        if(this.searchQuery != null && !this.hasChanged) return this.searchQuery;

        this.searchQuery = 'FIND \'' + this.searchTerm + '\''
            + super.doGetSearchGroupString()
            + super.doGetReturningSObjectsString()
            + super.doGetWithClauseString()
            + super.doGetUpdateArticleReportingString();

        // Change hasChanged to false so that subsequent calls to getSearchQuery() use the cached search query string
        // If additional builder methods are later called, the builder methods will set hasChanged = true
        this.hasChanged = false;

        System.debug(LoggingLevel.FINEST, this.searchQuery);
        return this.searchQuery;
    }

    public SObject getFirstResult() {
        return super.doGetFirstResult();
    }

    public List<SObject> getFirstResults() {
        return super.doGetFirstResults();
    }

    public List<List<SObject>> getResults() {
        return super.doGetResults();
    }

    private RecordSearch setHasChanged() {
        this.hasChanged = true;
        return this;
    }

}