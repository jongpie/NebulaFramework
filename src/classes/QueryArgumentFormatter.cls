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
public virtual class QueryArgumentFormatter extends NebulaCore implements IQueryArgumentFormatter {

    private String value;

    public QueryArgumentFormatter(Object valueToFormat) {
        this.currentModule = NebulaCore.Module.QUERY_BUILDER;
        this.value = this.objectToQueryString(valueToFormat);
    }

    public virtual String getValue() {
        return this.value;
    }

    protected virtual String objectToQueryString(Object valueToFormat) {
        if(valueToFormat == null) return null;
        else if(CollectionUtils.isList(valueToFormat)) return this.listToQueryString((List<Object>)valueToFormat);
        else if(CollectionUtils.isSet(valueToFormat)) return this.setToQueryString(valueToFormat);
        else if(CollectionUtils.isMap(valueToFormat)) return this.mapToQueryString(valueToFormat);
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
        else if(valueToFormat instanceof String) {
            // Escape single quotes to prevent SOQL/SOSL injection
            String stringArgument = String.escapeSingleQuotes((String)valueToFormat);
            return wrapInSingleQuotes(stringArgument);
        }
        else return String.valueOf(valueToFormat);
    }

    private String listToQueryString(List<Object> valueList) {
        List<String> parsedValueList = new List<String>();
        for(Object value : valueList) parsedValueList.add(this.objectToQueryString(value));
        return '(' + String.join(parsedValueList, ', ') + ')';
    }

    private String setToQueryString(Object valueSet) {
        String unformattedString = String.valueOf(valueSet).replace('{', '').replace('}', '');
        List<String> parsedValueList = new List<String>();
        for(String collectionItem : unformattedString.split(',')) {
            parsedValueList.add(this.objectToQueryString(collectionItem));
        }

        return '(' + String.join(parsedValueList, ', ') + ')';
    }

    private String mapToQueryString(Object valueMap) {
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(valueMap));

        return this.setToQueryString(m.keySet());
    }

    private String wrapInSingleQuotes(String input) {
        input = input.trim();

        if(input.left(1) != '\'') input = '\'' + input;
        if(input.right(1) != '\'') input = input + '\'';
        return input;
    }

}