/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Utils
*
* @description A utility class to help with dealing with collections (lists, sets & maps)
*
*/
public without sharing class CollectionUtils {

    /**
   * @description Returns the last item in a list
   * @param listOfItems the list to check
   * @return The last Object in the provided list
   * @example
   * List<String> myList = new List<String>{'A', B', 'C'};
   * String lastItem = CollectionUtils.getLastItem(myList);
   * System.assertEquals('C', lastItem);
   */
    public static Object getLastItem(List<Object> listOfItems) {
        Integer indexOfItem = listOfItems.size() - 1;
        return listOfItems[indexOfItem];
    }

    /**
   * @description Removes the last item in the provided list & returns the item
   * @param listOfItems the list to check
   * @return The last Object in the provided list
   * @example
   * List<String> myList = new List<String>{'A', B', 'C'};
   * System.assertEquals(3, myList.size());
   * String lastItem = CollectionUtils.getLastItem(myList);
   * System.assertEquals('C', lastItem);
   * System.assertEquals(2, myList.size());
   */
    public static Object pop(List<Object> listToSplice) {
        return splice(listToSplice, listToSplice.size() - 1);
    }

    /**
   * @description Removes the item in the specified index from the provided list & returns the item
   * @param listOfItems The list to check
   * @param indexOfItem The index of the item to remove
   * @return The Object at the specified index
   * @example
   * List<String> myList = new List<String>{'A', B', 'C'};
   * System.assertEquals(3, myList.size());
   * String itemToRemove = CollectionUtils.splice(myList, 1);
   * System.assertEquals('B', itemToRemove);
   * System.assertEquals(2, myList.size());
   */
    public static Object splice(List<Object> listToSplice, Integer indexOfItem) {
        Object itemToRemove = listToSplice[indexOfItem];
        listToSplice.remove(indexOfItem);
        return itemToRemove;
    }

    /**
   * @description Determines if the provided input is a type of collection (list, set or map)
   * @param input The Object to check
   * @return true if the item is a type of collection, otherwise returns false
   * @example
   * List<String> myList = new List<String>{'A', 'B', 'C'};
   * System.assert(CollectionUtils.isCollection(myList));
   */
    public static Boolean isCollection(Object input) {
        return isList(input) || isSet(input) || isMap(input);
    }

    public static Boolean isList(Object input) {
        // If we can cast the object to a list of objects, then it's a list
        try {
           Object convertedInput = (List<Object>)input;
           return true;
        } catch(System.TypeException ex) {
            return false;
        }
    }

    public static Boolean isSet(Object input) {
        // We can't cast the object to a set of objects
        // But if we try to cast it to a list of objects & it's a set,
        // then a TypeException is thrown so we know it's a set
        try {
           Object convertedInput = (List<Object>)input;
           return false;
        } catch(System.TypeException ex) {
            return ex.getMessage().contains('Set<');
        }
    }

    public static Boolean isMap(Object input) {
        // We can't cast the object to a map of objects
        // But if we try to cast it to a list of objects & it's a map,
        // then a TypeException is thrown so we know it's a map
        try {
           Object convertedInput = (List<Object>)input;
           return false;
        } catch(System.TypeException ex) {
            return ex.getMessage().contains('Map<');
        }
    }

}