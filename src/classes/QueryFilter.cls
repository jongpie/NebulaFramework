/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public class QueryFilter implements IQueryFilter {

    private List<Schema.SObjectField> parentRelationshipFields;
    private Schema.SObjectField sobjectField;
    private Schema.SObjectType sobjectType;
    private QueryOperator operator;
    private Object providedValue;
    @testVisible private String queryFieldName;

    public QueryFilter() {
            //TODO
    }

    public QueryFilter(Schema.SObjectField fieldToFilter, QueryOperator operator, Object providedValue) {
        this(new List<Schema.SObjectField>(), fieldToFilter, operator, providedValue);
    }

    public QueryFilter(Schema.SObjectField parentRelationshipField, Schema.SObjectField fieldToFilter, QueryOperator operator, Object providedValue) {
        this(new List<Schema.SObjectField>{parentRelationshipField}, fieldToFilter, operator, providedValue);
    }

    public QueryFilter(List<Schema.SObjectField> parentRelationshipFieldChain, Schema.SObjectField fieldToFilter, QueryOperator operator, Object providedValue) {
        this.parentRelationshipFields = parentRelationshipFieldChain;
        this.sobjectField             = fieldToFilter;
        this.sobjectType              = new SObjectFieldDescriber(fieldToFilter).SObjectType;
        this.operator                 = operator;
        this.providedValue            = providedValue;

        this.setQueryFieldName();
    }

    public IQueryFilter initialize(Schema.SObjectField fieldToFilter, QueryOperator operator, Object providedValue) {
        this.sobjectField             = fieldToFilter;
        this.sobjectType              = new SObjectFieldDescriber(fieldToFilter).SObjectType;
        this.operator                 = operator;
        this.providedValue            = providedValue;

        this.setQueryFieldName();

        return this;
    }

    public String getValue() {
        // TODO cleanup
        //return this.queryFieldName + ' ' + this.operator.getValue() + ' ' + new QueryArgumentFormatter(this.providedValue).getValue();
        //IQueryArgumentFormatter argumentFormatter = (IQueryArgumentFormatter)NebulaImplementation1.QUERY_ARGUMENT_FORMATTER_IMPLEMENTATION.newInstance();
        IQueryArgumentFormatter argumentFormatter = NebulaFactory.getQueryArgumentFormatter();
        return this.queryFieldName + ' ' + this.operator.getValue() + ' ' + argumentFormatter.getValue(this.providedValue);
    }

    private void setQueryFieldName() {
        this.queryFieldName = '';
        SObjectType currentSObjectType = this.SObjectType;
        for(Schema.SObjectField parentRelationshipField : this.parentRelationshipFields) {
            this.queryFieldName += parentRelationshipField.getDescribe().getRelationshipName() + '.';
            currentSObjectType = new SObjectFieldDescriber(parentRelationshipField).SObjectType;
        }
        this.queryFieldName += this.sobjectField;
    }

}