@isTest
private class UUID_Tests {

    @isTest
    static void it_should_consider_all_zeroes_string_to_be_empty() {
        System.assert(UUID.isEmpty('00000000-0000-0000-0000-000000000000'));
    }

    @isTest
    static void it_should_create_a_new_UUID() {
        String generatedUUID = new UUID().getValue();
        System.assertEquals(36, generatedUUID.length());
    }

    @isTest
    static void it_should_verify_that_a_UUID_is_a_UUID() {
        String generatedUUID = new UUID().getValue();
        System.assert(UUID.isValid(generatedUUID));
    }

    @isTest
    static void it_should_consider_null_string_an_empty_UUID() {
        System.assert(UUID.isEmpty(null));
    }

    @isTest
    static void it_should_not_consider_an_empty_string_a_UUID() {
        System.assertEquals(false, UUID.isValid(''));
    }

    @isTest
    static void it_should_not_consider_null_a_UUID() {
        System.assertEquals(false, UUID.isValid(null));
    }

    @isTest
    static void it_should_validate_a_UUID_in_upper_case() {
        String exampleUUID = 'f3665813-1a60-4924-ad9b-23a9cef17d80'.toUpperCase();
        System.assertEquals(true, UUID.isValid(exampleUUID));
    }

    @isTest
    static void it_should_validate_a_UUID_in_lower_case() {
        String exampleUUID = 'f3665813-1a60-4924-ad9b-23a9cef17d80'.toLowerCase();
        System.assertEquals(true, UUID.isValid(exampleUUID));
    }

}