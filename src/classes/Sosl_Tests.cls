@isTest
private class Sosl_Tests {

    @isTest
    static void it_should_return_results_for_a_single_sobject_type() {
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name)';

        Soql userQuery  = new Soql(Schema.User.SobjectType);
        Sosl userSearch = new Sosl(UserInfo.getUserEmail(), userQuery);

        System.assertEquals(expectedSearchQueryString, userSearch.getSearchQuery());
        List<User> userSearchResults = userSearch.getFirstSearchResults();
    }

    @isTest
    static void it_should_return_results_for_multiple_sobject_types() {
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING Account(Id, Name), User(Id, Name)';

        List<Soql> queries = new List<Soql>{
            new Soql(Schema.User.SobjectType),
            new Soql(Schema.Account.SobjectType)
        };
        Sosl search = new Sosl(UserInfo.getUserEmail(), queries);

        System.assertEquals(expectedSearchQueryString, search.getSearchQuery());
        List<List<Sobject>> searchResults = search.getSearchResults();
    }

    @isTest
    static void it_should_return_results_with_highlight_enabled() {
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name) WITH HIGHLIGHT';

        Sosl userSearch = new Sosl(UserInfo.getUserEmail(), new Soql(Schema.User.SobjectType));
        userSearch.withHighlight();

        System.assertEquals(expectedSearchQueryString, userSearch.getSearchQuery());
        List<User> userSearchResults = userSearch.getFirstSearchResults();
    }

    @isTest
    static void it_should_return_results_with_snippet_enabled() {
        Integer snippetTargetLength = 10;
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name)'
            + ' WITH SNIPPET (target_length=' + snippetTargetLength + ')';

        Sosl userSearch = new Sosl(UserInfo.getUserEmail(), new Soql(Schema.User.SobjectType));
        userSearch.withSnippet(snippetTargetLength);

        System.assertEquals(expectedSearchQueryString, userSearch.getSearchQuery());
        List<User> userSearchResults = userSearch.getFirstSearchResults();
    }

    @isTest
    static void it_should_return_results_in_email_search_group() {
        Integer snippetTargetLength = 10;
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN EMAIL FIELDS RETURNING User(Id, Name)';

        Sosl userSearch = new Sosl(UserInfo.getUserEmail(), new Soql(Schema.User.SobjectType));
        userSearch.inSearchGroup(Sosl.SearchGroup.EMAIL_FIELDS);

        System.assertEquals(expectedSearchQueryString, userSearch.getSearchQuery());
        List<User> userSearchResults = (List<User>)userSearch.getFirstSearchResults();
    }

    @isTest
    static void it_should_return_results_with_spell_correction_enabled() {
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name)'
            + ' WITH SPELL_CORRECTION = true';

        Sosl userSearch = new Sosl(UserInfo.getUserEmail(), new Soql(Schema.User.SobjectType));
        userSearch.withSpellCorrection();

        System.assertEquals(expectedSearchQueryString, userSearch.getSearchQuery());
        List<User> userSearchResults = userSearch.getFirstSearchResults();
    }

    @isTest
    static void it_should_return_results_with_update_article_reporting_for_tracking_enabled() {
        // If Knowledge isn't enabled, then we cannot use Knowledge-specific SOSL methods, so skip running this test
        if(!Schema.getGlobalDescribe().containsKey('KnowledgeArticle')) return;

        // If Knowledge is enabled, then execute the test
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name)'
            + ' UPDATE TRACKING';

        Sosl userSearch = new Sosl(UserInfo.getUserEmail(), new Soql(Schema.User.SobjectType));
        userSearch.updateArticleReporting(Sosl.ArticleReporting.TRACKING);

        System.assertEquals(expectedSearchQueryString, userSearch.getSearchQuery());
        List<User> userSearchResults = userSearch.getFirstSearchResults();
    }

    @isTest
    static void it_should_return_results_with_update_article_reporting_for_viewstat_enabled() {
        // If Knowledge isn't enabled, then we cannot use Knowledge-specific SOSL methods, so skip running this test
        if(!Schema.getGlobalDescribe().containsKey('KnowledgeArticle')) return;

        // If Knowledge is enabled, then execute the test
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name)'
            + ' UPDATE VIEWSTAT';

        Sosl userSearch = new Sosl(UserInfo.getUserEmail(), new Soql(Schema.User.SobjectType));
        userSearch.updateArticleReporting(Sosl.ArticleReporting.VIEWSTAT);

        System.assertEquals(expectedSearchQueryString, userSearch.getSearchQuery());
        List<User> userSearchResults = userSearch.getFirstSearchResults();
    }

    @isTest
    static void it_should_cache_search_results_when_enabled() {
        Integer loops = 4;
        Soql userQuery  = new Soql(Schema.User.SobjectType);
        Sosl userSearch = new Sosl(UserInfo.getUserEmail(), userQuery);

        // First, verify that caching is not enabled by default
        System.assertEquals(0, Limits.getSoslQueries());
        for(Integer i=0; i < loops; i++) {
            userSearch.getSearchResults();
        }
        System.assertEquals(loops, Limits.getSoslQueries());

        Test.startTest();

        userSearch.cacheResults();
        for(Integer i=0; i < loops; i++) {
            userSearch.getSearchResults();
        }
        System.assertEquals(1, Limits.getSoslQueries());

        Test.stopTest();
    }

}