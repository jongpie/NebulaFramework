/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class CollectionUtils_Tests {

    @isTest
    static void it_should_get_the_last_item_in_a_list() {
        List<String> collectionToCheck = new List<String>{'A', 'B', 'C'};
        Integer originalCollectionSize = collectionToCheck.size();

        System.assertEquals('C', CollectionUtils.getLastItem(collectionToCheck));
        System.assertEquals(originalCollectionSize, collectionToCheck.size());
    }

    @isTest
    static void it_should_pop_the_last_item_in_a_list() {
        List<String> collectionToCheck = new List<String>{'A', 'B', 'C'};
        Integer originalCollectionSize = collectionToCheck.size();

        System.assertEquals('C', CollectionUtils.pop(collectionToCheck));
        System.assertEquals(originalCollectionSize - 1, collectionToCheck.size());
        // Verify that the last item has been removed
        System.assertEquals(false, new Set<String>(collectionToCheck).contains('C'));
    }

    @isTest
    static void it_should_splice_the_specified_item_in_a_list() {
        List<String> collectionToCheck = new List<String>{'A', 'B', 'C'};
        Integer originalCollectionSize = collectionToCheck.size();

        System.assertEquals('B', CollectionUtils.splice(collectionToCheck, 1));
        System.assertEquals(originalCollectionSize - 1, collectionToCheck.size());
        // Verify that the specified item has been removed
        System.assertEquals(false, new Set<String>(collectionToCheck).contains('B'));
    }

    // Tests for lists
    @isTest
    static void it_should_say_that_a_list_of_strings_is_a_list_and_a_collection() {
        List<String> collectionToCheck = new List<String>{'A', 'B', 'C'};

        System.assertEquals(true, CollectionUtils.isCollection(collectionToCheck));
        System.assertEquals(true, CollectionUtils.isList(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isSet(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isMap(collectionToCheck));
    }

    @isTest
    static void it_should_say_that_a_list_of_integers_is_a_list_and_a_collection() {
        List<Integer> collectionToCheck = new List<Integer>{1, 2, 3};

        System.assertEquals(true, CollectionUtils.isCollection(collectionToCheck));
        System.assertEquals(true, CollectionUtils.isList(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isSet(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isMap(collectionToCheck));
    }

    @isTest
    static void it_should_say_that_a_list_of_users_is_a_list_and_a_collection() {
        List<User> collectionToCheck = [SELECT Id FROM User LIMIT 10];

        System.assertEquals(true, CollectionUtils.isCollection(collectionToCheck));
        System.assertEquals(true, CollectionUtils.isList(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isSet(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isMap(collectionToCheck));
    }

    // Tests for sets
    @isTest
    static void it_should_say_that_a_set_of_strings_is_a_set_and_a_collection() {
        Set<String> collectionToCheck = new Set<String>{'A', 'B', 'C'};

        System.assertEquals(true, CollectionUtils.isCollection(collectionToCheck));
        System.assertEquals(true, CollectionUtils.isSet(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isList(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isMap(collectionToCheck));
    }

    @isTest
    static void it_should_say_that_a_set_of_integers_is_a_set_and_a_collection() {
        Set<Integer> collectionToCheck = new Set<Integer>{1, 2, 3};

        System.assertEquals(true, CollectionUtils.isCollection(collectionToCheck));
        System.assertEquals(true, CollectionUtils.isSet(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isList(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isMap(collectionToCheck));
    }

    @isTest
    static void it_should_say_that_a_set_of_users_is_a_set_and_a_collection() {
        Set<User> collectionToCheck = new Set<User>([SELECT Id FROM User LIMIT 10]);

        System.assertEquals(true, CollectionUtils.isCollection(collectionToCheck));
        System.assertEquals(true, CollectionUtils.isSet(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isList(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isMap(collectionToCheck));
    }

    // Tests for maps
    @isTest
    static void it_should_say_that_a_map_of_strings_is_a_map_and_a_collection() {
        Map<String, Integer> collectionToCheck = new Map<String, Integer>{
            'First'  => 1,
            'Second' => 2,
            'Third'  => 3
        };

        System.assertEquals(true, CollectionUtils.isCollection(collectionToCheck));
        System.assertEquals(true, CollectionUtils.isMap(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isList(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isSet(collectionToCheck));
    }

    @isTest
    static void it_should_say_that_a_map_of_integers_is_a_map_and_a_collection() {
        Map<Integer, String> collectionToCheck = new Map<Integer, String>{
             1 => 'First',
             2 => 'Second',
             3 => 'Third'
        };

        System.assertEquals(true, CollectionUtils.isCollection(collectionToCheck));
        System.assertEquals(true, CollectionUtils.isMap(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isList(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isSet(collectionToCheck));
    }

    @isTest
    static void it_should_say_that_a_map_of_users_is_a_map_and_a_collection() {
        Map<Id, User> collectionToCheck = new Map<Id, User>([SELECT Id FROM User LIMIT 10]);

        System.assertEquals(true, CollectionUtils.isCollection(collectionToCheck));
        System.assertEquals(true, CollectionUtils.isMap(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isList(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isSet(collectionToCheck));
    }

    // Negative tests
    @isTest
    static void it_should_say_that_a_string_is_not_collection() {
        String valueToCheck = 'test string';

        System.assertEquals(false, CollectionUtils.isCollection(valueToCheck));
        System.assertEquals(false, CollectionUtils.isList(valueToCheck));
        System.assertEquals(false, CollectionUtils.isSet(valueToCheck));
        System.assertEquals(false, CollectionUtils.isMap(valueToCheck));
    }

    @isTest
    static void it_should_say_that_an_integer_is_not_collection() {
        Integer valueToCheck = 1;

        System.assertEquals(false, CollectionUtils.isCollection(valueToCheck));
        System.assertEquals(false, CollectionUtils.isList(valueToCheck));
        System.assertEquals(false, CollectionUtils.isSet(valueToCheck));
        System.assertEquals(false, CollectionUtils.isMap(valueToCheck));
    }

    @isTest
    static void it_should_say_that_a_user_is_not_collection() {
        User valueToCheck = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.assertEquals(false, CollectionUtils.isCollection(valueToCheck));
        System.assertEquals(false, CollectionUtils.isList(valueToCheck));
        System.assertEquals(false, CollectionUtils.isSet(valueToCheck));
        System.assertEquals(false, CollectionUtils.isMap(valueToCheck));
    }

}