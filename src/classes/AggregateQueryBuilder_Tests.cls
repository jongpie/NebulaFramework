/******************************************************************************************************
* This file is part of the Nebula Query & Search project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
******************************************************************************************************/
@isTest
private class AggregateQueryBuilder_Tests {

    @isTest
    static void it_should_be_usable_after_construction() {
        // Query builders should be usable as soon as it's constructed - it should be able to execute a query with some default values
        AggregateQueryBuilder aggregateQueryBuilder = new AggregateQueryBuilder(Schema.Opportunity.SobjectType);

        Test.startTest();

        AggregateResult result = (AggregateResult)aggregateQueryBuilder.getFirstResult();

        Test.stopTest();
    }

    @isTest
    static void it_should_return_results_when_filtering() {
        String expectedQueryString = 'SELECT Type FROM Opportunity WHERE AccountId != null GROUP BY Type';

        AggregateQueryBuilder aggregateQueryBuilder = new AggregateQueryBuilder(Schema.Opportunity.SobjectType)
            .groupByField(Schema.Opportunity.Type)
            .filterWhere(new Soql.QueryFilter(Schema.Opportunity.AccountId, Soql.Operator.NOT_EQUAL_TO, null));

        Test.startTest();

        System.assertEquals(expectedQueryString, aggregateQueryBuilder.getQuery());
        List<AggregateResult> results = aggregateQueryBuilder.getResults();

        Test.stopTest();
    }

    @isTest
    static void it_should_return_results_when_filtering_with_an_or_statement() {
        String expectedQueryString = 'SELECT Type, COUNT(Id) COUNT__Id FROM Account WHERE (AccountNumber = null OR Type = null) AND ParentId != null GROUP BY Type';

        AggregateQueryBuilder aggregateQueryBuilder = new AggregateQueryBuilder(Schema.Account.SobjectType)
            .groupByField(Schema.Account.Type)
            .filterWhere(new Soql.QueryFilter(Schema.Account.ParentId, Soql.Operator.NOT_EQUAL_TO, null))
            .orFilterWhere(new List<Soql.QueryFilter>{
                new Soql.QueryFilter(Schema.Account.Type, Soql.Operator.EQUALS, null),
                new Soql.QueryFilter(Schema.Account.AccountNumber, Soql.Operator.EQUALS, null)
            })
            .addAggregate(Soql.Aggregate.COUNT, Schema.Account.Id);

        System.assertEquals(expectedQueryString, aggregateQueryBuilder.getQuery());
        List<AggregateResult> results = aggregateQueryBuilder.getResults();
    }

    @isTest
    static void it_should_cache_results() {
        AggregateQueryBuilder aggregateQueryBuilder = new AggregateQueryBuilder(Schema.Opportunity.SobjectType);
        aggregateQueryBuilder.cacheResults();

        Test.startTest();

        System.assertEquals(0, Limits.getQueries());
        for(Integer i = 0; i < 3; i++) {
            aggregateQueryBuilder.getResults();
        }

        System.assertEquals(1, Limits.getQueries());

        Test.stopTest();
    }

    @isTest
    static void it_should_group_by_cube() {
        String expectedQueryString = 'SELECT Type, StageName, SUM(Amount) SUM__Amount FROM Opportunity GROUP BY CUBE(Type, StageName)';

        AggregateQueryBuilder aggregateQueryBuilder = new AggregateQueryBuilder(Schema.Opportunity.SobjectType)
            .groupByField(Schema.Opportunity.Type)
            .groupByField(Schema.Opportunity.StageName)
            .addAggregate(Soql.Aggregate.SUM, Schema.Opportunity.Amount)
            .usingGroupingDimension(Soql.GroupingDimension.CUBE);

        Test.startTest();

        System.assertEquals(expectedQueryString, aggregateQueryBuilder.getQuery());
        List<AggregateResult> results = aggregateQueryBuilder.getResults();

        Test.stopTest();
    }

    @isTest
    static void it_should_group_by_rollup() {
        String expectedQueryString = 'SELECT Type, StageName, SUM(Amount) SUM__Amount FROM Opportunity GROUP BY ROLLUP(Type, StageName)';

        AggregateQueryBuilder aggregateQueryBuilder = new AggregateQueryBuilder(Schema.Opportunity.SobjectType)
            .groupByField(Schema.Opportunity.Type)
            .groupByField(Schema.Opportunity.StageName)
            .addAggregate(Soql.Aggregate.SUM, Schema.Opportunity.Amount)
            .usingGroupingDimension(Soql.GroupingDimension.ROLLUP);

        Test.startTest();

        System.assertEquals(expectedQueryString, aggregateQueryBuilder.getQuery());
        List<AggregateResult> results = aggregateQueryBuilder.getResults();

        Test.stopTest();
    }

    @isTest
    static void it_should_group_by_having_aggregate() {
        String expectedQueryString = 'SELECT Name, COUNT(Id) COUNT__Id FROM Account GROUP BY Name HAVING COUNT(Id) > 2';

        AggregateQueryBuilder aggregateQueryBuilder = new AggregateQueryBuilder(Schema.Account.SobjectType)
          .groupByField(Account.Name)
          .addAggregate(Soql.Aggregate.COUNT, Account.Id)
          .havingAggregate(Soql.Aggregate.COUNT, Account.Id, Soql.Operator.GREATER_THAN, 2);

        Test.startTest();

        System.assertEquals(expectedQueryString, aggregateQueryBuilder.getQuery());
        List<AggregateResult> results = aggregateQueryBuilder.getResults();

        Test.stopTest();
    }

    @isTest
    static void it_should_group_by_a_date_function() {
        String expectedQueryString = 'SELECT CALENDAR_MONTH(CloseDate), COUNT(Id) COUNT__Id FROM Opportunity GROUP BY CALENDAR_MONTH(CloseDate)';

        AggregateQueryBuilder aggregateQueryBuilder = new AggregateQueryBuilder(Schema.Opportunity.SobjectType)
          .groupByField(new Soql.QueryField(Soql.DateFunction.CALENDAR_MONTH, Schema.Opportunity.CloseDate))
          .addAggregate(Soql.Aggregate.COUNT, Opportunity.Id);

        Test.startTest();

        System.assertEquals(expectedQueryString, aggregateQueryBuilder.getQuery());
        List<AggregateResult> results = aggregateQueryBuilder.getResults();

        Test.stopTest();
    }

    @isTest
    static void it_should_build_an_ridiculous_query_string() {
        String expectedQueryString = 'SELECT Account.Type, StageName, AVG(Amount) AVG__Amount, COUNT(AccountId) COUNT__AccountId,'
            + ' COUNT_DISTINCT(AccountId) COUNT_DISTINCT__AccountId, COUNT_DISTINCT(OwnerId) COUNT_DISTINCT__OwnerId, COUNT_DISTINCT(Type) COUNT_DISTINCT__Type,'
            + ' MAX(CreatedDate) MAX__CreatedDate, MIN(CreatedDate) MIN__CreatedDate, SUM(Amount) SUM__Amount'
            + ' FROM Opportunity'
            + ' WHERE AccountId != null'
            + ' GROUP BY Account.Type, StageName'
            + ' ORDER BY Account.Type ASC NULLS FIRST, StageName ASC NULLS FIRST, SUM(Amount) ASC NULLS FIRST,'
            + ' MIN(CloseDate) DESC NULLS FIRST, MAX(Account.LastActivityDate) ASC NULLS FIRST'
            + ' LIMIT 100'
            + ' OFFSET 0';

        AggregateQueryBuilder aggregateQueryBuilder = new AggregateQueryBuilder(Schema.Opportunity.SobjectType)
            .addAggregate(Soql.Aggregate.MAX, Schema.Opportunity.CreatedDate)
            .addAggregate(Soql.Aggregate.AVG, Schema.Opportunity.Amount)
            .addAggregate(Soql.Aggregate.COUNT_DISTINCT, Schema.Opportunity.OwnerId)
            .addAggregate(Soql.Aggregate.MIN, Schema.Opportunity.CreatedDate)
            .groupByField(new Soql.QueryField(new List<Schema.SobjectField>{
                Schema.Opportunity.AccountId, Schema.Account.Type
            }))
            .addAggregate(Soql.Aggregate.SUM, Schema.Opportunity.Amount)
            .groupByField(Schema.Opportunity.StageName)
            .addAggregate(Soql.Aggregate.COUNT, Schema.Opportunity.AccountId)
            .addAggregate(Soql.Aggregate.COUNT_DISTINCT, Schema.Opportunity.AccountId)
            .addAggregate(Soql.Aggregate.COUNT_DISTINCT, new Soql.QueryField(new List<Schema.SobjectField>{
                Schema.Opportunity.AccountId, Schema.Account.Type
            }))
            .orderByField(new Soql.QueryField(new List<Schema.SobjectField>{
                Schema.Opportunity.AccountId, Schema.Account.Type
            }))
            .orderByField(Schema.Opportunity.StageName)
            .orderByAggregate(Soql.Aggregate.SUM, Schema.Opportunity.Amount)
            .orderByAggregate(Soql.Aggregate.MIN, Schema.Opportunity.CloseDate, Soql.SortOrder.DESCENDING)
            .orderByAggregate(
                Soql.Aggregate.MAX,
                new Soql.QueryField(new List<Schema.SobjectField>{Schema.Opportunity.AccountId, Schema.Account.LastActivityDate})
            )
            .filterWhere(Schema.Opportunity.AccountId, Soql.Operator.NOT_EQUAL_TO, null)
            .limitTo(100)
            .offsetBy(0);

        Test.startTest();

        String returnedQueryString = aggregateQueryBuilder.getQuery();

        Test.stopTest();

        System.assertEquals(expectedQueryString, returnedQueryString);

        // Verify that the query can be executed
        List<AggregateResult> results = Database.query(returnedQueryString);
    }


}