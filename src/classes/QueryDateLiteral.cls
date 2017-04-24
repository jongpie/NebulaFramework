/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public without sharing class QueryDateLiteral {

    private final static String LAST_N = 'LAST_N_{0}: {1}';
    private final static String NEXT_N = 'NEXT_N_{0}: {1}';
    private final static String N_DAYS_AGO = 'N_DAYS_AGO: {0}';

    private final static String DAYS            = 'DAYS';
    private final static String WEEKS           = 'WEEKS';
    private final static String MONTHS          = 'MONTHS';
    private final static String QUARTERS        = 'QUARTERS';
    private final static String FISCAL_QUARTERS = 'FISCAL_QUARTERS';
    private final static String YEARS           = 'YEARS';
    private final static String FISCAL_YEARS    = 'FISCAL_YEARS';

    private String value;

    public String getValue() {
        return this.value;
    }

    private QueryDateLiteral(String value) {
        this.value = value;
    }

    //Actual constant literals
    public static QueryDateLiteral YESTERDAY {
        get { return new QueryDateLiteral('YESTERDAY'); }
    }

    public static QueryDateLiteral TODAY {
        get { return new QueryDateLiteral('TODAY'); }
    }

    public static QueryDateLiteral TOMORROW {
        get { return new QueryDateLiteral('TOMORROW'); }
    }

    public static QueryDateLiteral LAST_WEEK {
        get { return new QueryDateLiteral('LAST_WEEK'); }
    }

    public static QueryDateLiteral THIS_WEEK {
        get { return new QueryDateLiteral('THIS_WEEK'); }
    }

    public static QueryDateLiteral NEXT_WEEK {
        get { return new QueryDateLiteral('NEXT_WEEK'); }
    }

    public static QueryDateLiteral LAST_MONTH {
        get { return new QueryDateLiteral('LAST_MONTH'); }
    }

    public static QueryDateLiteral THIS_MONTH {
         get { return new QueryDateLiteral('THIS_MONTH'); }
    }

    public static QueryDateLiteral NEXT_MONTH {
       get { return new QueryDateLiteral('NEXT_MONTH'); }
    }

    public static QueryDateLiteral LAST_90_DAYS {
        get { return new QueryDateLiteral('LAST_90_DAYS'); }
    }

    public static QueryDateLiteral NEXT_90_DAYS {
       get { return new QueryDateLiteral('NEXT_90_DAYS'); }
    }

    public static QueryDateLiteral THIS_QUARTER {
        get { return new QueryDateLiteral('THIS_QUARTER'); }
    }

    public static QueryDateLiteral THIS_FISCAL_QUARTER {
        get { return new QueryDateLiteral('THIS_FISCAL_QUARTER'); }
    }

    public static QueryDateLiteral LAST_QUARTER {
        get { return new QueryDateLiteral('LAST_QUARTER'); }
    }

    public static QueryDateLiteral LAST_FISCAL_QUARTER {
        get { return new QueryDateLiteral('LAST_FISCAL_QUARTER'); }
    }

    public static QueryDateLiteral NEXT_QUARTER {
        get { return new QueryDateLiteral('NEXT_QUARTER'); }
    }

    public static QueryDateLiteral NEXT_FISCAL_QUARTER {
       get { return new QueryDateLiteral('NEXT_FISCAL_QUARTER'); }
    }

    public static QueryDateLiteral THIS_YEAR {
       get { return new QueryDateLiteral('THIS_YEAR'); }
    }

    public static QueryDateLiteral THIS_FISCAL_YEAR {
        get { return new QueryDateLiteral('THIS_FISCAL_YEAR'); }
    }

    public static QueryDateLiteral LAST_YEAR {
        get { return new QueryDateLiteral('LAST_YEAR'); }
    }

    public static QueryDateLiteral LAST_FISCAL_YEAR {
       get { return new QueryDateLiteral('LAST_FISCAL_YEAR'); }
    }

    public static QueryDateLiteral NEXT_YEAR {
        get { return new QueryDateLiteral('NEXT_YEAR'); }
    }

    public static QueryDateLiteral NEXT_FISCAL_YEAR {
        get { return new QueryDateLiteral('NEXT_FISCAL_YEAR'); }
    }

    ////Buildable literals
     public static QueryDateLiteral N_DAYS_AGO(Integer num) {
        String parsedValue = String.format(N_DAYS_AGO, new List<String>{String.valueOf(num)});
        return new QueryDateLiteral(parsedValue);
    }

     public static QueryDateLiteral LAST_N_DAYS(Integer num) {
        String parsedValue = String.format(LAST_N, new List<String>{DAYS,String.valueOf(num)});
        return new QueryDateLiteral(parsedValue);
    }

     public static QueryDateLiteral LAST_N_WEEKS(Integer num) {
        String parsedValue = String.format(LAST_N, new List<String>{WEEKS, String.valueof(num)});
        return new QueryDateLiteral(parsedValue);
    }

     public static QueryDateLiteral LAST_N_MONTHS(Integer num) {
        String parsedValue = String.format(LAST_N, new List<String>{MONTHS, String.valueOf(num)});
        return new QueryDateLiteral(parsedValue);
    }

     public static QueryDateLiteral LAST_N_QUARTERS(Integer num) {
        String parsedValue = String.format(LAST_N, new List<String>{QUARTERS, String.valueOf(num)});
        return new QueryDateLiteral(parsedValue);
    }

     public static QueryDateLiteral LAST_N_YEARS(Integer num) {
        String parsedValue = String.format(LAST_N, new List<String>{YEARS, String.valueOf(num)});
        return new QueryDateLiteral(parsedValue);
    }

     public static QueryDateLiteral LAST_N_FISCAL_YEARS(Integer num) {
        String parsedValue = String.format(LAST_N, new List<String>{FISCAL_YEARS, String.valueOf(num)});
        return new QueryDateLiteral(parsedValue);
    }

     public static QueryDateLiteral NEXT_N_DAYS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{DAYS, String.valueOf(num)});
        return new QueryDateLiteral(parsedValue);
    }

     public static QueryDateLiteral NEXT_N_WEEKS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{WEEKS, String.valueOf(num)});
        return new QueryDateLiteral(parsedValue);
    }

     public static QueryDateLiteral NEXT_N_MONTHS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{MONTHS, String.valueOf(num)});
        return new QueryDateLiteral(parsedValue);
    }

     public static QueryDateLiteral NEXT_N_QUARTERS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{QUARTERS, String.valueOf(num)});
        return new QueryDateLiteral(parsedValue);
    }

     public static QueryDateLiteral NEXT_N_FISCAL_QUARTERS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{FISCAL_QUARTERS, String.valueOf(num)});
        return new QueryDateLiteral(parsedValue);
    }

     public static QueryDateLiteral NEXT_N_YEARS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{YEARS, String.valueOf(num)});
        return new QueryDateLiteral(parsedValue);
    }

     public static QueryDateLiteral NEXT_N_FISCAL_YEARS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{FISCAL_YEARS, String.valueOf(num)});
        return new QueryDateLiteral(parsedValue);
    }

    private QueryDateLiteral setValue(String value) {
        this.value = value;
        return this;
    }
}