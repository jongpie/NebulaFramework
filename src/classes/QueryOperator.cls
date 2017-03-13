public without sharing class QueryOperator {

    private String value;

    public String getValue() {
        return this.value;
    }

    //Actual constant literals
    public QueryOperator EQUALS {
        get {return this.setValue('EQUALS');}
    }

    public QueryOperator NOT_EQUAL_TO {
        get {return this.setValue('NOT_EQUAL_TO');}
    }

    public QueryOperator GREATER_THAN {
        get {return this.setValue('GREATER_THAN');}
    }

    public QueryOperator GREATER_THAN_OR_EQUAL_TO {
        get {return this.setValue('GREATER_THAN_OR_EQUAL_TO');}
    }

    public QueryOperator LESS_THAN {
        get {return this.setValue('LESS_THAN');}
    }

    public QueryOperator LESS_THAN_OR_EQUAL_TO {
        get {return this.setValue('LESS_THAN_OR_EQUAL_TO');}
    }

    public QueryOperator IS_IN {
        get {return this.setValue('IS_IN');}
    }

    public QueryOperator IS_NOT_IN {
        get {return this.setValue('IS_NOT_IN');}
    }

    public QueryOperator INCLUDES {
        get {return this.setValue('INCLUDES');}
    }

    public QueryOperator EXCLUDES {
        get {return this.setValue('EXCLUDES');}
    }

    public QueryOperator IS_LIKE {
        get {return this.setValue('IS_LIKE');}
    }

    public QueryOperator IS_NOT_LIKE {
        get {return this.setValue('IS_NOT_LIKE');}
    }

    private QueryOperator setValue(String value) {
        this.value = value;
        return this;
    }

}