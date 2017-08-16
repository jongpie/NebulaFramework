/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class AggregateResultQueryBuilder_Tests {

    @isTest
    static void it_should_build_a_ridiculous_query_string() {
        String expectedString = 'SELECT Type,\nAVG(Amount) AVG__Amount, COUNT(AccountId) COUNT__AccountId, '
            + 'COUNT_DISTINCT(OwnerId) COUNT_DISTINCT__OwnerId, MAX(CreatedDate) MAX__CreatedDate, MIN(CreatedDate) MIN__CreatedDate'
            + '\nFROM Opportunity'
            + '\nGROUP BY Type';

        AggregateResultQueryBuilder aggregateResultQueryBuilder = (AggregateResultQueryBuilder)new AggregateResultQueryBuilder()
            // TODO the order of the method chaining shouldn't matter - the fields & aggregate functions should be sorted so its consistent
            .max(Schema.Opportunity.CreatedDate)
            .avg(Schema.Opportunity.Amount)
            .count_distinct(Schema.Opportunity.OwnerId)
            .min(Schema.Opportunity.CreatedDate)
            .groupBy(Schema.Opportunity.Type)
            .count(Schema.Opportunity.AccountId)
            .setSObjectType(Schema.Opportunity.SObjectType);
        String returnedQueryString = aggregateResultQueryBuilder.getQuery();

        System.assertEquals(expectedString, returnedQueryString);

        // Verify that the query can be executed
        Database.query(returnedQueryString);
    }


}