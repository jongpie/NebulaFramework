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
        QueryFilter queryFilter = (QueryFilter)new QueryFilter().filterByField(new QueryField(sobjectField), operator, providedValues);
        Test.stopTest();

        String expectedQueryFilter = 'CompanyName ' + operator.getValue() + ' (\'' + String.join(providedValues, '\', \'') + '\')';
        System.assertEquals(expectedQueryFilter, queryFilter.getValue());
    }

    @isTest
    static void it_should_return_the_query_filter_for_a_parent_field() {
         QueryField parentFieldToFilter = new QueryField(new List<Schema.SObjectField>{
            Schema.Lead.CreatedById, Schema.User.Email
        });
        QueryOperator operator = QueryOperator.EQUALS;
        String providedValue   = 'derp@test.com';

        Test.startTest();
        QueryFilter queryFilter = (QueryFilter)new QueryFilter().filterByField(parentFieldToFilter, operator, providedValue);
        Test.stopTest();

        String expectedQueryFilter = 'CreatedBy.Email ' + operator.getValue() + ' \'' + providedValue + '\'';
        System.assertEquals(expectedQueryFilter, queryFilter.getValue());
    }

    @isTest
    static void it_should_return_the_query_filter_for_a_grandparent_field() {
        QueryField grandparentFieldToFilter = new QueryField(new List<Schema.SObjectField>{
            Schema.Lead.OwnerId, Schema.User.ManagerId, Schema.User.ProfileId, Schema.Profile.Name
        });
        QueryOperator operator = QueryOperator.EQUALS;
        String providedValue   = 'derp';

        Test.startTest();
        QueryFilter queryFilter = (QueryFilter)new QueryFilter().filterByField(grandparentFieldToFilter, operator, providedValue);
        Test.stopTest();

        String expectedQueryFilter = 'Owner.Manager.Profile.Name ' + operator.getValue() + ' \'' + providedValue + '\'';
        System.assertEquals(expectedQueryFilter, queryFilter.getValue());
    }

    @isTest
    static void it_should_return_the_query_filter_for_a_query_date() {
        QueryDate qd           = QueryDate.CALENDAR_MONTH(Schema.Lead.CreatedDate);
        QueryOperator operator = QueryOperator.EQUALS;
        Integer providedValue  = 3;

        Test.startTest();
        QueryFilter queryFilter = (QueryFilter)new QueryFilter().filterByQueryDate(qd, operator, providedValue);
        Test.stopTest();

        String expectedQueryFilter = 'CALENDAR_MONTH(CreatedDate) ' + operator.getValue() + ' ' + providedValue;
        System.assertEquals(expectedQueryFilter, queryFilter.getValue());
    }

    @isTest
    static void it_should_return_the_query_filter_for_a_subquery() {
        QueryOperator operator                          = QueryOperator.IS_IN;
        Schema.SObjectField lookupFieldOnRelatedSObject = Schema.Lead.ConvertedAccountId;

        Test.startTest();
        QueryFilter queryFilter = (QueryFilter)new QueryFilter().filterBySubquery(operator, lookupFieldOnRelatedSObject);
        Test.stopTest();

        String expectedQueryFilter = 'Id ' + operator.getValue() + ' (SELECT ' + lookupFieldOnRelatedSObject.getDescribe().getName() + ' FROM Lead)';
        System.assertEquals(expectedQueryFilter, queryFilter.getValue());
    }

    @isTest
    static void it_should_return_the_query_filter_for_a_subquery_with_a_specified_field() {
        QueryOperator operator                          = QueryOperator.IS_IN;
        Schema.SObjectField lookupField                 = Schema.Lead.OwnerId;
        Schema.SObjectField lookupFieldOnRelatedSObject = Schema.User.Id;

        Test.startTest();
        QueryFilter queryFilter = (QueryFilter)new QueryFilter().filterBySubquery(lookupField, operator, lookupFieldOnRelatedSObject);
        Test.stopTest();

        String expectedQueryFilter = 'OwnerId ' + operator.getValue() + ' (SELECT ' + lookupFieldOnRelatedSObject.getDescribe().getName() + ' FROM User)';
        System.assertEquals(expectedQueryFilter, queryFilter.getValue());
    }

}