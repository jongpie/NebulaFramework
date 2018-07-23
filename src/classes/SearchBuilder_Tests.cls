/******************************************************************************************************
* This file is part of the Nebula Query & Search project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
******************************************************************************************************/
@isTest
private class SearchBuilder_Tests {

    @isTest
    static void it_should_return_first_result_for_a_single_sobject_type() {
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name)';

        SobjectQueryBuilder userQuery  = new SobjectQueryBuilder(Schema.User.SobjectType);
        SearchBuilder userSearch = new SearchBuilder(UserInfo.getUserEmail(), userQuery);

        System.assertEquals(expectedSearchQueryString, userSearch.getSearch());
        User userSearchResult = (User)userSearch.getFirstResult();
    }

    @isTest
    static void it_should_return_results_for_a_single_sobject_type() {
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name)';

        SobjectQueryBuilder userQuery  = new SobjectQueryBuilder(Schema.User.SobjectType);
        SearchBuilder userSearch = new SearchBuilder(UserInfo.getUserEmail(), userQuery);

        System.assertEquals(expectedSearchQueryString, userSearch.getSearch());
        List<User> userSearchResults = userSearch.getFirstResults();
    }

    @isTest
    static void it_should_return_results_for_multiple_sobject_types() {
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING Account(Id, Name), User(Id, Name)';

        List<SobjectQueryBuilder> queries = new List<SobjectQueryBuilder>{
            new SobjectQueryBuilder(Schema.User.SobjectType),
            new SobjectQueryBuilder(Schema.Account.SobjectType)
        };
        SearchBuilder search = new SearchBuilder(UserInfo.getUserEmail(), queries);

        System.assertEquals(expectedSearchQueryString, search.getSearch());
        List<List<Sobject>> searchResults = search.getResults();
    }

    @isTest
    static void it_should_return_results_with_highlight_enabled() {
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name) WITH HIGHLIGHT';

        SearchBuilder userSearch = new SearchBuilder(UserInfo.getUserEmail(), new SobjectQueryBuilder(Schema.User.SobjectType));
        userSearch.withHighlight();

        System.assertEquals(expectedSearchQueryString, userSearch.getSearch());
        List<User> userSearchResults = userSearch.getFirstResults();
    }

    @isTest
    static void it_should_return_results_with_snippet_enabled() {
        Integer snippetTargetLength = 10;
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name)'
            + ' WITH SNIPPET (target_length=' + snippetTargetLength + ')';

        SearchBuilder userSearch = new SearchBuilder(UserInfo.getUserEmail(), new SobjectQueryBuilder(Schema.User.SobjectType));
        userSearch.withSnippet(snippetTargetLength);

        System.assertEquals(expectedSearchQueryString, userSearch.getSearch());
        List<User> userSearchResults = userSearch.getFirstResults();
    }

    @isTest
    static void it_should_return_results_in_email_search_group() {
        Integer snippetTargetLength = 10;
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN EMAIL FIELDS RETURNING User(Id, Name)';

        SearchBuilder userSearch = new SearchBuilder(UserInfo.getUserEmail(), new SobjectQueryBuilder(Schema.User.SobjectType));
        userSearch.inSearchGroup(Sosl.SearchGroup.EMAIL_FIELDS);

        System.assertEquals(expectedSearchQueryString, userSearch.getSearch());
        List<User> userSearchResults = (List<User>)userSearch.getFirstResults();
    }

    @isTest
    static void it_should_return_results_with_spell_correction_enabled() {
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name)'
            + ' WITH SPELL_CORRECTION = true';

        SearchBuilder userSearch = new SearchBuilder(UserInfo.getUserEmail(), new SobjectQueryBuilder(Schema.User.SobjectType));
        userSearch.withSpellCorrection();

        System.assertEquals(expectedSearchQueryString, userSearch.getSearch());
        List<User> userSearchResults = userSearch.getFirstResults();
    }

    @isTest
    static void it_should_return_results_with_update_article_reporting_for_tracking_enabled() {
        // If Knowledge isn't enabled, then we cannot use Knowledge-specific SOSL methods, so skip running this test
        if(!Schema.getGlobalDescribe().containsKey('KnowledgeArticle')) return;

        // If Knowledge is enabled, then execute the test
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name)'
            + ' UPDATE TRACKING';

        SearchBuilder userSearch = new SearchBuilder(UserInfo.getUserEmail(), new SobjectQueryBuilder(Schema.User.SobjectType));
        userSearch.updateArticleReporting(Sosl.ArticleReporting.TRACKING);

        System.assertEquals(expectedSearchQueryString, userSearch.getSearch());
        List<User> userSearchResults = userSearch.getFirstResults();
    }

    @isTest
    static void it_should_return_results_with_update_article_reporting_for_viewstat_enabled() {
        // If Knowledge isn't enabled, then we cannot use Knowledge-specific SOSL methods, so skip running this test
        if(!Schema.getGlobalDescribe().containsKey('KnowledgeArticle')) return;

        // If Knowledge is enabled, then execute the test
        String expectedSearchQueryString = 'FIND \'' + UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name)'
            + ' UPDATE VIEWSTAT';

        SearchBuilder userSearch = new SearchBuilder(UserInfo.getUserEmail(), new SobjectQueryBuilder(Schema.User.SobjectType));
        userSearch.updateArticleReporting(Sosl.ArticleReporting.VIEWSTAT);

        System.assertEquals(expectedSearchQueryString, userSearch.getSearch());
        List<User> userSearchResults = userSearch.getFirstResults();
    }

    @isTest
    static void it_should_cache_search_results_when_enabled() {
        Integer loops = 4;
        SobjectQueryBuilder userQuery  = new SobjectQueryBuilder(Schema.User.SobjectType);
        SearchBuilder userSearch = new SearchBuilder(UserInfo.getUserEmail(), userQuery);

        // First, verify that caching is not enabled by default
        System.assertEquals(0, Limits.getSoslQueries());
        for(Integer i=0; i < loops; i++) {
            userSearch.getResults();
        }
        System.assertEquals(loops, Limits.getSoslQueries());

        Test.startTest();

        userSearch.cacheResults();
        for(Integer i=0; i < loops; i++) {
            userSearch.getResults();
        }
        System.assertEquals(1, Limits.getSoslQueries());

        Test.stopTest();
    }

}