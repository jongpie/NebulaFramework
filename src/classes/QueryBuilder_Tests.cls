@isTest
public class QueryBuilder_Tests {
    @isTest
    static void it_should_call_sort_order_properly_ascending() {
        Schema.SObjectType objType = Contact.SObjectType;
        FieldSet queryFields = SObjectType.Contact.FieldSets.QueryFields;

        Test.startTest();
        QueryBuilder queryFactory = new QueryBuilder(objType,queryFields,null);
        queryFactory.orderBy(Contact.CreatedDate,QuerySortOrder.ASCENDING);
        Test.stopTest();

        System.assert(queryFactory.orderByList[0].contains(Contact.CreatedDate.getDescribe().getName()));
    }

    @isTest
    static void it_should_call_sort_order_properly_descending() {
        Schema.SObjectType objType = Contact.SObjectType;
        FieldSet queryFields = SObjectType.Contact.FieldSets.QueryFields;

        Test.startTest();
        QueryBuilder queryFactory = new QueryBuilder(objType,queryFields,null);
        queryFactory.orderBy(Contact.CreatedDate,QuerySortOrder.DESCENDING);
        Test.stopTest();

        System.assert(queryFactory.orderByList[0].contains(Contact.CreatedDate.getDescribe().getName()));
    }

    @isTest
    static void it_should_disable_common_fields_successfully() {
        Schema.SObjectType objType = Contact.SObjectType;
        FieldSet queryFields = SObjectType.Contact.FieldSets.QueryFields;

        Test.startTest();
        QueryBuilder queryFactory = new QueryBuilder(objType,queryFields,null);
        queryFactory.turnOffCommonFields();
        Test.stopTest();

        System.assert(!queryFactory.shouldAddCommonFields);
    }

    @isTest
    static void it_should_set_for_update() {
        Schema.SObjectType objType = Contact.SObjectType;
        FieldSet queryFields = SObjectType.Contact.FieldSets.QueryFields;

        Test.startTest();
        QueryBuilder queryFactory = new QueryBuilder(objType,queryFields,null);
        queryFactory.setAsUpdate();
        Test.stopTest();

        System.assert(queryFactory.forUpdate);
    }
}