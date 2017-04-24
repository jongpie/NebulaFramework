/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public class CollectionUtils {

    public static List<Id> convertToIdList(List<SObject> sObjectList) {
        return new List<Id>(convertToIdSet(sObjectList));
    }

    public static Set<Id> convertToIdSet(List<SObject> sObjectList) {
        return convertToMap(sObjectList).keySet();
    }

    public static Set<Id> convertToIdSet(String fieldName, List<SObject> sObjectList) {
        return convertToMap(fieldName, sObjectList).keySet();
    }

    public static Map<Id,SObject> convertToMap(List<SObject> sObjectList) {
        return new Map<Id,SObject>(sObjectList);
    }

    public static Map<Id, SObject> convertToMap(String fieldName, List<SObject> sObjectList) {
        Map<Id,SObject> mapping = new Map<Id,SObject>();
        if(sObjectList.isEmpty()) return mapping;

        /**
         * Validation to make sure fieldName is an Id or Lookup
         */
        Set<String> acceptedFieldTypes = new Set<String>{'STRING','ID','REFERENCE', 'DATACATEGORYGROUPREFERENCE'};
        String sobjectField = String.valueOf(sObjectList[0].getSObjectType()) + '.' + fieldName;
        if(!acceptedFieldTypes.contains(DescribeUtils.getFieldType(sobjectField))) throw new Exceptions.DescribeException('Field should be of type Id');

        for(SObject sObj : sObjectList) {
            if(sObj.get(fieldName) == null) continue;
            mapping.put((Id)sObj.get(fieldName), sObj);
        }

        return mapping;
    }

    public static Map<String, SObject> convertToStringMap(String fieldName, List<SObject> sObjectList) {
        Map<String,SObject> mapping = new Map<String,SObject>();
        if(sObjectList.isEmpty()) return mapping;

        /**
         * Validation to make sure fieldName is text
         */
        Set<String> acceptedFieldTypes = new Set<String>{'STRING', 'PICKLIST', 'MULTIPICKLIST', 'PHONE', 'ENCRYPTEDSTRING', 'DATE', 'DATETIME', 'URL', 'TEXTAREA', 'EMAIL', 'TIME'};

        String sobjectField = String.valueOf(sObjectList[0].getSObjectType()) + '.' + fieldName;
        if(!acceptedFieldTypes.contains(DescribeUtils.getFieldType(sobjectField))) throw new Exceptions.DescribeException('Field does not support: ' + DescribeUtils.getFieldType(sobjectField));

        for(SObject sObj : sObjectList) {
            if(sObj.get(fieldName) == null) continue;
            mapping.put((String)sObj.get(fieldName), sObj);
        }

        return mapping;
    }

    public static Boolean isNullOrEmpty(List<Object> listOfThings) {
        return listOfThings == null || listOfThings.isEmpty();
    }

    public static Boolean isNullOrEmpty(Map<String,String> mapOfThings) {
        return mapOfThings == null || mapOfThings.isEmpty();
    }

    public static SObject getFirstOrDefault(List<SObject> listOfThings) {
        return listOfThings.isEmpty() ? null : listOfThings[0];
    }

    public static void removeAll(Map<String,Object> mapping, List<String> fieldsToRemove) {
        Integer size = fieldsToRemove.size();
        for(Integer i = 0; i < size; i++) {
            mapping.remove(fieldsToRemove[i]);
        }
    }
}