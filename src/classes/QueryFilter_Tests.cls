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
        List<String> values              = new List<String>{'derp'};

        Test.startTest();
        QueryFilter queryFilter = (QueryFilter)new QueryFilter().initialize(sobjectField, operator, values);
        Test.stopTest();

        String expectedQueryFieldName = 'CompanyName';
        System.assertEquals(expectedQueryFieldName, queryFilter.queryFieldName);

        String expectedQueryFilter = 'CompanyName ' + operator.getValue() + ' (\'' + String.join(values, '\',\'') + '\')';
        System.assertEquals(expectedQueryFilter, queryFilter.getValue());
    }

    @isTest
    static void it_should_return_the_query_filter_for_a_parent_field() {
        Schema.SObjectField parentRelationshipSObjectField = Schema.Lead.CreatedById;
        Schema.SObjectField sobjectField                   = Schema.User.Email;
        QueryOperator operator                             = QueryOperator.EQUALS;
        String value                                       = 'derp@test.com';

        Test.startTest();
        QueryFilter queryFilter = (QueryFilter)new QueryFilter().initialize(parentRelationshipSObjectField, sobjectField, operator, value);
        Test.stopTest();

        String expectedQueryFieldName = 'CreatedBy.Email';
        System.assertEquals(expectedQueryFieldName, queryFilter.queryFieldName);

        String expectedQueryFilter = 'CreatedBy.Email ' + operator.getValue() + ' \'' + value + '\'';
        System.assertEquals(expectedQueryFilter, queryFilter.getValue());
    }

    @isTest
    static void it_should_return_the_query_filter_for_a_grandparent_field() {
        List<Schema.SObjectField> grandparentFields = new List<Schema.SObjectField>{
            Schema.Lead.OwnerId, Schema.User.ManagerId, Schema.User.ProfileId
        };

        Schema.SObjectField sobjectField = Schema.Profile.Name;
        QueryOperator operator           = QueryOperator.EQUALS;
        String value                     = 'derp';

        Test.startTest();
        QueryFilter queryFilter = (QueryFilter)new QueryFilter().initialize(grandparentFields, sobjectField, operator, value);
        Test.stopTest();

        String expectedQueryFieldName = 'Owner.Manager.Profile.Name';
        System.assertEquals(expectedQueryFieldName, queryFilter.queryFieldName);

        String expectedQueryFilter = 'Owner.Manager.Profile.Name ' + operator.getValue() + ' \'' + value + '\'';
        System.assertEquals(expectedQueryFilter, queryFilter.getValue());
    }

}