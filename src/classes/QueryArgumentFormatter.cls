/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public virtual class QueryArgumentFormatter extends NebulaCore implements IQueryArgumentFormatter {

    private Object argumentValue;

    public QueryArgumentFormatter(Object argumentValue) {
        this.currentModule = NebulaCore.Module.REPOSITORY;

        this.argumentValue = argumentValue;
    }

    public virtual String getValue() {
        return this.objectToQueryString(this.argumentValue);
    }

    protected virtual String objectToQueryString(Object valueToFormat) {
        if(valueToFormat == null) return null;
        else if(valueToFormat instanceof List<Object>) return this.listToQueryString((List<Object>)valueToFormat);
        else if(valueToFormat instanceof QueryDateLiteral) {
            QueryDateLiteral dateLiteral = (QueryDateLiteral)valueToFormat;
            return dateLiteral.getValue();
        }
        else if(valueToFormat instanceof Boolean) return String.valueOf((Boolean)valueToFormat);
        else if(valueToFormat instanceof Date) return String.valueOf((Date)valueToFormat);
        else if(valueToFormat instanceof Datetime) {
            Datetime datetimeValue = (Datetime)valueToFormat;
            return datetimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'Greenwich Mean Time');
        }
        else if(valueToFormat instanceof Decimal) return String.valueOf((Decimal)valueToFormat);
        else if(valueToFormat instanceof Double) return String.valueOf((Double)valueToFormat);
        else if(valueToFormat instanceof Integer) return String.valueOf((Integer)valueToFormat);
        else if(valueToFormat instanceof Long) return String.valueOf((Long)valueToFormat);
        else if(valueToFormat instanceof SObject) {
            SObject record = (SObject)valueToFormat;
            return wrapInSingleQuotes(record.Id);
        }
        else if(valueToFormat instanceof Schema.SObjectType) {
            Schema.SObjectType sobjectType = (Schema.SObjectType)valueToFormat;
            return wrapInSingleQuotes(sobjectType.getDescribe().getName());
        }
        else if(valueToFormat instanceof String) return wrapInSingleQuotes((String)valueToFormat);
        else return String.valueOf(valueToFormat);
    }

    protected virtual String listToQueryString(List<Object> valueList) {
        List<String> parsedValueList = new List<String>();
        for(Object value : valueList) parsedValueList.add(this.objectToQueryString(value));
        return '(' + String.join(parsedValueList, ',') + ')';
    }

    protected virtual String wrapInSingleQuotes(String input) {
        if(input.left(1) != '\'') input = '\'' + input;
        if(input.right(1) != '\'') input = input + '\'';
        return input;
    }

}