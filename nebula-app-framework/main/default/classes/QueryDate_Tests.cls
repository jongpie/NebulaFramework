/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class QueryDate_Tests {

    @isTest
    static void it_should_return_sobject_type() {
        QueryDate dt = QueryDate.CALENDAR_MONTH(Schema.User.CreatedDate);
        System.assertEquals(Schema.User.SObjectType, dt.getSObjectType());
    }

    @isTest
    static void it_should_return_calendar_month_string() {
        QueryDate dt = QueryDate.CALENDAR_MONTH(Schema.User.CreatedDate);
        System.assertEquals('CALENDAR_MONTH(CreatedDate)', dt.getValue());
    }

    @isTest
    static void it_should_return_calendar_quarter_string() {
        QueryDate dt = QueryDate.CALENDAR_QUARTER(Schema.User.CreatedDate);
        System.assertEquals('CALENDAR_QUARTER(CreatedDate)', dt.getValue());
    }

    @isTest
    static void it_should_return_calendar_year_string() {
        QueryDate dt = QueryDate.CALENDAR_YEAR(Schema.User.CreatedDate);
        System.assertEquals('CALENDAR_YEAR(CreatedDate)', dt.getValue());
    }

    @isTest
    static void it_should_return_day_in_month_string() {
        QueryDate dt = QueryDate.DAY_IN_MONTH(Schema.User.CreatedDate);
        System.assertEquals('DAY_IN_MONTH(CreatedDate)', dt.getValue());
    }

    @isTest
    static void it_should_return_day_in_week_string() {
        QueryDate dt = QueryDate.DAY_IN_WEEK(Schema.User.CreatedDate);
        System.assertEquals('DAY_IN_WEEK(CreatedDate)', dt.getValue());
    }

    @isTest
    static void it_should_return_day_in_year_string() {
        QueryDate dt = QueryDate.DAY_IN_YEAR(Schema.User.CreatedDate);
        System.assertEquals('DAY_IN_YEAR(CreatedDate)', dt.getValue());
    }

    @isTest
    static void it_should_return_day_only_string() {
        QueryDate dt = QueryDate.DAY_ONLY(Schema.User.CreatedDate);
        System.assertEquals('DAY_ONLY(CreatedDate)', dt.getValue());
    }

    @isTest
    static void it_should_return_fiscal_month_string() {
        QueryDate dt = QueryDate.FISCAL_MONTH(Schema.User.CreatedDate);
        System.assertEquals('FISCAL_MONTH(CreatedDate)', dt.getValue());
    }

    @isTest
    static void it_should_return_fiscal_quarter_string() {
        QueryDate dt = QueryDate.FISCAL_QUARTER(Schema.User.CreatedDate);
        System.assertEquals('FISCAL_QUARTER(CreatedDate)', dt.getValue());
    }

    @isTest
    static void it_should_return_fiscal_year_string() {
        QueryDate dt = QueryDate.FISCAL_YEAR(Schema.User.CreatedDate);
        System.assertEquals('FISCAL_YEAR(CreatedDate)', dt.getValue());
    }

    @isTest
    static void it_should_return_hour_in_day_string() {
        QueryDate dt = QueryDate.HOUR_IN_DAY(Schema.User.CreatedDate);
        System.assertEquals('HOUR_IN_DAY(CreatedDate)', dt.getValue());
    }

    @isTest
    static void it_should_return_week_in_month_string() {
        QueryDate dt = QueryDate.WEEK_IN_MONTH(Schema.User.CreatedDate);
        System.assertEquals('WEEK_IN_MONTH(CreatedDate)', dt.getValue());
    }

    @isTest
    static void it_should_return_week_in_year_string() {
        QueryDate dt = QueryDate.WEEK_IN_YEAR(Schema.User.CreatedDate);
        System.assertEquals('WEEK_IN_YEAR(CreatedDate)', dt.getValue());
    }

}