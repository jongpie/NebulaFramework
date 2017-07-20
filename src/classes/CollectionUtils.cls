/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public without sharing class CollectionUtils {

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