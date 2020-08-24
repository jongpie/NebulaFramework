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
    IQueryFilter filterByField(QueryField queryField, QueryOperator operator, Object providedValue);
    IQueryFilter filterByQueryDate(QueryDate queryDateToFilter, QueryOperator operator, Integer providedValue);
    IQueryFilter filterBySubquery(QueryOperator inOrNotIn, Schema.SObjectField lookupFieldOnRelatedSObject);
    IQueryFilter filterBySubquery(Schema.SObjectField lookupField, QueryOperator inOrNotIn, Schema.SObjectField lookupFieldOnRelatedSObject);

    IQueryFilter andFilterBy(List<IQueryFilter> queryFilters);
    IQueryFilter orFilterBy(List<IQueryFilter> queryFilters);

    // Getter methods
    String getValue();

}