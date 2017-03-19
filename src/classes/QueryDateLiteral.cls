/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public without sharing class QueryDateLiteral {

    private final String LAST_N = 'LAST_N_{0}: {1}';
    private final String NEXT_N = 'NEXT_N_{0}: {1}';

    private final String DAYS            = 'DAYS';
    private final String WEEKS           = 'WEEKS';
    private final String MONTHS          = 'MONTHS';
    private final String QUARTERS        = 'QUARTERS';
    private final String FISCAL_QUARTERS = 'FISCAL_QUARTERS';
    private final String YEARS           = 'YEARS';
    private final String FISCAL_YEARS    = 'FISCAL_YEARS';

    private String value;

    public String getValue() {
        return this.value;
    }

    //Actual constant literals
    public QueryDateLiteral YESTERDAY {
        get {return this.setValue('YESTERDAY');}
    }

    public QueryDateLiteral TODAY {
        get {return this.setValue('TODAY');}
    }

    public QueryDateLiteral TOMORROW {
        get {return this.setValue('TOMORROW');}
    }

    public QueryDateLiteral LAST_WEEK {
        get {return this.setValue('LAST_WEEK');}
    }

    public QueryDateLiteral THIS_WEEK {
        get {return this.setValue('THIS_WEEK');}
    }

    public QueryDateLiteral NEXT_WEEK {
        get {return this.setValue('NEXT_WEEK');}
    }

    public QueryDateLiteral LAST_MONTH {
        get {return this.setValue('LAST_MONTH');}
    }

    public QueryDateLiteral THIS_MONTH {
        get {return this.setValue('THIS_MONTH');}
    }

    public QueryDateLiteral NEXT_MONTH {
        get {return this.setValue('NEXT_MONTH');}
    }

    public QueryDateLiteral LAST_90_DAYS {
        get {return this.setValue('LAST_90_DAYS');}
    }

    public QueryDateLiteral NEXT_90_DAYS {
        get {return this.setValue('NEXT_90_DAYS');}
    }

    public QueryDateLiteral THIS_QUARTER {
        get {return this.setValue('THIS_QUARTER');}
    }

    public QueryDateLiteral THIS_FISCAL_QUARTER {
        get {return this.setValue('THIS_FISCAL_QUARTER');}
    }

    public QueryDateLiteral LAST_QUARTER {
        get {return this.setValue('LAST_QUARTER');}
    }

    public QueryDateLiteral LAST_FISCAL_QUARTER {
        get {return this.setValue('LAST_FISCAL_QUARTER');}
    }

    public QueryDateLiteral NEXT_QUARTER {
        get {return this.setValue('NEXT_QUARTER');}
    }

    public QueryDateLiteral NEXT_FISCAL_QUARTER {
        get {return this.setValue('NEXT_FISCAL_QUARTER');}
    }

    public QueryDateLiteral THIS_YEAR {
        get {return this.setValue('THIS_YEAR');}
    }

    public QueryDateLiteral THIS_FISCAL_YEAR {
        get {return this.setValue('THIS_FISCAL_YEAR');}
    }

    public QueryDateLiteral LAST_YEAR {
        get {return this.setValue('LAST_YEAR');}
    }

    public QueryDateLiteral LAST_FISCAL_YEAR {
        get {return this.setValue('LAST_FISCAL_YEAR');}
    }

    public QueryDateLiteral NEXT_YEAR {
        get {return this.setValue('NEXT_YEAR');}
    }

    public QueryDateLiteral NEXT_FISCAL_YEAR {
        get {return this.setValue('NEXT_FISCAL_YEAR');}
    }

    ////Buildable literals
    public QueryDateLiteral LAST_N_DAYS(Integer num) {
        String parsedValue = String.format(LAST_N, new List<String>{DAYS,String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public QueryDateLiteral LAST_N_WEEKS(Integer num) {
        String parsedValue = String.format(LAST_N, new List<String>{WEEKS, String.valueof(num)});
        return this.setValue(parsedValue);
    }

    public QueryDateLiteral LAST_N_MONTHS(Integer num) {
        String parsedValue = String.format(LAST_N, new List<String>{MONTHS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public QueryDateLiteral LAST_N_QUARTERS(Integer num) {
        String parsedValue = String.format(LAST_N, new List<String>{QUARTERS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public QueryDateLiteral LAST_N_YEARS(Integer num) {
        String parsedValue = String.format(LAST_N, new List<String>{YEARS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public QueryDateLiteral LAST_N_FISCAL_YEARS(Integer num) {
        String parsedValue = String.format(LAST_N, new List<String>{FISCAL_YEARS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public QueryDateLiteral NEXT_N_DAYS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{DAYS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public QueryDateLiteral NEXT_N_WEEKS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{WEEKS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public QueryDateLiteral NEXT_N_MONTHS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{MONTHS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public QueryDateLiteral NEXT_N_QUARTERS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{QUARTERS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public QueryDateLiteral NEXT_N_FISCAL_QUARTERS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{FISCAL_QUARTERS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public QueryDateLiteral NEXT_N_YEARS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{YEARS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public QueryDateLiteral NEXT_N_FISCAL_YEARS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{FISCAL_YEARS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    private QueryDateLiteral setValue(String value) {
        this.value = value;
        return this;
    }
}