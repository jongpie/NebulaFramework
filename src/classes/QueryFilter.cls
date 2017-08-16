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
public class QueryFilter implements IQueryFilter {

    private QueryDate queryDate;
    private List<Schema.SObjectField> fieldToFilterChain;
    private Schema.SObjectField sobjectField;
    private Schema.SObjectType sobjectType;
    private QueryOperator operator;
    private Object providedValue;
    @testVisible private String queryFieldName;

    public QueryFilter() {
        this.queryFieldName     = '';
        this.fieldToFilterChain = new List<Schema.SObjectField>();
    }

    public IQueryFilter setValue(QueryDate queryDateToFilter, QueryOperator operator, Object providedValue) {
        // TODO finish implementing for QueryDate or remove
        this.sobjectType        = queryDateToFilter.getSObjectType();
        this.operator           = operator;
        this.providedValue      = providedValue;

        this.getQueryDateFieldName();

        return this;
    }

    public IQueryFilter setValue(Schema.SObjectField fieldToFilter, QueryOperator operator, Object providedValue) {
        return this.setValue(new List<Schema.SObjectField>{fieldToFilter}, operator, providedValue);
    }

    public IQueryFilter setValue(List<Schema.SObjectField> fieldToFilterChain, QueryOperator operator, Object providedValue) {
        this.fieldToFilterChain = fieldToFilterChain;
        this.sobjectType        = new SObjectFieldDescriber(fieldToFilterChain[0]).SObjectType;
        this.operator           = operator;
        this.providedValue      = providedValue;

        this.setSObjectFieldName();

        return this;
    }

    public String getValue() {
        IQueryArgumentFormatter argumentFormatter = NebulaFactory.getQueryArgumentFormatter();
        return this.queryFieldName + ' ' + this.operator.getValue() + ' ' + argumentFormatter.getValue(this.providedValue);
    }

    public Schema.SObjectField getSObjectField() { // TODO eliminate method??
        return this.sobjectField;
    }

    public QueryOperator getQueryOperator() {
        return this.operator;
    }

    public Object getProvidedValue() {
        return this.providedValue;
    }

    private void getQueryDateFieldName() {
        if(this.queryDate == null) return;

        this.queryFieldName = this.queryDate.getValue();
    }

    private void setSObjectFieldName() {
        if(this.fieldToFilterChain == null) return;

        Schema.SObjectField lastField = (Schema.SObjectField)CollectionUtils.pop(this.fieldToFilterChain);

        List<String> fieldChain = new List<String>();
        for(Schema.SObjectField parentField : this.fieldToFilterChain) {
            fieldChain.add(parentField.getDescribe().getRelationshipName());
        }

        String parsedFieldChain = '';
        if(fieldChain.isEmpty()) {
            // If there are no fields in the chain, then the last field is a field on the current sobject
            this.sobjectField = lastField;
        } else {
            // If there is a chain of fields, build a string with the dot notation needed for SOQL/SOSL
            parsedFieldChain = String.join(fieldChain, '.') + '.';
        }

        // Set the fully qualified field name
        this.queryFieldName = parsedFieldChain + lastField.getDescribe().getName();
    }

}