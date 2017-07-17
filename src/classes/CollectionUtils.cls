/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public without sharing class CollectionUtils {

    public static Boolean isCollection(Object input) {
        return isList(input) || isSet(input) || isMap(input);
    }

    public static Boolean isList(Object input) {
        try {
           Object convertedInput = (List<Object>)input;
           return true;
        } catch(System.TypeException ex) {
            return false;
        }
    }

    public static Boolean isSet(Object input) {
        try {
           Object convertedInput = (List<Object>)input;
           return false;
        } catch(System.TypeException ex) {
            return ex.getMessage().contains('Set<');
        }
    }

    public static Boolean isMap(Object input) {
        try {
           Object convertedInput = (List<Object>)input;
           return false;
        } catch(System.TypeException ex) {
            return ex.getMessage().contains('Map<');
        }
    }

}