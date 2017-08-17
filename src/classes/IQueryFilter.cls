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
public interface IQueryFilter {

    // Setter methods
    IQueryFilter setValue(Schema.SObjectField fieldToFilter, QueryOperator operator, Object providedValue);
    IQueryFilter setValue(List<Schema.SObjectField> fieldToFilterChain, QueryOperator operator, Object providedValue);
    IQueryFilter setValue(QueryDate queryDateToFilter, QueryOperator operator, Integer providedValue);
    IQueryFilter setValue(QueryOperator inOrNotIn, Schema.SObjectField lookupFieldOnRelatedSObject);
    IQueryFilter setValue(QueryOperator inOrNotIn, Schema.SObjectField lookupField, Schema.SObjectField lookupFieldOnRelatedSObject);

    // Getter methods
    String getValue();

}