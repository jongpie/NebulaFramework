/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class QueryDateLiteral_Tests {

    private static Integer offsetNumber = 5;

    @isTest
    static void it_should_return_yesterday_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.YESTERDAY;
        System.assertEquals('YESTERDAY', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_today_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.TODAY;
        System.assertEquals('TODAY', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_tomorrow_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.TOMORROW;
        System.assertEquals('TOMORROW', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_last_week_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.LAST_WEEK;
        System.assertEquals('LAST_WEEK', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_this_week_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.THIS_WEEK;
        System.assertEquals('THIS_WEEK', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_next_week_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.NEXT_WEEK;
        System.assertEquals('NEXT_WEEK', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_last_month_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.LAST_MONTH;
        System.assertEquals('LAST_MONTH', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_this_month_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.THIS_MONTH;
        System.assertEquals('THIS_MONTH', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_next_month_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.NEXT_MONTH;
        System.assertEquals('NEXT_MONTH', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_last_ninety_days_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.LAST_90_DAYS;
        System.assertEquals('LAST_90_DAYS', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_next_ninety_days_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.NEXT_90_DAYS;
        System.assertEquals('NEXT_90_DAYS', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_this_quarter_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.THIS_QUARTER;
        System.assertEquals('THIS_QUARTER', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_last_quarter_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.LAST_QUARTER;
        System.assertEquals('LAST_QUARTER', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_last_fiscal_quarter_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.LAST_FISCAL_QUARTER;
        System.assertEquals('LAST_FISCAL_QUARTER', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_this_fiscal_quarter_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.THIS_FISCAL_QUARTER;
        System.assertEquals('THIS_FISCAL_QUARTER', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_next_quarter_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.NEXT_QUARTER;
        System.assertEquals('NEXT_QUARTER', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_next_fiscal_quarter_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.NEXT_FISCAL_QUARTER;
        System.assertEquals('NEXT_FISCAL_QUARTER', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_this_year_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.THIS_YEAR;
        System.assertEquals('THIS_YEAR', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_this_fiscal_year_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.THIS_FISCAL_YEAR;
        System.assertEquals('THIS_FISCAL_YEAR', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_last_year_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.LAST_YEAR;
        System.assertEquals('LAST_YEAR', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_last_fiscal_year_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.LAST_FISCAL_YEAR;
        System.assertEquals('LAST_FISCAL_YEAR', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_next_year_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.NEXT_YEAR;
        System.assertEquals('NEXT_YEAR', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_next_fiscal_year_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.NEXT_FISCAL_YEAR;
        System.assertEquals('NEXT_FISCAL_YEAR', dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_n_days_ago_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.N_DAYS_AGO(offsetNumber);
        System.assertEquals('N_DAYS_AGO:' + offsetNumber, dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_last_n_days_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.LAST_N_DAYS(offsetNumber);
        System.assertEquals('LAST_N_DAYS:' + offsetNumber, dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_last_n_weeks_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.LAST_N_WEEKS(offsetNumber);
        System.assertEquals('LAST_N_WEEKS:' + offsetNumber, dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_last_n_months_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.LAST_N_MONTHS(offsetNumber);
        System.assertEquals('LAST_N_MONTHS:' + offsetNumber, dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_last_n_quarters_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.LAST_N_QUARTERS(offsetNumber);
        System.assertEquals('LAST_N_QUARTERS:' + offsetNumber, dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_last_n_years_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.LAST_N_YEARS(offsetNumber);
        System.assertEquals('LAST_N_YEARS:' + offsetNumber, dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_last_n_fiscal_years_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.LAST_N_FISCAL_YEARS(offsetNumber);
        System.assertEquals('LAST_N_FISCAL_YEARS:' + offsetNumber, dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_next_n_days_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.NEXT_N_DAYS(offsetNumber);
        System.assertEquals('NEXT_N_DAYS:' + offsetNumber, dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_next_n_weeks_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.NEXT_N_WEEKS(offsetNumber);
        System.assertEquals('NEXT_N_WEEKS:' + offsetNumber, dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_next_n_months_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.NEXT_N_MONTHS(offsetNumber);
        System.assertEquals('NEXT_N_MONTHS:' + offsetNumber, dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_next_n_quarters_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.NEXT_N_QUARTERS(offsetNumber);
        System.assertEquals('NEXT_N_QUARTERS:' + offsetNumber, dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_next_n_fiscal_quarters_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.NEXT_N_FISCAL_QUARTERS(offsetNumber);
        System.assertEquals('NEXT_N_FISCAL_QUARTERS:' + offsetNumber, dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_next_n_years_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.NEXT_N_YEARS(offsetNumber);
        System.assertEquals('NEXT_N_YEARS:' + offsetNumber, dateLiteral.getValue());
    }

    @isTest
    static void it_should_return_next_n_fiscal_years_string() {
        QueryDateLiteral dateLiteral = QueryDateLiteral.NEXT_N_FISCAL_YEARS(offsetNumber);
        System.assertEquals('NEXT_N_FISCAL_YEARS:' + offsetNumber, dateLiteral.getValue());
    }

}