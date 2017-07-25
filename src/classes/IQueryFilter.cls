/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface IQueryFilter {

    // Setter methods
    IQueryFilter setValue(Schema.SObjectField fieldToFilter, QueryOperator operator, Object providedValue);
    IQueryFilter setValue(List<Schema.SObjectField> fieldToFilterChain, QueryOperator operator, Object providedValue);

    // Getter methods
    String getValue();
    Schema.SObjectField getSObjectField();
    QueryOperator getQueryOperator();
    Object getProvidedValue();

}