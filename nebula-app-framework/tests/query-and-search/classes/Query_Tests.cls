/******************************************************************************************************
* This file is part of the Nebula Query & Search project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
******************************************************************************************************/
@isTest
private class Query_Tests {

    @isTest
    static void it_should_return_results_for_a_simple_query() {
        String expectedQueryString = 'SELECT Id, Name FROM Account';

        Query simpleAccountQuery = new Query(Schema.Account.SObjectType);

        System.assertEquals(expectedQueryString, simpleAccountQuery.getQuery());
        List<Account> accounts = simpleAccountQuery.getResults();
    }

    @isTest
    static void it_should_return_results_for_an_advanced_query() {
        Datetime now = System.now();

        String expectedQueryString = 'SELECT Alias, Email, Id, IsActive, Profile.Name, ProfileId'
            + ' FROM User USING SCOPE MINE'
            + ' WHERE CreatedDate <= LAST_WEEK'
            + ' AND Email != null'
            + ' AND IsActive = true'
            + ' AND LastLoginDate >= LAST_N_DAYS:3'
            + ' AND LastModifiedDate <= ' + now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'Greenwich Mean Time')
            + ' AND Profile.Id != \'' + UserInfo.getProfileId() + '\''
            + ' ORDER BY Profile.CreatedBy.LastModifiedDate ASC NULLS FIRST, Name ASC NULLS FIRST, Email ASC NULLS FIRST'
            + ' LIMIT 100 OFFSET 1 FOR VIEW';

        List<SObjectField> fieldsToQuery = new List<SObjectField>{Schema.User.IsActive, Schema.User.Alias};

        Query userQuery = new Query(Schema.User.SObjectType)
            .addFields(fieldsToQuery)
            .addField(Schema.User.ProfileId)
            .addField(Schema.User.Email, Soql.FieldCategory.UPDATEABLE)
            .removeField(new Soql.QueryField(Schema.User.Name))
            .removeField(Schema.User.UserRoleId)
            .includeLabels()
            .includeFormattedValues()
            .usingScope(Soql.Scope.MINE)
            .filterWhere(Schema.User.IsActive, Soql.Operator.EQUALS, true)
            .filterWhere(new Soql.QueryField(Schema.User.SObjectType, 'Profile.Id'), Soql.Operator.NOT_EQUAL_TO, UserInfo.getProfileId())
            .filterWhere(Schema.User.LastModifiedDate, Soql.Operator.LESS_THAN_OR_EQUAL_TO, now)
            .filterWhere(Schema.User.LastLoginDate, Soql.Operator.GREATER_THAN_OR_EQUAL_TO, new Soql.DateLiteral(Soql.RelativeDateLiteral.LAST_N_DAYS, 3))
            .filterWhere(Schema.User.CreatedDate, Soql.Operator.LESS_THAN_OR_EQUAL_TO, new Soql.DateLiteral(Soql.FixedDateLiteral.LAST_WEEK))
            .filterWhere(Schema.User.Email, Soql.Operator.NOT_EQUAL_TO, null)
            .orderByField(new Soql.QueryField(Schema.User.SObjectType, 'Profile.CreatedBy.LastModifiedDate'))
            .orderByField(Schema.User.Name, Soql.SortOrder.ASCENDING)
            .orderByField(Schema.User.Email)
            .limitTo(100)
            .offsetBy(1)
            .forView();

        System.assertEquals(expectedQueryString, userQuery.getQuery());
        List<User> users = userQuery.getResults();
    }

    @isTest
    static void it_should_return_results_and_include_grandparent_query_field() {
        String expectedQueryString = 'SELECT Id, Name, Parent.Owner.Name FROM Account';

        List<Schema.SObjectField> fieldChain = new List<Schema.SObjectField>{
            Schema.Account.ParentId, Schema.Account.OwnerId, Schema.User.Name
        };
        Soql.QueryField queryField = new Soql.QueryField(fieldChain);

        Query accountQuery = new Query(Schema.Account.SObjectType);
        accountQuery.addField(queryField);

        System.assertEquals(expectedQueryString, accountQuery.getQuery());
        List<Account> accounts = accountQuery.getResults();
    }

    @isTest
    static void it_should_return_results_and_not_include_sobject_type_for_monomorphic_field() {
        String expectedQueryString = 'SELECT Id, Name, Owner.Name, OwnerId FROM Account';

        Query accountQuery = new Query(Schema.Account.SObjectType)
            .addField(new Soql.QueryField(Schema.Account.OwnerId));

        System.assertEquals(expectedQueryString, accountQuery.getQuery());
        List<Account> accounts = accountQuery.getResults();
    }

    @isTest
    static void it_should_return_results_and_include_separate_fields_for_for_polymorphic_field() {
        List<String> supportedPolymorphicFieldNames = new List<String>();
        for(Schema.SObjectField field : Schema.Name.SObjectType.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            if(!fieldDescribe.isAccessible()) continue;
            supportedPolymorphicFieldNames.add(String.valueOf(field));

            Set<String> referenceFieldNames = new Set<String>{'ProfileId',  'RecordTypeId', 'UserRoleId'};
            if(referenceFieldNames.contains(fieldDescribe.getName())) supportedPolymorphicFieldNames.add(fieldDescribe.getRelationshipName() + '.Name');
        }
        supportedPolymorphicFieldNames.sort();
        String expectedQuery = 'SELECT Id, Subject, TYPEOF Who WHEN Contact THEN Account.Name, AccountId, Id, Name'
            +' WHEN Lead THEN Company, Id, LeadSource, Name'
            + ' ELSE ' + String.join(supportedPolymorphicFieldNames, ', ') + ' END'
            + ' FROM Task';

        Test.startTest();

        Map<Schema.SObjectType, List<Schema.SObjectField>> fieldsBySObjectType = new Map<Schema.SObjectType, List<Schema.SObjectField>>();

        // Contact fields
        List<Schema.SObjectField> contactFields = new List<Schema.SObjectField>{
            Schema.Contact.Id, Schema.Contact.Name, Schema.Contact.AccountId
        };
        fieldsBySObjectType.put(Schema.Contact.SObjectType, contactFields);

        // Lead fields
        List<Schema.SObjectField> leadFields = new List<Schema.SObjectField>{
            Schema.Lead.Id, Schema.Lead.Name, Schema.Lead.Company, Schema.Lead.LeadSource
        };
        fieldsBySObjectType.put(Schema.Lead.SObjectType, leadFields );

        // Query the task object
        Query taskQuery = new Query(Schema.Task.SObjectType)
            .addPolymorphicFields(Schema.Task.WhoId, fieldsBySObjectType);

        Test.stopTest();

        System.assertEquals(expectedQuery, taskQuery.getQuery());
        System.debug(taskQuery.getResults());
    }

    @isTest
    static void it_should_return_results_and_include_sobject_type_for_polymorphic_field() {
        String expectedQueryString = 'SELECT Id, Name, Owner.Name, Owner.Type, OwnerId FROM Lead';

        Query leadQuery = new Query(Schema.Lead.SObjectType)
            .addField(new Soql.QueryField(Schema.Lead.OwnerId));

        System.assertEquals(expectedQueryString, leadQuery.getQuery());
        List<Lead> leads = leadQuery.getResults();
    }

    @isTest
    static void it_should_return_results_and_include_related_records() {
        String expectedQueryString = 'SELECT Id, Name, Type, (SELECT Email, Id, Name FROM Contacts) FROM Account';

        Query contactQuery = new Query(Schema.Contact.SObjectType)
            .addField(Schema.Contact.Email);

        Query accountQuery = new Query(Schema.Account.SObjectType)
            .includeRelatedRecords(Schema.Contact.AccountId, contactQuery)
            .addField(new Soql.QueryField(Schema.Account.Type));

        System.assertEquals(expectedQueryString, accountQuery.getQuery());
        List<Account> accounts = accountQuery.getResults();
    }

    @isTest
    static void it_should_return_results_when_filtering_with_an_or_statement() {
        String expectedQueryString = 'SELECT Id, Name FROM Account WHERE ParentId != null AND (AccountNumber = null OR Type = null)';

        Query accountQuery = new Query(Schema.Account.SObjectType)
            .addField(Schema.Account.AnnualRevenue)
            .orFilterWhere(new List<Soql.QueryFilter>{
                new Soql.QueryFilter(Schema.Account.Type, Soql.Operator.EQUALS, null),
                new Soql.QueryFilter(Schema.Account.AccountNumber, Soql.Operator.EQUALS, null)
            })
            .filterWhere(new Soql.QueryFilter(Schema.Account.ParentId, Soql.Operator.NOT_EQUAL_TO, null));
        List<Account> accounts = accountQuery.getResults();
    }

    @isTest
    static void it_should_return_results_when_filtering_with_iso_currency() {
        // If multi-currency isn't enabled, then we cannot use IsoCurrency, so skip running this test
        if(!UserInfo.isMultiCurrencyOrganization()) return;

        // If multi-currency is enabled, then execute the test
        Query accountQuery = new Query(Schema.Account.SObjectType)
            .addField(Schema.Account.AnnualRevenue)
            .filterWhere(Schema.Account.AnnualRevenue, Soql.Operator.LESS_THAN, new Soql.IsoCurrency('USD', 100));
        List<Account> accounts = accountQuery.getResults();
    }

    @isTest
    static void it_should_cache_query_results_when_enabled() {
        Integer loops = 4;
        Query userQuery = new Query(Schema.User.SObjectType).limitTo(1);

        // First, verify that caching is not enabled by default
        System.assertEquals(0, Limits.getQueries());
        for(Integer i = 0; i < loops; i++) {
            userQuery.getResults();
        }
        System.assertEquals(loops, Limits.getQueries());

        Test.startTest();

        userQuery.cacheResults();
        for(Integer i = 0; i < loops; i++) {
            userQuery.getResults();
        }
        System.assertEquals(1, Limits.getQueries());

        Test.stopTest();
    }

}