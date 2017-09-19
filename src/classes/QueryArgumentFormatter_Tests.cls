/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class QueryArgumentFormatter_Tests {

    @isTest
    static void it_should_return_query_string_for_null() {
        Object providedValue  = null;
        String expectedString = null;

        Test.startTest();
        String returnedValue = new QueryArgumentFormatter(providedValue).getValue();
        Test.stopTest();

        System.assertEquals(expectedString, returnedValue);
    }

    @isTest
    static void it_should_return_query_string_for_list() {
        List<Integer> providedValueList  = new List<Integer>{1, 2, 3};
        String expectedString = '(1, 2, 3)';

        Test.startTest();
        String returnedValue = new QueryArgumentFormatter(providedValueList).getValue();
        Test.stopTest();

        System.assertEquals(expectedString, returnedValue);
    }

    @isTest
    static void it_should_return_query_string_for_set() {
        Set<String> providedValueSet = new Set<String>{'A', 'B', 'C'};
        String expectedString = '(\'A\', \'B\', \'C\')';

        Test.startTest();
        String returnedValue = new QueryArgumentFormatter(providedValueSet).getValue();
        Test.stopTest();

        System.assertEquals(expectedString, returnedValue);
    }

    @isTest
    static void it_should_return_query_string_for_map() {
        Map<Id, User> providedValueMap = new Map<Id, User>([SELECT Id FROM User LIMIT 10]);
        List<Id> sortedIdList = new List<Id>(providedValueMap.keySet());
        sortedIdList.sort();
        String expectedString = '(\'' + String.join(sortedIdList, '\', \'') + '\')';

        Test.startTest();
        String returnedValue = new QueryArgumentFormatter(providedValueMap).getValue();
        Test.stopTest();

        System.assertEquals(expectedString, returnedValue);
    }

    @isTest
    static void it_should_return_query_string_for_query_date_literal() {
        QueryDateLiteral providedValue = QueryDateLiteral.YESTERDAY;
        String expectedString          = providedValue.getValue();

        Test.startTest();
        String returnedValue = new QueryArgumentFormatter(providedValue).getValue();
        Test.stopTest();

        System.assertEquals(expectedString, returnedValue);
    }

    @isTest
    static void it_should_return_query_string_for_boolean() {
        Boolean providedValue = true;
        String expectedString = String.valueOf(providedValue);

        Test.startTest();
        String returnedValue = new QueryArgumentFormatter(providedValue).getValue();
        Test.stopTest();

        System.assertEquals(expectedString, returnedValue);
    }

    @isTest
    static void it_should_return_query_string_for_date() {
        Date providedValue    = System.today();
        String expectedString = String.valueOf(providedValue);

        Test.startTest();
        String returnedValue = new QueryArgumentFormatter(providedValue).getValue();
        Test.stopTest();

        System.assertEquals(expectedString, returnedValue);
    }

    @isTest
    static void it_should_return_query_string_for_datetime() {
        Datetime providedValue = System.now();
        String expectedString  = providedValue.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'Greenwich Mean Time');

        Test.startTest();
        String returnedValue = new QueryArgumentFormatter(providedValue).getValue();
        Test.stopTest();

        System.assertEquals(expectedString, returnedValue);
    }

    @isTest
    static void it_should_return_query_string_for_decimal() {
        Decimal providedValue = 1.1;
        String expectedString = String.valueOf(providedValue);

        Test.startTest();
        String returnedValue = new QueryArgumentFormatter(providedValue).getValue();
        Test.stopTest();

        System.assertEquals(expectedString, returnedValue);
    }

    @isTest
    static void it_should_return_query_string_for_double() {
        Double providedValue  = 1.1;
        String expectedString = String.valueOf(providedValue);

        Test.startTest();
        String returnedValue = new QueryArgumentFormatter(providedValue).getValue();
        Test.stopTest();

        System.assertEquals(expectedString, returnedValue);
    }

    @isTest
    static void it_should_return_query_string_for_integer() {
        Integer providedValue =  10;
        String expectedString = String.valueOf(providedValue);

        Test.startTest();
        String returnedValue = new QueryArgumentFormatter(providedValue).getValue();
        Test.stopTest();

        System.assertEquals(expectedString, returnedValue);
    }

    @isTest
    static void it_should_return_query_string_for_long() {
        Long providedValue    = 1234567890;
        String expectedString = String.valueOf(providedValue);

        Test.startTest();
        String returnedValue = new QueryArgumentFormatter(providedValue).getValue();
        Test.stopTest();

        System.assertEquals(expectedString, returnedValue);
    }

    @isTest
    static void it_should_return_query_string_for_sobject() {
        Lead providedValue = (Lead)TestSObjectBuilder.getTestLeadBuilder().build(true);
        String expectedString = '\'' + providedValue.Id + '\'';

        Test.startTest();
        String returnedValue = new QueryArgumentFormatter(providedValue).getValue();
        Test.stopTest();

        System.assertEquals(expectedString, returnedValue);
    }

    @isTest
    static void it_should_return_query_string_for_sobject_type() {
        Schema.SObjectType providedValue = Schema.Lead.SObjectType;
        String expectedString = '\'' + providedValue.getDescribe().getName() + '\'';

        Test.startTest();
        String returnedValue = new QueryArgumentFormatter(providedValue).getValue();
        Test.stopTest();

        System.assertEquals(expectedString, returnedValue);
    }

    @isTest
    static void it_should_return_query_string_for_string() {
        String providedValue  = 'test';
        String expectedString = '\'' + providedValue + '\'';

        Test.startTest();
        String returnedValue = new QueryArgumentFormatter(providedValue).getValue();
        Test.stopTest();

        System.assertEquals(expectedString, returnedValue);
    }

    @isTest
    static void it_should_return_query_string_for_string_containing_single_quotes() {
        String providedValue  = 'Jon\'s test';
        String expectedString = '\'' + String.escapeSingleQuotes(providedValue) + '\'';

        Test.startTest();
        String returnedValue = new QueryArgumentFormatter(providedValue).getValue();
        Test.stopTest();

        System.assertEquals(expectedString, returnedValue);
    }

    @isTest
    static void it_should_return_query_string_for_unsupported_type() {
        UUID providedValue  = new UUID();
        String expectedString = String.valueOf(providedValue);

        Test.startTest();
        String returnedValue = new QueryArgumentFormatter(providedValue).getValue();
        Test.stopTest();

        System.assertEquals(expectedString, returnedValue);
    }

}