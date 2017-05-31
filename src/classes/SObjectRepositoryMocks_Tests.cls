@isTest
private class SObjectRepositoryMocks_Tests {

    @isTest
    static void it_should_fake_returning_by_id() {
        Id testId = getTestId();

        Sobject returnedObj = new SObjectRepositoryMocks.Base(null).getById(testId);

        System.assert(returnedObj.Id == testId);
    }

    @isTest
    static void it_should_fake_returning_by_field_and_value() {
        Id testId = getTestId();
        SObjectField field = getField();
        String value = getFieldValue();

        SObject returnedObj = new SObjectRepositoryMocks.Base(null).getByFieldForIds(field,value, new Set<Id>{testId})[0];

        System.assert(returnedObj.get(String.valueOf(field)) == value);
    }

    @isTest
    static void it_should_return_list_of_sobjects_when_mocking_sosl_search() {
        System.assert(new SObjectRepositoryMocks.Base().getSearchResults(getFieldValue(),QuerySearchGroup.ALL_FIELDS) instanceof List<SObject>);
    }

    @isTest
    static void it_should_return_list_of_sobjects_when_mocking_sosl_search_with_passed_objects() {
        Contact con = new Contact();
        ISObjectRepository base = new SObjectRepositoryMocks.Base().with(new List<SObject>{con});

        System.assert(base.getSearchResults(getFieldValue(),QuerySearchGroup.ALL_FIELDS) instanceof List<SObject>);
    }

    static SObjectField getField() {
        return Schema.Lead.LeadSource;
    }

    static String getFieldValue() {
        return 'Web';
    }

    static Id getTestId() {
        return TestingUtils.generateId(Schema.Lead.SObjectType);
    }

}