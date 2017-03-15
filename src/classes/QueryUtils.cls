/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public without sharing class QueryUtils {

    public static String toQueryString(List<Object> valueList) {
        List<String> parsedValueList = new List<String>();
        for(Object value : valueList) parsedValueList.add(toQueryString(value));
        return '(' + String.join(parsedValueList, ',') + ')';
    }

    public static String toQueryString(Object value) {
        if(value == null) return null;
        else if(value instanceof List<Object>) return toQueryString((List<Object>)value);
        else if(value instanceof QueryDateLiteral) {
            QueryDateLiteral dateLiteral = (QueryDateLiteral)value;
            return dateLiteral.getValue();
        }
        else if(value instanceof Boolean) return String.valueOf((Boolean)value);
        else if(value instanceof Date) return String.valueOf((Date)value);
        else if(value instanceof Datetime) {
            Datetime datetimeValue = (Datetime)value;
            return datetimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'Greenwich Mean Time');
        }
        else if(value instanceof Decimal) return String.valueOf((Decimal)value);
        else if(value instanceof Double) return String.valueOf((Double)value);
        else if(value instanceof Integer) return String.valueOf((Integer)value);
        else if(value instanceof Long) return String.valueOf((Long)value);
        else if(value instanceof SObject) {
            SObject record = (SObject)value;
            return wrapInSingleQuotes(record.Id);
        }
        else if(value instanceof String) return wrapInSingleQuotes((String)value);
        else return String.valueOf(value);
    }

    public static String wrapInSingleQuotes(String input) {
        if(input.left(1) != '\'') input = '\'' + input;
        if(input.right(1) != '\'') input = input + '\'';
        return input;
    }

}