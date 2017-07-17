/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
private class CollectionUtils_Tests {

    @isTest
    static void it_should_say_that_a_list_is_a_list_and_a_collection() {
        List<Integer> collectionToCheck = new List<Integer>{1, 2, 3};

        System.assertEquals(true, CollectionUtils.isCollection(collectionToCheck));
        System.assertEquals(true, CollectionUtils.isList(collectionToCheck));

        System.assertEquals(false, CollectionUtils.isSet(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isMap(collectionToCheck));
    }

    @isTest
    static void it_should_say_that_a_set_is_a_set_and_a_collection() {
        Set<String> collectionToCheck = new Set<String>{'A', 'B', 'C'};

        System.assertEquals(true, CollectionUtils.isCollection(collectionToCheck));
        System.assertEquals(true, CollectionUtils.isSet(collectionToCheck));

        System.assertEquals(false, CollectionUtils.isList(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isMap(collectionToCheck));
    }

    @isTest
    static void it_should_say_that_a_map_is_a_map_and_a_collection() {
        Map<Id, User> collectionToCheck = new Map<Id, User>([SELECT Id FROM User]);

        System.assertEquals(true, CollectionUtils.isCollection(collectionToCheck));
        System.assertEquals(true, CollectionUtils.isMap(collectionToCheck));

        System.assertEquals(false, CollectionUtils.isList(collectionToCheck));
        System.assertEquals(false, CollectionUtils.isSet(collectionToCheck));
    }

    @isTest
    static void it_should_say_that_a_string_is_not_collection() {
        String valueToCheck = 'test string';

        System.assertEquals(false, CollectionUtils.isCollection(valueToCheck));
        System.assertEquals(false, CollectionUtils.isList(valueToCheck));
        System.assertEquals(false, CollectionUtils.isSet(valueToCheck));
        System.assertEquals(false, CollectionUtils.isMap(valueToCheck));
    }

}