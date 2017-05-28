/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public class QueryFilter {

    public List<Schema.SObjectField> ParentRelationshipFields {get; private set;}
    public Schema.SObjectField SObjectField {get; private set;}
    public Schema.SObjectType SObjectType {get; private set;}
    public QueryOperator Operator {get; private set;}
    public Object Value {get; private set;}
    public String QueryFieldName {get; private set;}

    //private String queryFilter;

    public QueryFilter(Schema.SObjectField fieldToFilter, QueryOperator operator, Object value) {
        this(new List<Schema.SObjectField>(), fieldToFilter, operator, value);
    }

    public QueryFilter(Schema.SObjectField parentRelationshipField, Schema.SObjectField fieldToFilter, QueryOperator operator, Object value) {
        this(new List<Schema.SObjectField>{parentRelationshipField}, fieldToFilter, operator, value);
    }

    public QueryFilter(List<Schema.SObjectField> sortedParentRelationshipFields, Schema.SObjectField fieldToFilter, QueryOperator operator, Object value) {
        this.parentRelationshipFields = sortedParentRelationshipFields;
        this.sobjectField             = fieldToFilter;
        this.sobjectType              = new SObjectFieldDescriber(fieldToFilter).sobjectType;
        this.operator                 = operator;
        this.value                    = value;

        this.setQueryFieldName();
        //this.setQueryFilter();
    }

    public String getValue() {
        return this.queryFieldName + ' ' + this.operator.getValue() + ' ' + new QueryArgumentFormatter(this.value).getValue();
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

    /*private void setQueryFilter() {
        this.queryFilter = this.queryFieldName + ' ' + this.operator.getValue() + ' ' + this.objectToQueryString(this.value);
    }*/

}