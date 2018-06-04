@isTest
private class Soql_Tests {

    @isTest
    static void it_should_return_results_for_a_simple_query() {
        String expectedQueryString = 'SELECT Id, Name FROM Account';

        Soql simpleAccountQuery = new Soql(Schema.Account.SobjectType);

        System.assertEquals(expectedQueryString, simpleAccountQuery.getQuery());
        List<Account> accounts = simpleAccountQuery.getQueryResults();
    }

    @isTest
    static void it_should_return_results_for_an_advanced_query() {
        Datetime now = System.now();

        // The fields are conditionally added to the query based on the current user's permissions
        // To keep the test simpler for now, the rest of the query (excluding the 'SELECT <fields>') is validated
        String expectedPartialQueryString = 'FROM User USING SCOPE MINE WHERE IsActive = true'
            + ' AND Profile.Id != \'' + UserInfo.getProfileId() + '\' AND LastModifiedDate <= ' + now
            + ' AND CreatedDate <= LAST_WEEK AND Email != null'
            + ' ORDER BY Profile.Name ASC NULLS FIRST, Name ASC NULLS FIRST, Email ASC NULLS FIRST LIMIT 100 OFFSET 1 FOR VIEW';

        List<SobjectField> fieldsToQuery = new List<SobjectField>{Schema.User.IsActive, Schema.User.Alias};

        Soql userQuery = new Soql(Schema.User.SobjectType)
            .addFields(fieldsToQuery)
            .addField(Schema.User.ProfileId)
            .addField(Schema.User.Email, Soql.FieldCategory.UPDATEABLE)
            .addFields(Soql.FieldCategory.STANDARD)
            .removeField(new Soql.QueryField(Schema.User.Name))
            .removeField(Schema.User.UserRoleId)
            .includeLabels()
            .includeFormattedValues()
            .usingScope(Soql.Scope.MINE)
            .filterWhere(Schema.User.IsActive, '=', true)
            .filterWhere(new Soql.QueryField(Schema.User.SobjectType, 'Profile.Id'), '!=', UserInfo.getProfileId())
            .filterWhere(Schema.User.LastModifiedDate, '<=', now)
            .filterWhere(Schema.User.CreatedDate, '<=', new Soql.DateLiteral('LAST_WEEK'))
            .filterWhere(Schema.User.Email, '!=', null)
            .orderBy(new Soql.QueryField(Schema.User.SobjectType, 'Profile.CreatedBy.LastModifiedDate'))
            .orderBy(Schema.User.Name, Soql.SortOrder.ASCENDING)
            .orderBy(Schema.User.Email)
            .limitCount(100)
            .offset(1)
            .forView();

        //System.assert(userQuery.getQuery().endsWith(expectedPartialQueryString), Json.serialize(userQuery.getQuery())); //TODO finish implementing this assert
        List<User> users = userQuery.getQueryResults();
    }

    @isTest
    static void it_should_return_results_for_an_aggregate_query() {
        Soql aggregateAccountQuery = new Soql(Schema.User.SobjectType)
            .addField(Schema.User.ProfileId)
            .aggregateField(Schema.User.CreatedDate, Soql.Aggregate.MAX)
            .aggregateField(Schema.User.CreatedDate, Soql.Aggregate.MIN)
            .aggregateField(Schema.User.Email, Soql.Aggregate.COUNT);
        List<AggregateResult> results = aggregateAccountQuery.getQueryResults();
    }

    @isTest
    static void it_should_return_results_and_include_grandparent_query_field() {
        String expectedQueryString = 'SELECT Id, Name, Parent.Owner.Name FROM Account';

        List<Schema.SobjectField> fieldChain = new List<Schema.SobjectField>{
            Schema.Account.ParentId, Schema.Account.OwnerId, Schema.User.Name
        };
        Soql.QueryField queryField = new Soql.QueryField(fieldChain);

        Soql accountQuery = new Soql(Schema.Account.SobjectType);
        accountQuery.addField(queryField);

        System.assertEquals(expectedQueryString, accountQuery.getQuery());
        List<Account> accounts = accountQuery.getQueryResults();
    }

    @isTest
    static void it_should_return_results_when_filtering_with_iso_currency() {
        // If multi-currency isn't enabled, then we cannot use IsoCurrency, so skip running this test
        if(!UserInfo.isMultiCurrencyOrganization()) return;

        // If multi-currency is enabled, then execute the test
        Soql accountQuery = new Soql(Schema.Account.SobjectType)
            .addField(Schema.Account.AnnualRevenue)
            .filterWhere(Schema.Account.AnnualRevenue, '<', new Soql.IsoCurrency('USD', 100));
        List<Account> accounts = accountQuery.getQueryResults();
    }

    @isTest
    static void it_should_cache_query_results_when_enabled() {
        Integer loops = 4;
        Soql userQuery = new Soql(Schema.User.SobjectType).limitCount(1);

        // First, verify that caching is not enabled by default
        System.assertEquals(0, Limits.getQueries());
        for(Integer i=0; i < loops; i++) {
            userQuery.getQueryResults();
        }
        System.assertEquals(loops, Limits.getQueries());

        Test.startTest();

        userQuery.cacheResults();
        for(Integer i=0; i < loops; i++) {
            userQuery.getQueryResults();
        }
        System.assertEquals(1, Limits.getQueries());

        Test.stopTest();
    }

}