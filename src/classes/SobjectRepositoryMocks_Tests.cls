/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class SobjectRepositoryMocks_Tests {

    @isTest
    static void it_should_fake_returning_by_id() {
        Id testId = getTestId();

        Sobject returnedRecord = new SobjectRepositoryMocks.Base(null).get(testId);

        System.assert(returnedRecord.Id == testId);
    }

    @isTest
    static void it_should_fake_returning_by_field_and_value() {
        Id testId = getTestId();
        Soql.QueryField field = getField();

        List<Soql.QueryFilter> queryFilters = new List<Soql.QueryFilter>{new Soql.QueryFilter(field, '=', getFieldValue())};
        Sobject returnedRecord = new SobjectRepositoryMocks.Base(null).get(new Set<Id>{testId}, queryFilters)[0];

        System.assertEquals(getFieldValue(), returnedRecord.get(String.valueOf(field)));
    }

    @isTest
    static void it_should_return_list_of_sobjects_when_mocking_sosl_search() {
        System.assert(new SobjectRepositoryMocks.Base().search(getFieldValue(), Sosl.SearchGroup.ALL_FIELDS) instanceOf List<Sobject>);
    }

    @isTest
    static void it_should_return_list_of_sobjects_when_mocking_sosl_search_with_passed_objects() {
        Contact contact = new Contact();
        new TestDataFactory(contact).populateRequiredFields();
        ISobjectRepository base = new SobjectRepositoryMocks.Base().with(new List<Sobject>{contact});

        System.assert(base.search(getFieldValue(), Sosl.SearchGroup.ALL_FIELDS) instanceOf List<Sobject>);
    }

    static Soql.QueryField getField() {
        return new Soql.QueryField(Schema.Lead.LeadSource);
    }

    static String getFieldValue() {
        return 'Web';
    }

    static Id getTestId() {
        return TestingUtils.generateId(Schema.Lead.SobjectType);
    }

}