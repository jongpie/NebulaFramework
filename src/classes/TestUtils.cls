/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
public class TestUtils {

    public static List<Sobject> insertedRecords  = new List<Sobject>();
    public static List<Sobject> upsertedRecords  = new List<Sobject>();
    public static List<Sobject> updatedRecords   = new List<Sobject>();
    public static List<Sobject> deletedRecords   = new List<Sobject>();
    public static List<Sobject> undeletedRecords = new List<Sobject>();

    private static Integer startingNumber = 1;

    public static String generateId(Schema.SobjectType sobjectType) {
        String result = String.valueOf(startingNumber++);
        return sobjectType.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
   }

    public static void generateIds(List<Sobject> records) {
        for(Sobject record : records) record.Id = record.Id != null ? record.Id : generateId(record.getSobjectType());
    }

    public static Integer generateRandomNumber() {
        return generateRandomNumber(6);
    }

    public static Integer generateRandomNumber(Integer n){
        return Integer.valueOf(Math.rint(Math.pow(10, n) * Math.random()));
    }

    public static Sobject setReadOnlyField(Sobject record, Schema.SobjectField fieldName, Object value) {
        return setReadOnlyField(record, new Map<Schema.SobjectField, Object>{fieldName => value});
    }

    public static Sobject setReadOnlyField(Sobject record, Map<Schema.SobjectField, Object> changesToFields) {
        String serializedRecord = Json.serialize(record);
        Map<String, Object> deserializedRecordMap = (Map<String, Object>)Json.deserializeUntyped(serializedRecord);

        // Loop through the deserialized record map and put the field & value
        // Since it's a map, if the field already exists on the Sobject, it's updated (or added if it wasn't there already)
        for(Schema.SobjectField sobjectField : changesToFields.keySet()) {
            String fieldName = sobjectField.getDescribe().getName();
            deserializedRecordMap.put(fieldName, changesToFields.get(sobjectField));
        }

        serializedRecord = Json.serialize(deserializedRecordMap);
        return (Sobject)Json.deserialize(serializedRecord, Sobject.class);
    }

}