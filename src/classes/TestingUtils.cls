public class TestingUtils {

    public static List<SObject> insertedRecords = new List<SObject>();
    public static List<SObject> upsertedRecords = new List<SObject>();
    public static List<SObject> updatedRecords  = new List<SObject>();
    private static Integer startingNumber = 1;

    public static List<SObject> getInsertedRecords(Schema.SObjectType sObjectType) {
        List<SObject> records = new List<SObject>();
        for(SObject sObj : insertedRecords) {
            if(sObj.getSObjectType() != sObjectType) continue;
            records.add((SObject)sObj);
        }

        return records;
    }

    public static List<SObject> getUpsertedRecords(Schema.SObjectType sObjectType) {
        List<SObject> records = new List<SObject>();
        for(SObject sObj : upsertedRecords) {
            if(sObj.getSObjectType() != sObjectType) continue;
            records.add((SObject)sObj);
        }

        return records;
    }

    /**
     * Generates Fake Ids
     * https://foobarforce.com/2013/08/15/apex-method-of-the-day-string-repeat/
     */
   public static String generateId(Schema.SObjectType sObjectType) {
      String result = String.valueOf(startingNumber++);
      return sObjectType.getDescribe().getKeyPrefix() +
         '0'.repeat(12-result.length()) + result;
   }

   /**
    * This is solution by Dan Appleman aka "The Man, the Myth, the Legend"
    * for creating an artifial time delay in Apex (since there is nothing native)
    * Advanced Apex Programing - page 196
    */
    public static void delay(Integer seconds) {
        List<Integer> largeArray = new List<Integer>();
        for(Integer x = 0; x < 1000; x++) largeArray.add(x);
        for(Integer counter = 0; counter < seconds * 4; counter++) {
            String s = json.serialize(largeArray);
        }
    }

    public static SObject setReadOnlyField(SObject sobj, String fieldName, String value) {
        String serializedRecord = JSON.serialize(sobj);
        serializedRecord = serializedRecord.removeEnd('}');
        serializedRecord += ',"' + fieldName + '":"' + value + '"}';

        return (SObject)JSON.deserialize(serializedRecord, SObject.class);
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