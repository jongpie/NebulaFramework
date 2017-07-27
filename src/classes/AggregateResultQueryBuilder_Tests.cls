@isTest
private class AggregateResultQueryBuilder_Tests {

    @isTest
    static void it_should_build_a_ridiculous_query_string() {
        String expectedString = 'SELECT Type, COUNT() COUNT, COUNT_DISTINCT(OwnerId) COUNT_DISTINCT_OwnerId, MAX(CreatedDate) MAX_CreatedDate, MIN(CreatedDate) MIN_CreatedDate';
        expectedString += '\nFROM Case';
        expectedString += '\nGROUP BY Type';

        String returnedQueryString = new AggregateResultQueryBuilder()
            // TODO the order of the method chaining shouldn't matter - the fields & aggregate functions should be sorted so its consistent
            .max(Schema.Case.CreatedDate)
            .groupBy(Schema.Case.Type)
            .count_distinct(Schema.Case.OwnerId)
            .min(Schema.Case.CreatedDate)
            .count()
            .setSObjectType(Schema.Case.SObjectType)
            .getQueryString();

        System.assertEquals(expectedString, returnedQueryString);
    }


}