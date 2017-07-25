/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class QueryFilter_Tests {

    @isTest
    static void it_should_return_the_query_filter_for_a_field() {
        Schema.SObjectField sobjectField = Schema.User.CompanyName;
        QueryOperator operator           = QueryOperator.IS_IN;
        List<String> providedValues      = new List<String>{'derp', 'herp'};

        Test.startTest();
        QueryFilter queryFilter = (QueryFilter)new QueryFilter().setValue(sobjectField, operator, providedValues);
        Test.stopTest();

        String expectedQueryFieldName = 'CompanyName';
        System.assertEquals(expectedQueryFieldName, queryFilter.queryFieldName);

        String expectedQueryFilter = 'CompanyName ' + operator.getValue() + ' (\'' + String.join(providedValues, '\', \'') + '\')';
        System.assertEquals(expectedQueryFilter, queryFilter.getValue());
    }

    @isTest
    static void it_should_return_the_query_filter_for_a_parent_field() {
         List<Schema.SObjectField> parentFieldToFilter = new List<Schema.SObjectField>{
            Schema.Lead.CreatedById, Schema.User.Email
        };
        QueryOperator operator = QueryOperator.EQUALS;
        String providedValue   = 'derp@test.com';

        Test.startTest();
        QueryFilter queryFilter = (QueryFilter)new QueryFilter().setValue(parentFieldToFilter, operator, providedValue);
        Test.stopTest();

        String expectedQueryFieldName = 'CreatedBy.Email';
        System.assertEquals(expectedQueryFieldName, queryFilter.queryFieldName);

        String expectedQueryFilter = 'CreatedBy.Email ' + operator.getValue() + ' \'' + providedValue + '\'';
        System.assertEquals(expectedQueryFilter, queryFilter.getValue());
    }

    @isTest
    static void it_should_return_the_query_filter_for_a_grandparent_field() {
        List<Schema.SObjectField> grandparentFieldToFilter = new List<Schema.SObjectField>{
            Schema.Lead.OwnerId, Schema.User.ManagerId, Schema.User.ProfileId, Schema.Profile.Name
        };
        QueryOperator operator = QueryOperator.EQUALS;
        String providedValue   = 'derp';

        Test.startTest();
        QueryFilter queryFilter = (QueryFilter)new QueryFilter().setValue(grandparentFieldToFilter, operator, providedValue);
        Test.stopTest();

        String expectedQueryFieldName = 'Owner.Manager.Profile.Name';
        System.assertEquals(expectedQueryFieldName, queryFilter.queryFieldName);

        String expectedQueryFilter = 'Owner.Manager.Profile.Name ' + operator.getValue() + ' \'' + providedValue + '\'';
        System.assertEquals(expectedQueryFilter, queryFilter.getValue());
    }

    @isTest
    static void it_should_return_the_sobject_field_for_a_field() {
        Schema.SObjectField sobjectField = Schema.User.CompanyName;
        QueryOperator operator           = QueryOperator.EQUALS;
        String providedValue             = 'derp';

        QueryFilter queryFilter = (QueryFilter)new QueryFilter().setValue(sobjectField, operator, providedValue);

        Test.startTest();
        System.assertEquals(sobjectField, queryFilter.getSObjectField());
        Test.stopTest();
    }

    @isTest
    static void it_should_not_return_the_sobject_field_for_a_parent_field() {
        List<Schema.SObjectField> parentFieldToFilter = new List<Schema.SObjectField>{
            Schema.Lead.OwnerId, Schema.User.ManagerId, Schema.User.ProfileId, Schema.Profile.Name
        };
        QueryOperator operator           = QueryOperator.EQUALS;
        String providedValue             = 'derp';

        QueryFilter queryFilter = (QueryFilter)new QueryFilter().setValue(parentFieldToFilter, operator, providedValue);

        Test.startTest();
        System.assertEquals(null, queryFilter.getSObjectField());
        Test.stopTest();
    }


    @isTest
    static void it_should_always_return_the_query_operator() {
        Schema.SObjectField sobjectField = Schema.User.CompanyName;
        QueryOperator operator = QueryOperator.EQUALS;
        String providedValue   = 'derp';

        QueryFilter queryFilter = (QueryFilter)new QueryFilter().setValue(sobjectField, operator, providedValue);

        Test.startTest();
        System.assertEquals(operator, queryFilter.getQueryOperator());
        Test.stopTest();
    }

    @isTest
    static void it_should_always_return_the_provided_value() {
        Schema.SObjectField sobjectField = Schema.User.CompanyName;
        QueryOperator operator = QueryOperator.EQUALS;
        String providedValue   = 'derp';

        QueryFilter queryFilter = (QueryFilter)new QueryFilter().setValue(sobjectField, operator, providedValue);

        Test.startTest();
        System.assertEquals(providedValue, queryFilter.getProvidedValue());
        Test.stopTest();
    }

}