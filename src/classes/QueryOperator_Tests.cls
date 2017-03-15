@isTest
private class QueryOperator_Tests {

    @isTest
    static void it_should_return_EQUALS_string() {
        System.assertEquals('=', new QueryOperator().EQUALS.getValue());
    }

    @isTest
    static void it_should_return_NOT_EQUAL_TO_string() {
        System.assertEquals('!=', new QueryOperator().NOT_EQUAL_TO.getValue());
    }

    @isTest
    static void it_should_return_GREATER_THAN_string() {
        System.assertEquals('>', new QueryOperator().GREATER_THAN.getValue());
    }

    @isTest
    static void it_should_return_GREATER_THAN_OR_EQUAL_TO_string() {
        System.assertEquals('>=', new QueryOperator().GREATER_THAN_OR_EQUAL_TO.getValue());
    }

    @isTest
    static void it_should_return_LESS_THAN_string() {
        System.assertEquals('<', new QueryOperator().LESS_THAN.getValue());
    }

    @isTest
    static void it_should_return_LESS_THAN_OR_EQUAL_TO_string() {
        System.assertEquals('<=', new QueryOperator().LESS_THAN_OR_EQUAL_TO.getValue());
    }

    @isTest
    static void it_should_return_IS_IN_string() {
        System.assertEquals('IN', new QueryOperator().IS_IN.getValue());
    }

    @isTest
    static void it_should_return_IS_NOT_IN_string() {
        System.assertEquals('NOT IN', new QueryOperator().IS_NOT_IN.getValue());
    }

    @isTest
    static void it_should_return_INCLUDES_string() {
        System.assertEquals('INCLUDES', new QueryOperator().INCLUDES.getValue());
    }

    @isTest
    static void it_should_return_EXCLUDES_string() {
        System.assertEquals('EXCLUDES', new QueryOperator().EXCLUDES.getValue());
    }

    @isTest
    static void it_should_return_IS_LIKE_string() {
        System.assertEquals('LIKE', new QueryOperator().IS_LIKE.getValue());
    }

    @isTest
    static void it_should_return_IS_NOT_LIKE_string() {
        System.assertEquals('NOT LIKE', new QueryOperator().IS_NOT_LIKE.getValue());
    }

}