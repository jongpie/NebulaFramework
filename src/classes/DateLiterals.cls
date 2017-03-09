public class DateLiterals {

    private final String LAST_N = 'LAST_N_{0}: {1}';
    private final String NEXT_N = 'NEXT_N_{0}: {1}';

    private final String DAYS            = 'DAYS';
    private final String WEEKS           = 'WEEKS';
    private final String MONTHS          = 'MONTHS';
    private final String QUARTERS        = 'QUARTERS';
    private final String FISCAL_QUARTERS = 'FISCAL_QUARTERS';
    private final String YEARS           = 'YEARS';
    private final String FISCAL_YEARS    = 'FISCAL_YEARS';

    public String value {get; private set;}

    //Actual constant literals
    public DateLiterals YESTERDAY {
        get {return this.setValue('YESTERDAY');}
    }

    public DateLiterals TODAY {
        get {return this.setValue('TODAY');}
    }

    public DateLiterals TOMORROW {
        get {return this.setValue('TOMORROW');}
    }

    public DateLiterals LAST_WEEK {
        get {return this.setValue('LAST_WEEK');}
    }

    public DateLiterals THIS_WEEK {
        get {return this.setValue('THIS_WEEK');}
    }

    public DateLiterals NEXT_WEEK {
        get {return this.setValue('NEXT_WEEK');}
    }

    public DateLiterals LAST_MONTH {
        get {return this.setValue('LAST_MONTH');}
    }

    public DateLiterals THIS_MONTH {
        get {return this.setValue('THIS_MONTH');}
    }

    public DateLiterals NEXT_MONTH {
        get {return this.setValue('NEXT_MONTH');}
    }

    public DateLiterals LAST_90_DAYS {
        get {return this.setValue('LAST_90_DAYS');}
    }

    public DateLiterals NEXT_90_DAYS {
        get {return this.setValue('NEXT_90_DAYS');}
    }

    public DateLiterals THIS_QUARTER {
        get {return this.setValue('THIS_QUARTER');}
    }

    public DateLiterals THIS_FISCAL_QUARTER {
        get {return this.setValue('THIS_FISCAL_QUARTER');}
    }

    public DateLiterals LAST_QUARTER {
        get {return this.setValue('LAST_QUARTER');}
    }

    public DateLiterals LAST_FISCAL_QUARTER {
        get {return this.setValue('LAST_FISCAL_QUARTER');}
    }

    public DateLiterals NEXT_QUARTER {
        get {return this.setValue('NEXT_QUARTER');}
    }

    public DateLiterals NEXT_FISCAL_QUARTER {
        get {return this.setValue('NEXT_FISCAL_QUARTER');}
    }

    public DateLiterals THIS_YEAR {
        get {return this.setValue('THIS_YEAR');}
    }

    public DateLiterals THIS_FISCAL_YEAR {
        get {return this.setValue('THIS_FISCAL_YEAR');}
    }

    public DateLiterals LAST_YEAR {
        get {return this.setValue('LAST_YEAR');}
    }

    public DateLiterals LAST_FISCAL_YEAR {
        get {return this.setValue('LAST_FISCAL_YEAR');}
    }

    public DateLiterals NEXT_YEAR {
        get {return this.setValue('NEXT_YEAR');}
    }

    public DateLiterals NEXT_FISCAL_YEAR {
        get {return this.setValue('NEXT_FISCAL_YEAR');}
    }

    ////Buildable literals
    public DateLiterals LAST_N_DAYS(Integer num) {
        String parsedValue = String.format(LAST_N, new List<String>{DAYS,String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public DateLiterals LAST_N_WEEKS(Integer num) {
        String parsedValue = String.format(LAST_N, new List<String>{WEEKS, String.valueof(num)});
        return this.setValue(parsedValue);
    }

    public DateLiterals LAST_N_MONTHS(Integer num) {
        String parsedValue = String.format(LAST_N, new List<String>{MONTHS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public DateLiterals LAST_N_QUARTERS(Integer num) {
        String parsedValue = String.format(LAST_N, new List<String>{QUARTERS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public DateLiterals LAST_N_YEARS(Integer num) {
        String parsedValue = String.format(LAST_N, new List<String>{YEARS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public DateLiterals LAST_N_FISCAL_YEARS(Integer num) {
        String parsedValue = String.format(LAST_N, new List<String>{FISCAL_YEARS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public DateLiterals NEXT_N_DAYS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{DAYS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public DateLiterals NEXT_N_WEEKS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{WEEKS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public DateLiterals NEXT_N_MONTHS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{MONTHS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public DateLiterals NEXT_N_QUARTERS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{QUARTERS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public DateLiterals NEXT_N_FISCAL_QUARTERS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{FISCAL_QUARTERS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public DateLiterals NEXT_N_YEARS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{YEARS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    public DateLiterals NEXT_N_FISCAL_YEARS(Integer num) {
        String parsedValue = String.format(NEXT_N, new List<String>{FISCAL_YEARS, String.valueOf(num)});
        return this.setValue(parsedValue);
    }

    private DateLiterals setValue(String value) {
        this.value = value;
        return this;
    }

}