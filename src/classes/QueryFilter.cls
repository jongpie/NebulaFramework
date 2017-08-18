/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Query Builder
*
* @description Handles generating any query conditions (the WHERE statement in a query)
* Each part of a WHERE statement is a separate instance of query filter.
*
*/
public class QueryFilter implements IQueryFilter {

    private String queryFilterString;

    /**
    * @description Creates a filter for a field on the current sobject
    * @param fieldToFilter Field on the current sobject that you want to filter list to check
    * @param operator The instance of QueryOperator to use in the filter the list to check
    * @param providedValue The value to compare to in the filter
    * @return The instance of IQueryFilter, to allow chaining methods
    * @example
    * QueryFilter filter = new QueryFilter().setValue(Schema.User.Email, QueryOperator.NOT_EQUAL_TO, null);
    * System.assertEquals('Email != null', filter.getValue());
    */
    public IQueryFilter filterByField(Schema.SObjectField fieldToFilter, QueryOperator operator, Object providedValue) {
        return this.filterByParentField(new List<Schema.SObjectField>{fieldToFilter}, operator, providedValue);
    }

    /**
    * @description Creates a filter for a field on a parent sobject
    * @param fieldToFilterChain An ordered list of fields that chain together to build the parent field
    * @param operator The instance of QueryOperator to use in the filter the list to check
    * @param providedValue The value to compare to in the filter
    * @return The instance of IQueryFilter, to allow chaining methods
    * @example
    * List<Schema.SObjectField> parentFieldChain = new List<Schema.SObjectField>{Schema.Lead.CreatedById, Schema.User.Email};
    * QueryFilter filter = new QueryFilter().setValue(parentFieldChain, QueryOperator.NOT_EQUAL_TO, null);
    * System.assertEquals('CreatedBy.Email != null', filter.getValue());
    */
    public IQueryFilter filterByParentField(List<Schema.SObjectField> fieldToFilterChain, QueryOperator operator, Object providedValue) {
        this.queryFilterString = this.parseSObjectFieldName(fieldToFilterChain)
            + ' ' + operator.getValue()
            + ' ' + NebulaFactory.getQueryArgumentFormatter().getValue(providedValue);

        return this;
    }

    /**
    * @description Creates a filter for a date function
    * @param queryDateToFilter An instance of QueryDate, created by supplying a date or datetime field to filter on
    * @param operator The instance of QueryOperator to use in the filter the list to check
    * @param providedValue The value to compare to in the filter
    * @return The instance of IQueryFilter, to allow chaining methods
    * @example
    * QueryDate qd = QueryDate.CALENDAR_MONTH(Schema.Lead.CreatedDate);
    * QueryFilter filter = new QueryFilter().setValue(qd, QueryOperator.EQUALS, 2);
    * System.assertEquals('CALENDAR_MONTH(CreatedDate) = 2', filter.getValue());
    */
    public IQueryFilter filterByQueryDate(QueryDate queryDateToFilter, QueryOperator operator, Integer providedValue) {
        this.queryFilterString = queryDateToFilter.getValue()
            + ' ' + operator.getValue()
            + ' ' + providedValue;

        return this;
    }

    /**
    * @description Creates a filter for a subquery on the sobject's ID
    * @param inOrNotIn An instance of QueryOperator - it must be QueryOperator.IS_IN or QueryOperator.IS_NOT_IN
    * @param lookupFieldOnRelatedSObject The lookup field on a related object that contains the ID of the current sobject
    * @return The instance of IQueryFilter, to allow chaining methods
    * @example
    * QueryFilter filter = new QueryFilter().setValue(QueryOperator.IS_IN, Schema.Lead.ConvertedAccountId);
    * System.assertEquals('Id IN (SELECT ConvertedAccountId FROM Lead)', filter.getValue());
    */
   // TODO figure out a better solution for inOrNotIn
    public IQueryFilter filterBySubquery(QueryOperator inOrNotIn, Schema.SObjectField lookupFieldOnRelatedSObject) {
        return this.setValueForSubquery('Id', inOrNotIn, lookupFieldOnRelatedSObject);
    }

    /**
    * @description Creates a filter for a subquery on an ID field for the current sobject
    * @param lookupField The lookup field on the current sobject that contains an ID
    * @param inOrNotIn An instance of QueryOperator - it must be QueryOperator.IS_IN or QueryOperator.IS_NOT_IN
    * @param lookupFieldOnRelatedSObject The lookup field on a related object that contains the value of the lookupField paraemter
    * @return The instance of IQueryFilter, to allow chaining methods
    * @example
    * QueryFilter filter = new QueryFilter().setValue(Schema.Lead.OwnerId, QueryOperator.IS_IN, Schema.User.Id);
    * System.assertEquals('OwnerId IN (SELECT Id FROM User)', filter.getValue());
    */
    public IQueryFilter filterBySubquery(QueryOperator inOrNotIn, Schema.SObjectField lookupField, Schema.SObjectField lookupFieldOnRelatedSObject) {
        return this.setValueForSubquery(lookupField.getDescribe().getName(), inOrNotIn, lookupFieldOnRelatedSObject);
    }

    /**
    * @description Adds several filters together as a set of 'AND' filters
    * @param queryFilters The filters to group together
    * @return The instance of IQueryFilter, to allow chaining methods
    */
    public IQueryFilter andFilterBy(List<IQueryFilter> queryFilters) {
        return this.filterByWithSeparator(queryFilters, 'AND');
    }

    /**
    * @description Adds several filters together as a set of 'OR' filters
    * @param queryFilters The filters to group together
    * @return The instance of IQueryFilter, to allow chaining methods
    */
    public IQueryFilter orFilterBy(List<IQueryFilter> queryFilters) {
        return this.filterByWithSeparator(queryFilters, 'OR');
    }

    /**
    * @description Returns the calculated value, based on the method & parameters provided
    * @return The string of the query filter, ready to be used in dynamic SOQL/SOSL
    */
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

    private IQueryFilter setValueForSubquery(String idFieldName, QueryOperator inOrNotIn, Schema.SObjectField lookupFieldOnRelatedSObject) {
        String relatedSObjectTypeName = new SObjectFieldDescriber(lookupFieldOnRelatedSObject).getSObjectType().getDescribe().getName();
        String lookupFieldOnRelatedSObjectName = lookupFieldOnRelatedSObject.getDescribe().getName();

        this.queryFilterString = idFieldName + ' ' + inOrNotIn.getValue() + ' (SELECT ' + lookupFieldOnRelatedSObjectName + ' FROM ' + relatedSObjectTypeName + ')';

        return this;
    }

    private IQueryFilter filterByWithSeparator(List<IQueryFilter> queryFilters, String separator) {
        List<String> queryFilterValues = new List<String>();
        for(IQueryFilter queryFilter : queryFilters) queryFilterValues.add(queryFilter.getValue());

        this.queryFilterString = '(' + String.join(queryFilterValues, ' ' + separator + ' ') + ')';
        return this;
    }

}