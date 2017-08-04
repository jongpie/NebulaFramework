/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Utils
*
* @description TODO
*/
@isTest
public class TestingUtils {

    public static List<SObject> insertedRecords  = new List<SObject>();
    public static List<SObject> upsertedRecords  = new List<SObject>();
    public static List<SObject> updatedRecords   = new List<SObject>();
    public static List<SObject> deletedRecords   = new List<SObject>();
    public static List<SObject> undeletedRecords = new List<SObject>();

    private static Integer startingNumber = 1;

    public static String generateId(Schema.SObjectType sobjectType) {
        String result = String.valueOf(startingNumber++);
        return sobjectType.getDescribe().getKeyPrefix() + '0'.repeat(12-result.length()) + result;
   }

    public static void generateIds(List<SObject> records) {
        for(SObject record : records) record.Id = record.Id != null ? record.Id : generateId(record.getSObjectType());
    }

    public static SObject setReadOnlyField(SObject sobj, Schema.SObjectField fieldName, Object value) {
        return setReadOnlyField(sobj, new Map<Schema.SObjectField, Object>{fieldName => value});
    }

    public static SObject setReadOnlyField(SObject sobj, Map<Schema.SObjectField, Object> changesToFields) {
        String serializedRecord = JSON.serialize(sobj);
        Map<String, Object> deserializedRecordMap = (Map<String, Object>)JSON.deserializeUntyped(serializedRecord);

        // Loop through the deserialized record map and put the field & value
        // Since it's a map, if the field already exists on the SObject, it's updated (or added if it wasn't there already)
        for(Schema.SObjectField sobjectField : changesToFields.keySet()) {
            String fieldName = sobjectField.getDescribe().getName();
            deserializedRecordMap.put(fieldName, changesToFields.get(sobjectField));
        }

        serializedRecord = JSON.serialize(deserializedRecordMap);
        return (SObject)JSON.deserialize(serializedRecord, SObject.class);
    }

}