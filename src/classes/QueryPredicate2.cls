/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

public class QueryPredicate2 {

    public List<Schema.SObjectField> ParentRelationshipFields {get; private set;}
    public Schema.SObjectField SObjectField {get; private set;}
    public Schema.SObjectType SObjectType {get; private set;}
    public QueryOperator Operator {get; private set;}
    public Object Value {get; private set;}
    public String QueryFieldName {get; private set;}

    private String queryFilter;

    public QueryPredicate2(Schema.SObjectField sobjectField, QueryOperator operator, Object value) {
        this(new List<Schema.SObjectField>(), sobjectField, operator, value);
    }

    public QueryPredicate2(Schema.SObjectField parentRelationshipField, Schema.SObjectField sobjectField, QueryOperator operator, Object value) {
        this(new List<Schema.SObjectField>{parentRelationshipField}, sobjectField, operator, value);
    }

    public QueryPredicate2(List<Schema.SObjectField> parentRelationshipFields, Schema.SObjectField sobjectField, QueryOperator operator, Object value) {
        this.parentRelationshipFields = parentRelationshipFields;
        this.sobjectField             = sobjectField;
        this.sobjectType              = new SObjectFieldDescriber(sobjectField).sobjectType;
        this.operator                 = operator;
        this.value                    = value;

        this.setQueryFieldName();
        this.setQueryFilter();
    }

    public String getQueryFilter() {
        return this.queryFilter;
    }

    private void setQueryFieldName() {
        SObjectTypeDescriber sobjectTypeDescriber = new SObjectTypeDescriber(this.sobjectType);

        this.queryFieldName = '';
        SObjectType currentSObjectType = this.SObjectType;
        for(Schema.SObjectField parentRelationshipField : this.parentRelationshipFields) {
// TODO figure out how to leverage SObjectFieldDescriber
// Validate that the SObjectField provided actually exists
SObjectTypeDescriber parentSObjectTypeDescriber = new SObjectTypeDescriber(this.sobjectType);
//System.assert(sobjectTypeDescriber.validateSObjectFieldExists(parentRelationshipField));
 new SObjectTypeDescriber(this.sobjectType).validateSObjectFieldExists(this.sobjectField);
            this.queryFieldName += parentRelationshipField.getDescribe().getRelationshipName() + '.';
            currentSObjectType = new SObjectFieldDescriber(parentRelationshipField).sobjectType;
        }
        this.queryFieldName += this.sobjectField;
    }

    private void setQueryFilter() {
        this.queryFilter = this.queryFieldName + ' ' + this.operator.getValue() + ' ' + this.objectToQueryString(this.value);
    }

    private String objectToQueryString(Object valueToFormat) {
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
        else if(valueToFormat instanceof String) return wrapInSingleQuotes((String)valueToFormat);
        else return String.valueOf(valueToFormat);
    }

    private String listToQueryString(List<Object> valueList) {
        List<String> parsedValueList = new List<String>();
        for(Object value : valueList) parsedValueList.add(this.objectToQueryString(value));
        return '(' + String.join(parsedValueList, ',') + ')';
    }

    private String wrapInSingleQuotes(String input) {
        if(input.left(1) != '\'') input = '\'' + input;
        if(input.right(1) != '\'') input = input + '\'';
        return input;
    }

}