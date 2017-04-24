public class TestingUtils {
    public class InvalidArgumentException extends Exception {}
    public static List<SObject> insertedRecords = new List<SObject>();
    public static List<SObject> upsertedRecords = new List<SObject>();
    public static List<SObject> updatedRecords  = new List<SObject>();
    public static List<SObject> deletedRecords  = new List<SObject>();
    public static List<SObject> undeletedRecords= new List<Sobject>();
    private static Integer startingNumber = 1;

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

    public static List<SObject> getInsertedByType(Schema.SObjectType sObjectType) {
        List<SObject> matchingRecords = new List<SObject>();
        for (SObject record : insertedRecords) {
            if(record.getSObjectType() ==  sObjectType) {
                matchingRecords.Add(record);
            }
        }
        return matchingRecords;
    }
    public static SObject getSingleOrDefaultInsertedByType(Schema.SObjectType sObjectType){
        List<SObject> matchingRecords = getInsertedByType(sObjectType);
        if(matchingRecords.size() > 1) {
            throw new Exceptions.InvalidOperationException();
        }
        return matchingRecords.size() == 0 ? null : matchingRecords[0];
    }

    public static SObject setReadOnlyField(SObject sobj, String fieldName, String value) {
        return setReadOnlyField(sobj,new Map<String,String>{fieldName => value});
    }

    public static SObject setReadOnlyField(SObject sobj, Map<String,String> changesToFields) {
        String serializedRecord = JSON.serialize(sobj);
        serializedRecord = serializedRecord.removeEnd('}');
        for(String stringer: changesToFields.keySet()) {
            serializedRecord += ',"' + stringer + '":"' + changesToFields.get(stringer)+'"';
        }

        serializedRecord+= + '}';

        return (SObject)JSON.deserialize(serializedRecord, SObject.class);
    }
}