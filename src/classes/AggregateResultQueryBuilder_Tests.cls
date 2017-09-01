/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class AggregateResultQueryBuilder_Tests {


    @isTest
    static void it_should_be_usable_after_construction() {
        // Query builders should be usable as soon as it's constructed - it should be able to execute a query with some default values
        IAggregateResultQueryBuilder aggregateQueryBuilder = new AggregateResultQueryBuilder(Schema.Opportunity.SObjectType);

        Test.startTest();

        List<AggregateResult> results = (List<AggregateResult>)aggregateQueryBuilder.getQueryResults();

        Test.stopTest();
    }

    @isTest
    static void it_should_cache_results() {
        IAggregateResultQueryBuilder aggregateResultQueryBuilder = new AggregateResultQueryBuilder(Schema.Opportunity.SObjectType);
        aggregateResultQueryBuilder.cacheResults();

        Test.startTest();

        System.assertEquals(0, Limits.getQueries());
        for(Integer i = 0; i < 10; i++) {
            System.debug(aggregateResultQueryBuilder.getQueryResults());
        }

        System.assertEquals(1, Limits.getQueries());

        Test.stopTest();
    }

    @isTest
    static void it_should_build_a_ridiculous_query_string() {
        String expectedString = 'SELECT Type,\nAVG(Amount) AVG__Amount, COUNT(AccountId) COUNT__AccountId, '
            + 'COUNT_DISTINCT(OwnerId) COUNT_DISTINCT__OwnerId, MAX(CreatedDate) MAX__CreatedDate, MIN(CreatedDate) MIN__CreatedDate'
            + '\nFROM Opportunity'
            + '\nGROUP BY Type';

        IAggregateResultQueryBuilder aggregateResultQueryBuilder = new AggregateResultQueryBuilder(Schema.Opportunity.SObjectType)
            .max(new QueryField(Schema.Opportunity.CreatedDate))
            .avg(new QueryField(Schema.Opportunity.Amount))
            .countDistinct(new QueryField(Schema.Opportunity.OwnerId))
            .min(new QueryField(Schema.Opportunity.CreatedDate))
            .groupBy(new QueryField(Schema.Opportunity.Type))
            .count(new QueryField(Schema.Opportunity.AccountId));
        String returnedQueryString = aggregateResultQueryBuilder.getQuery();

        System.assertEquals(expectedString, returnedQueryString);

        // Verify that the query can be executed
        Database.query(returnedQueryString);
    }


}