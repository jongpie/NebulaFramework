/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public abstract class SObjectRecordTypes extends NebulaCore {

    private static Map<String, List<RecordType>> cachedRecordTypesBySObjectMap = new Map<String, List<RecordType>>();

    public final Map<Id, RecordType> ALL_RECORD_TYPES_BY_ID;
    public final Map<String, RecordType> ALL_RECORD_TYPES_BY_DEVELOPER_NAME;

    private String sobjectName;

    public SObjectRecordTypes(Schema.DescribeSObjectResult describeSObjectResult) {
        this.currentModule = NebulaCore.Module.RECORD_TYPES;

        this.sobjectName = describeSObjectResult.getName();

        Logger.addEntry(this, 'Getting record types for ' + this.sobjectName);

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

        if(NebulaSettings.recordTypesSettings.LazyLoad__c){
            whereClauseList.add('SObjectType = \'' + this.sobjectName + '\'');
            Logger.addEntry(this, 'NebulaSettings.recordTypesSettings.LazyLoad__c=' + NebulaSettings.recordTypesSettings.LazyLoad__c);
            Logger.addEntry(this, 'this.sobjectName=' + this.sobjectName);
        }
        if(NebulaSettings.recordTypesSettings.ExcludeManagedRecordTypes__c) whereClauseList.add('NamespacePrefix = null');
        if(!whereClauseList.isEmpty()) query += ' WHERE ' + String.join(whereClauseList, ' AND ');

        query += ' ORDER BY DeveloperName';

        Logger.addEntry(this, 'SObjectRecordTypes query=' + query);

        if(!cachedRecordTypesBySObjectMap.containsKey(this.sobjectName)) cachedRecordTypesBySObjectMap.put(this.sobjectName, new List<RecordType>());
        List<RecordType> recordTypeList = (List<RecordType>)Database.query(query);
        for(RecordType recordType : recordTypeList) cachedRecordTypesBySObjectMap.get(this.sobjectName).add(recordType);

        Logger.addEntry(this, 'cachedRecordTypesBySObjectMap=' + cachedRecordTypesBySObjectMap);
    }

    private Map<Id, RecordType> getAllRecordTypesById() {
        return new Map<Id, RecordType>(cachedRecordTypesBySObjectMap.get(this.sobjectName));
    }

    private Map<String, RecordType> getAllRecordTypesByDeveloperName() {
        Map<String, RecordType> allRecordTypesByDeveloperName = new Map<String, RecordType>();
        for(RecordType recordType : this.getAllRecordTypesById().values()) {
            if(recordType.SObjectType != this.sobjectName) continue;

            allRecordTypesByDeveloperName.put(recordType.DeveloperName, recordType);
        }

        return allRecordTypesByDeveloperName;
    }
}