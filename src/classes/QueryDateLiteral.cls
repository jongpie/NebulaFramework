/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Query Builder
*
* @description TODO
*
*/
public without sharing class QueryDateLiteral {

    private String value;

    public String getValue() {
        return this.value;
    }

    private QueryDateLiteral(String value) {
        this.value = value;
    }

    // Actual constant literals
    public static final QueryDateLiteral YESTERDAY           = new QueryDateLiteral('YESTERDAY');
    public static final QueryDateLiteral TODAY               = new QueryDateLiteral('TODAY');
    public static final QueryDateLiteral TOMORROW            = new QueryDateLiteral('TOMORROW');
    public static final QueryDateLiteral LAST_WEEK           = new QueryDateLiteral('LAST_WEEK');
    public static final QueryDateLiteral THIS_WEEK           = new QueryDateLiteral('THIS_WEEK');
    public static final QueryDateLiteral NEXT_WEEK           = new QueryDateLiteral('NEXT_WEEK');
    public static final QueryDateLiteral LAST_MONTH          = new QueryDateLiteral('LAST_MONTH');
    public static final QueryDateLiteral THIS_MONTH          = new QueryDateLiteral('THIS_MONTH');
    public static final QueryDateLiteral NEXT_MONTH          = new QueryDateLiteral('NEXT_MONTH');
    public static final QueryDateLiteral LAST_90_DAYS        = new QueryDateLiteral('LAST_90_DAYS');
    public static final QueryDateLiteral NEXT_90_DAYS        = new QueryDateLiteral('NEXT_90_DAYS');
    public static final QueryDateLiteral LAST_QUARTER        = new QueryDateLiteral('LAST_QUARTER');
    public static final QueryDateLiteral THIS_QUARTER        = new QueryDateLiteral('THIS_QUARTER');
    public static final QueryDateLiteral NEXT_QUARTER        = new QueryDateLiteral('NEXT_QUARTER');
    public static final QueryDateLiteral LAST_FISCAL_QUARTER = new QueryDateLiteral('LAST_FISCAL_QUARTER');
    public static final QueryDateLiteral THIS_FISCAL_QUARTER = new QueryDateLiteral('THIS_FISCAL_QUARTER');
    public static final QueryDateLiteral NEXT_FISCAL_QUARTER = new QueryDateLiteral('NEXT_FISCAL_QUARTER');
    public static final QueryDateLiteral LAST_YEAR           = new QueryDateLiteral('LAST_YEAR');
    public static final QueryDateLiteral THIS_YEAR           = new QueryDateLiteral('THIS_YEAR');
    public static final QueryDateLiteral NEXT_YEAR           = new QueryDateLiteral('NEXT_YEAR');
    public static final QueryDateLiteral LAST_FISCAL_YEAR    = new QueryDateLiteral('LAST_FISCAL_YEAR');
    public static final QueryDateLiteral THIS_FISCAL_YEAR    = new QueryDateLiteral('THIS_FISCAL_YEAR');
    public static final QueryDateLiteral NEXT_FISCAL_YEAR    = new QueryDateLiteral('NEXT_FISCAL_YEAR');

    private static final String LAST_N     = 'LAST_N_{0}:{1}';
    private static final String NEXT_N     = 'NEXT_N_{0}:{1}';
    private static final String N_DAYS_AGO = 'N_DAYS_AGO:{0}';

    private static final String DAYS            = 'DAYS';
    private static final String WEEKS           = 'WEEKS';
    private static final String MONTHS          = 'MONTHS';
    private static final String QUARTERS        = 'QUARTERS';
    private static final String YEARS           = 'YEARS';
    private static final String FISCAL_QUARTERS = 'FISCAL_QUARTERS';
    private static final String FISCAL_YEARS    = 'FISCAL_YEARS';

    // Buildable literals
    public static QueryDateLiteral N_DAYS_AGO(Integer num) {
        String parsedValue = String.format(N_DAYS_AGO, new List<String>{String.valueOf(num)});
        return new QueryDateLiteral(parsedValue);
    }

    public static QueryDateLiteral LAST_N_DAYS(Integer num) {
        return buildQueryDateLiteral(LAST_N, DAYS, num);
    }

    public static QueryDateLiteral LAST_N_WEEKS(Integer num) {
        return buildQueryDateLiteral(LAST_N, WEEKS, num);
    }

    public static QueryDateLiteral LAST_N_MONTHS(Integer num) {
        return buildQueryDateLiteral(LAST_N, MONTHS, num);
    }

    public static QueryDateLiteral LAST_N_QUARTERS(Integer num) {
        return buildQueryDateLiteral(LAST_N, QUARTERS, num);
    }

    public static QueryDateLiteral LAST_N_YEARS(Integer num) {
        return buildQueryDateLiteral(LAST_N, YEARS, num);
    }

    public static QueryDateLiteral LAST_N_FISCAL_YEARS(Integer num) {
        return buildQueryDateLiteral(LAST_N, FISCAL_YEARS, num);
    }

    public static QueryDateLiteral NEXT_N_DAYS(Integer num) {
        return buildQueryDateLiteral(NEXT_N, DAYS, num);
    }

    public static QueryDateLiteral NEXT_N_WEEKS(Integer num) {
        return buildQueryDateLiteral(NEXT_N, WEEKS, num);
    }

    public static QueryDateLiteral NEXT_N_MONTHS(Integer num) {
        return buildQueryDateLiteral(NEXT_N, MONTHS, num);
    }

    public static QueryDateLiteral NEXT_N_QUARTERS(Integer num) {
        return buildQueryDateLiteral(NEXT_N, QUARTERS, num);
    }

    public static QueryDateLiteral NEXT_N_FISCAL_QUARTERS(Integer num) {
        return buildQueryDateLiteral(NEXT_N, FISCAL_QUARTERS, num);
    }

    public static QueryDateLiteral NEXT_N_YEARS(Integer num) {
        return buildQueryDateLiteral(NEXT_N, YEARS, num);
    }

    public static QueryDateLiteral NEXT_N_FISCAL_YEARS(Integer num) {
        return buildQueryDateLiteral(NEXT_N, FISCAL_YEARS, num);
    }

    private static QueryDateLiteral buildQueryDateLiteral(String base, String period, Integer num) {
        String parsedValue = String.format(base, new List<String>{period, String.valueOf(num)});
        return new QueryDateLiteral(parsedValue);
    }

}