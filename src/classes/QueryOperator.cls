/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public without sharing class QueryOperator {

    private String value;

    public String getValue() {
        return this.value;
    }

    //Actual constant literals
    public QueryOperator EQUALS {
        get {return this.setValue('=');}
    }

    public QueryOperator NOT_EQUAL_TO {
        get {return this.setValue('!=');}
    }

    public QueryOperator GREATER_THAN {
        get {return this.setValue('>');}
    }

    public QueryOperator GREATER_THAN_OR_EQUAL_TO {
        get {return this.setValue('>=');}
    }

    public QueryOperator LESS_THAN {
        get {return this.setValue('<');}
    }

    public QueryOperator LESS_THAN_OR_EQUAL_TO {
        get {return this.setValue('<=');}
    }

    public QueryOperator IS_IN {
        get {return this.setValue('IN');}
    }

    public QueryOperator IS_NOT_IN {
        get {return this.setValue('NOT IN');}
    }

    public QueryOperator INCLUDES {
        get {return this.setValue('INCLUDES');}
    }

    public QueryOperator EXCLUDES {
        get {return this.setValue('EXCLUDES');}
    }

    public QueryOperator IS_LIKE {
        get {return this.setValue('LIKE');}
    }

    public QueryOperator IS_NOT_LIKE {
        get {return this.setValue('NOT LIKE');}
    }

    private QueryOperator setValue(String value) {
        this.value = value;
        return this;
    }
}