/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class SearchQueryBuilder_Tests {

    @isTest
    static void it_should_be_usable_after_construction() {
        // Query builders should be usable as soon as it's constructed - it should be able to execute a query with some default values
        String searchTerm = 'test';
        ISObjectQueryBuilder opportunityQueryBuilder = new SObjectQueryBuilder(Schema.Opportunity.SObjectType);

        ISearchQueryBuilder searchQueryBuilder = new SearchQueryBuilder(searchTerm, new List<ISObjectQueryBuilder>{opportunityQueryBuilder});

        Test.startTest();

        List<List<SObject>> results = (List<List<SObject>>)searchQueryBuilder.getSearchResults();

        Test.stopTest();
    }

    @isTest
    static void it_should_cache_results() {
        String searchTerm = 'test';
        ISObjectQueryBuilder opportunityQueryBuilder = new SObjectQueryBuilder(Schema.Opportunity.SObjectType);

        ISearchQueryBuilder searchQueryBuilder = new SearchQueryBuilder(searchTerm, new List<ISObjectQueryBuilder>{opportunityQueryBuilder});
        searchQueryBuilder.cacheResults();

        Test.startTest();

        System.assertEquals(0, Limits.getSoslQueries());
        for(Integer i = 0; i < 10; i++) {
            System.debug(searchQueryBuilder.getSearchResults());
        }

        System.assertEquals(1, Limits.getSoslQueries());

        Test.stopTest();
    }

    @isTest
    static void it_should_set_search_group() {
        // TODO finish writing tests!
    }

    @isTest
    static void it_should_add_sobject_query_builder() {
        // TODO finish writing tests!
    }

    @isTest
    static void it_should_get_query() {
        // TODO finish writing tests!
    }

    @isTest
    static void it_should_get_first_query_results() {
        // TODO finish writing tests!
    }

    @isTest
    static void it_should_get_query_results() {
        // TODO finish writing tests!
    }

}