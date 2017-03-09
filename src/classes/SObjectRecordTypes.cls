public abstract class SObjectRecordTypes extends NebulaCore {

    private static Map<String, List<RecordType>> cachedRecordTypesBySObjectMap = new Map<String, List<RecordType>>();

    public final Map<Id, RecordType> ALL_RECORD_TYPES_BY_ID;
    public final Map<String, RecordType> ALL_RECORD_TYPES_BY_DEVELOPER_NAME;

    private String sobjectName;

    public SObjectRecordTypes(Schema.DescribeSObjectResult describeSObjectResult) {
        this.currentModule = NebulaCore.Module.RECORD_TYPES;

        this.sobjectName = describeSObjectResult.getName();

        this.addLogEntry('Getting record types for ' + this.sobjectName);

        this.populateCache();

        this.ALL_RECORD_TYPES_BY_ID             = this.getAllRecordTypesById();
        this.ALL_RECORD_TYPES_BY_DEVELOPER_NAME = this.getAllRecordTypesByDeveloperName();
    }

    // TODO clean up all this mess for cache, getRecordTypes, getAllRecordTypesByDeveloperName, etc
    // Too many similarly named methods going on
    private void populateCache() {
        if(cachedRecordTypesBySObjectMap.containsKey(this.sobjectName)) return;

        // If we don't have the SObject cached, then we need to query
        List<String> fieldList = new List<String>(Schema.SObjectType.RecordType.fields.getMap().keySet());

        String query = 'SELECT ' + String.join(fieldList, ', ') + ' FROM RecordType';

        List<String> whereClauseList = new List<String>();
        if(new NebulaSettings().recordTypesSettings.LazyLoad__c) whereClauseList.add('SObjectType = \'' + this.sobjectName + '\'');
        if(new NebulaSettings().recordTypesSettings.ExcludeManagedRecordTypes__c) whereClauseList.add('NamespacePrefix = null');
        if(!whereClauseList.isEmpty()) query += ' WHERE ' + String.join(whereClauseList, ' AND ');

        query += ' ORDER BY DeveloperName';

        this.addLogEntry('SObjectRecordTypes query=' + query);
        List<RecordType> recordTypeList = (List<RecordType>)Database.query(query);

        cachedRecordTypesBySObjectMap.put(this.sobjectName, recordTypeList);
    }

    private Map<Id, RecordType> getAllRecordTypesById() {
        return new Map<Id, RecordType>(cachedRecordTypesBySObjectMap.get(this.sobjectName));
    }

    private Map<String, RecordType> getAllRecordTypesByDeveloperName() {
        Map<String, RecordType> allRecordTypesByDeveloperName = new Map<String, RecordType>();
        for(RecordType recordType : this.getAllRecordTypesById().values()) allRecordTypesByDeveloperName.put(recordType.DeveloperName, recordType);

        return allRecordTypesByDeveloperName;
    }

    private class RecordTypeException extends Exception {}

}