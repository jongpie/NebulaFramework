/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public without sharing class QueryOperator {

    private String value;

    private QueryOperator(String value) {
        this.value = value;
    }

    public String getValue() {
        return this.value;
    }

    public static QueryOperator EQUALS {
        get {return new QueryOperator('=');}
    }

    public static QueryOperator NOT_EQUAL_TO {
        get {return new QueryOperator('!=');}
    }

    public static QueryOperator GREATER_THAN {
        get {return new QueryOperator('>');}
    }

    public static QueryOperator GREATER_THAN_OR_EQUAL_TO {
        get {return new QueryOperator('>=');}
    }

    public static QueryOperator LESS_THAN {
        get {return new QueryOperator('<');}
    }

    public static QueryOperator LESS_THAN_OR_EQUAL_TO {
        get {return new QueryOperator('<=');}
    }

    public static QueryOperator IS_IN {
        get {return new QueryOperator('IN');}
    }

    public static QueryOperator IS_NOT_IN {
        get {return new QueryOperator('NOT IN');}
    }

    public static QueryOperator INCLUDES {
        get {return new QueryOperator('INCLUDES');}
    }

    public static QueryOperator EXCLUDES {
        get {return new QueryOperator('EXCLUDES');}
    }

    public static QueryOperator IS_LIKE {
        get {return new QueryOperator('LIKE');}
    }

    public static QueryOperator IS_NOT_LIKE {
        get {return new QueryOperator('NOT LIKE');}
    }

}