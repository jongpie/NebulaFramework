/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public class TestingUtils {
    public static List<SObject> insertedRecords = new List<SObject>();
    public static List<SObject> upsertedRecords = new List<SObject>();
    public static List<SObject> updatedRecords  = new List<SObject>();
    public static List<SObject> deletedRecords  = new List<SObject>();
    public static List<SObject> undeletedRecords= new List<Sobject>();
    private static Integer startingNumber = 1;

    static {
        if(!Test.isRunningTest()) throw new Exceptions.InvalidOperationException('TestingUtils can only be called during tests!');
    }

    public static String generateId(Schema.SObjectType sObjectType) {
        String result = String.valueOf(startingNumber++);
        return sObjectType.getDescribe().getKeyPrefix() + '0'.repeat(12-result.length()) + result;
   }

    public static void generateIds(List<SObject> records) {
        for(SObject record : records) {
            if(record.Id != null) continue;
            record.Id = generateId(record.getSObjectType());
        }
    }

    public static SObject setReadOnlyField(SObject sobj, SObjectField fieldName, String value) {
        return setReadOnlyField(sobj,new Map<SObjectField,String>{fieldName => value});
    }

    public static SObject setReadOnlyField(SObject sobj, Map<SObjectField,String> changesToFields) {
        String serializedRecord = JSON.serialize(sobj);
        serializedRecord = serializedRecord.removeEnd('}');
        for(SObjectField fieldName: changesToFields.keySet()) {
            serializedRecord += ',"'
                + fieldName + '":"'
                + changesToFields.get(fieldName)
                +'"';
        }

        serializedRecord+= + '}';

        return (SObject)JSON.deserialize(serializedRecord, SObject.class);
    }
}