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

    private String queryFilterString;

    public IQueryFilter setValue(Schema.SObjectField fieldToFilter, QueryOperator operator, Object providedValue) {
        return this.setValue(new List<Schema.SObjectField>{fieldToFilter}, operator, providedValue);
    }

    public IQueryFilter setValue(List<Schema.SObjectField> fieldToFilterChain, QueryOperator operator, Object providedValue) {
        this.queryFilterString = this.parseSObjectFieldName(fieldToFilterChain)
            + ' ' + operator.getValue()
            + ' ' + NebulaFactory.getQueryArgumentFormatter().getValue(providedValue);

        return this;
    }

    public IQueryFilter setValue(QueryDate queryDateToFilter, QueryOperator operator, Object providedValue) {
        this.queryFilterString = queryDateToFilter.getValue()
            + ' ' + operator.getValue()
            + ' ' + NebulaFactory.getQueryArgumentFormatter().getValue(providedValue);

        return this;
    }

    public String getValue() {
        return this.queryFilterString;
    }

    private String parseSObjectFieldName(List<Schema.SObjectField> fieldToFilterChain) {
        Schema.SObjectField lastField = (Schema.SObjectField)CollectionUtils.pop(fieldToFilterChain);

        List<String> fieldChain = new List<String>();
        for(Schema.SObjectField parentField : fieldToFilterChain) {
            fieldChain.add(parentField.getDescribe().getRelationshipName());
        }

        String parsedFieldChain = '';
        if(!fieldChain.isEmpty()) {
            // If there is a chain of fields, build a string with the dot notation needed for SOQL/SOSL
            parsedFieldChain = String.join(fieldChain, '.') + '.';
        }

        // Return the fully qualified field name
        return parsedFieldChain + lastField.getDescribe().getName();
    }

}