global abstract class SObjectRecordTypes {

    private static Map<String, List<RecordType>> cachedRecordTypesBySObjectMap = new Map<String, List<RecordType>>();

    global final Map<Id, RecordType> ALL_RECORD_TYPES_BY_ID;
    global final Map<String, RecordType> ALL_RECORD_TYPES_BY_DEVELOPER_NAME;

    private String sobjectName;
    private RecordTypesSettings__c recordTypesSettings;

    global SObjectRecordTypes() {
        this(null);
    }

    global SObjectRecordTypes(Schema.DescribeSObjectResult describeSObjectResult) {
        this.sobjectName = describeSObjectResult.getName();

        this.getRecordTypeSettings();
        this.populateCache();

        this.ALL_RECORD_TYPES_BY_ID             = this.getAllRecordTypesById();
        this.ALL_RECORD_TYPES_BY_DEVELOPER_NAME = this.getAllRecordTypesByDeveloperName();
    }

    private void getRecordTypeSettings() {
        this.recordTypesSettings = RecordTypesSettings__c.getInstance();

        if(this.recordTypesSettings.Id == null) {
            // If there's no ID, then there are settings setup for the current user at the user, profile or org level
            // Upsert the org defaults - the default field values will be used
            upsert RecordTypesSettings__c.getOrgDefaults();
            // Call getInstance() again to get the settings with the field defaults
            this.recordTypesSettings = RecordTypesSettings__c.getInstance();
        }
    }

    private void populateCache() {
        if(cachedRecordTypesBySObjectMap.containsKey(this.sobjectName)) return;
        else cachedRecordTypesBySObjectMap.put(this.sobjectName, this.getRecordTypes());
    }

    private List<RecordType> getRecordTypes() {
        List<String> fieldList = new List<String>(Schema.SObjectType.RecordType.fields.getMap().keySet());

        String query = 'SELECT ' + String.join(fieldList, ', ') + ' FROM RecordType';

        List<String> whereClauseList = new List<String>();
        if(this.recordTypesSettings.LazyLoad__c) whereClauseList.add('SObjectType = \'' + this.sobjectName + '\'');
        if(this.recordTypesSettings.ExcludeManagedRecordTypes__c) whereClauseList.add('NamespacePrefix = null');
        if(!whereClauseList.isEmpty()) query += ' WHERE ' + String.join(whereClauseList, ' AND ');

        query += ' ORDER BY DeveloperName';

        System.debug(query);
        return (List<RecordType>)Database.query(query);
    }

    private Map<Id, RecordType> getAllRecordTypesById() {
        return new Map<Id, RecordType>(cachedRecordTypesBySObjectMap.get(this.sobjectName));
    }

    private Map<String, RecordType> getAllRecordTypesByDeveloperName() {
        Map<String, RecordType> allRecordTypesByDeveloperName= new Map<String, RecordType>();
        for(RecordType recordType : this.getAllRecordTypesById().values()) allRecordTypesByDeveloperName.put(recordType.DeveloperName, recordType);

        return allRecordTypesByDeveloperName;
    }

    private class RecordTypeException extends Exception {}

}