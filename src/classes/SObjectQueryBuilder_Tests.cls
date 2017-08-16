/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class SObjectQueryBuilder_Tests {

    @isTest
    static void it_should_call_sort_order_properly_ascending() {
        Schema.SObjectType objType = Contact.SObjectType;
        List<SObjectField> fields = new List<SObjectField>{Contact.CreatedDate};

        Test.startTest();
        SObjectQueryBuilder query = (SObjectQueryBuilder)new SObjectQueryBuilder().setSObjectType(objType).addFields(fields);
        query.orderBy(Contact.CreatedDate,QuerySortOrder.ASCENDING);
        Test.stopTest();

        System.assert(query.orderByList[0].contains(Contact.CreatedDate.getDescribe().getName()));
    }

    @isTest
    static void it_should_call_sort_order_properly_descending() {
        Schema.SObjectType objType = Contact.SObjectType;
        List<SObjectField> fields = new List<SObjectField>{Contact.CreatedDate};

        Test.startTest();
        SObjectQueryBuilder query = (SObjectQueryBuilder)new SObjectQueryBuilder().setSObjectType(objType).addFields(fields);
        query.orderBy(Contact.CreatedDate,QuerySortOrder.DESCENDING);
        Test.stopTest();

        System.assert(query.orderByList[0].contains(Contact.CreatedDate.getDescribe().getName()));
    }

    @isTest
    static void it_should_set_for_update() {
        Schema.SObjectType objType = Contact.SObjectType;
        List<SObjectField> fields = new List<SObjectField>{Contact.CreatedDate};

        Test.startTest();
        SObjectQueryBuilder query = (SObjectQueryBuilder)new SObjectQueryBuilder().setSObjectType(objType).addFields(fields);
        query.setAsUpdate();
        Test.stopTest();

        System.assert(query.forUpdate);
    }

    @isTest
    static void it_should_generate_a_query_with_a_subselect() {
        List<Lead> leads = (List<Lead>)new SObjectQueryBuilder()
            .setSObjectType(Schema.Lead.SObjectType)
            .inSubquery(Schema.Lead.OwnerId, Schema.User.Id)
            .getQueryResults();

        // TODO finish writings tests System.assert(false, 'finish writing tests');
    }

}