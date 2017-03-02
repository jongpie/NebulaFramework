public abstract class SObjectRecordTypes {

    private static Map<String, List<RecordType>> cachedRecordTypesBySObjectMap = new Map<String, List<RecordType>>();

    public Map<Id, RecordType> ALL_RECORD_TYPES_BY_ID;
    public Map<String, RecordType> ALL_RECORD_TYPES_BY_DEVELOPER_NAME;

    private String sobjectName;
    private RecordTypesSettings__c recordTypesSettings;

    protected SObjectRecordTypes(Schema.DescribeSObjectResult describeSObjectResult) {
        this.sobjectName = describeSObjectResult.getName();

        this.getRecordTypeSettings();
        this.populateCache();

        this.setAllRecordTypesById();
        this.setAllRecordTypesByDeveloperName();
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

    private void setAllRecordTypesById() {
        this.ALL_RECORD_TYPES_BY_ID = new Map<Id, RecordType>(cachedRecordTypesBySObjectMap.get(this.sobjectName));
        System.debug('ALL_RECORD_TYPES_BY_ID=' + this.ALL_RECORD_TYPES_BY_ID);
    }

    private void setAllRecordTypesByDeveloperName() {
        this.ALL_RECORD_TYPES_BY_DEVELOPER_NAME = new Map<String, RecordType>();
        for(RecordType recordType : this.ALL_RECORD_TYPES_BY_ID.values()) this.ALL_RECORD_TYPES_BY_DEVELOPER_NAME.put(recordType.DeveloperName, recordType);
    }

    private class RecordTypeException extends Exception {}

}