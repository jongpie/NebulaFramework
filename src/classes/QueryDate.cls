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
public without sharing class QueryDate extends NebulaCore { // TODO decide if this class is needed & if so, if there is a better name

    private Schema.SObjectField sobjectField;
    private Schema.SObjectType sobjectType;
    private String value;

    public String getValue() {
        return this.value;
    }

    public Schema.SObjectType getSObjectType() {
        return this.sobjectType;
    }

    private QueryDate setValue(Schema.SObjectField sobjectField, String value) {
        this.sobjectField = sobjectField;
        this.sobjectType  = new SObjectFieldDescriber(sobjectField).getSObjectType();
        this.value        = value;
        return this;
    }

    public static QueryDate CALENDAR_MONTH(Schema.SObjectField sobjectField) {
        return buildQueryDate('CALENDAR_MONTH', sobjectField);
    }

    public static QueryDate CALENDAR_QUARTER(Schema.SObjectField sobjectField) {
        return buildQueryDate('CALENDAR_QUARTER', sobjectField);
    }

    public static QueryDate CALENDAR_YEAR(Schema.SObjectField sobjectField) {
        return buildQueryDate('CALENDAR_YEAR', sobjectField);
    }

    public static QueryDate DAY_IN_MONTH(Schema.SObjectField sobjectField) {
        return buildQueryDate('DAY_IN_MONTH', sobjectField);
    }

    public static QueryDate DAY_IN_WEEK(Schema.SObjectField sobjectField) {
        return buildQueryDate('DAY_IN_WEEK', sobjectField);
    }

    public static QueryDate DAY_IN_YEAR(Schema.SObjectField sobjectField) {
        return buildQueryDate('DAY_IN_YEAR', sobjectField);
    }

    public static QueryDate DAY_ONLY(Schema.SObjectField sobjectField) {
        return buildQueryDate('DAY_ONLY', sobjectField);
    }

    public static QueryDate FISCAL_MONTH(Schema.SObjectField sobjectField) {
        return buildQueryDate('FISCAL_MONTH', sobjectField);
    }

    public static QueryDate FISCAL_QUARTER(Schema.SObjectField sobjectField) {
        return buildQueryDate('FISCAL_QUARTER', sobjectField);
    }

    public static QueryDate FISCAL_YEAR(Schema.SObjectField sobjectField) {
        return buildQueryDate('FISCAL_YEAR', sobjectField);
    }

    public static QueryDate HOUR_IN_DAY(Schema.SObjectField sobjectField) {
        return buildQueryDate('HOUR_IN_DAY', sobjectField);
    }

    public static QueryDate WEEK_IN_MONTH(Schema.SObjectField sobjectField) {
        return buildQueryDate('WEEK_IN_MONTH', sobjectField);
    }

    public static QueryDate WEEK_IN_YEAR(Schema.SObjectField sobjectField) {
        return buildQueryDate('WEEK_IN_YEAR', sobjectField);
    }

    private static QueryDate buildQueryDate(String dateOperation, Schema.SObjectField sobjectField) {
        String value = dateOperation + '(' + sobjectField.getDescribe().getName() + ')';
        return new QueryDate().setValue(sobjectField, value);
    }

}