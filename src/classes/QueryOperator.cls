/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Query Builder
*
* @description Provides all of the operators needed for SOQL/SOSL queries and minimizes the use of strings within the framework
* Salesforce docs: developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_comparisonoperators.htm
*
*/
public without sharing class QueryOperator {

    private String value;

    private QueryOperator(String value) {
        this.value = value;
    }

    public String getValue() {
        return this.value;
    }

    public static final QueryOperator EQUALS                   = new QueryOperator('=');
    public static final QueryOperator NOT_EQUAL_TO             = new QueryOperator('!=');
    public static final QueryOperator GREATER_THAN             = new QueryOperator('>');
    public static final QueryOperator GREATER_THAN_OR_EQUAL_TO = new QueryOperator('>=');
    public static final QueryOperator LESS_THAN                = new QueryOperator('<');
    public static final QueryOperator LESS_THAN_OR_EQUAL_TO    = new QueryOperator('<=');
    public static final QueryOperator IS_IN                    = new QueryOperator('IN');
    public static final QueryOperator IS_NOT_IN                = new QueryOperator('NOT IN');
    public static final QueryOperator INCLUDES                 = new QueryOperator('INCLUDES');
    public static final QueryOperator EXCLUDES                 = new QueryOperator('EXCLUDES');
    public static final QueryOperator IS_LIKE                  = new QueryOperator('LIKE');
    public static final QueryOperator IS_NOT_LIKE              = new QueryOperator('NOT LIKE');

}