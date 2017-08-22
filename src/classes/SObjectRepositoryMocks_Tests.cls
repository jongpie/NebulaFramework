/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class SObjectRepositoryMocks_Tests {

    @isTest
    static void it_should_fake_returning_by_id() {
        Id testId = getTestId();

        SObject returnedObj = new SObjectRepositoryMocks.Base(null).getById(testId);

        System.assert(returnedObj.Id == testId);
    }

    @isTest
    static void it_should_fake_returning_by_field_and_value() {
        Id testId = getTestId();
        QueryField field = getField();

        List<IQueryFilter> queryFilters = new List<IQueryFilter>{NebulaFactory.getQueryFilter().filterByField(field, QueryOperator.EQUALS, getFieldValue())};
        SObject returnedObj = new SObjectRepositoryMocks.Base(null).getByIdAndQueryFilters(new Set<Id>{testId}, queryFilters)[0];

        System.assertEquals(getFieldValue(), returnedObj.get(String.valueOf(field)));
    }

    @isTest
    static void it_should_return_list_of_sobjects_when_mocking_sosl_search() {
        System.assert(new SObjectRepositoryMocks.Base().getSearchResults(getFieldValue(), QuerySearchGroup.ALL_FIELDS) instanceof List<SObject>);
    }

    @isTest
    static void it_should_return_list_of_sobjects_when_mocking_sosl_search_with_passed_objects() {
        Contact con = new Contact();
        ISObjectRepository base = new SObjectRepositoryMocks.Base().with(new List<SObject>{con});

        System.assert(base.getSearchResults(getFieldValue(),QuerySearchGroup.ALL_FIELDS) instanceof List<SObject>);
    }

    static QueryField getField() {
        return new QueryField(Schema.Lead.LeadSource);
    }

    static String getFieldValue() {
        return 'Web';
    }

    static Id getTestId() {
        return TestingUtils.generateId(Schema.Lead.SObjectType);
    }

}