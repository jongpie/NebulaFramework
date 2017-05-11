/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class QueryOperator_Tests {

    @isTest
    static void it_should_return_EQUALS_string() {
        System.assertEquals('=', QueryOperator.EQUALS.getValue());
    }

    @isTest
    static void it_should_return_NOT_EQUAL_TO_string() {
        System.assertEquals('!=', QueryOperator.NOT_EQUAL_TO.getValue());
    }

    @isTest
    static void it_should_return_GREATER_THAN_string() {
        System.assertEquals('>', QueryOperator.GREATER_THAN.getValue());
    }

    @isTest
    static void it_should_return_GREATER_THAN_OR_EQUAL_TO_string() {
        System.assertEquals('>=', QueryOperator.GREATER_THAN_OR_EQUAL_TO.getValue());
    }

    @isTest
    static void it_should_return_LESS_THAN_string() {
        System.assertEquals('<', QueryOperator.LESS_THAN.getValue());
    }

    @isTest
    static void it_should_return_LESS_THAN_OR_EQUAL_TO_string() {
        System.assertEquals('<=', QueryOperator.LESS_THAN_OR_EQUAL_TO.getValue());
    }

    @isTest
    static void it_should_return_IS_IN_string() {
        System.assertEquals('IN', QueryOperator.IS_IN.getValue());
    }

    @isTest
    static void it_should_return_IS_NOT_IN_string() {
        System.assertEquals('NOT IN', QueryOperator.IS_NOT_IN.getValue());
    }

    @isTest
    static void it_should_return_INCLUDES_string() {
        System.assertEquals('INCLUDES', QueryOperator.INCLUDES.getValue());
    }

    @isTest
    static void it_should_return_EXCLUDES_string() {
        System.assertEquals('EXCLUDES', QueryOperator.EXCLUDES.getValue());
    }

    @isTest
    static void it_should_return_IS_LIKE_string() {
        System.assertEquals('LIKE', QueryOperator.IS_LIKE.getValue());
    }

    @isTest
    static void it_should_return_IS_NOT_LIKE_string() {
        System.assertEquals('NOT LIKE', QueryOperator.IS_NOT_LIKE.getValue());
    }

}