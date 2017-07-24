/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public abstract class SObjectRecordTypes extends NebulaCore implements ISObjectRecordTypes {

    private static Map<String, List<RecordType>> cachedRecordTypesBySObjectMap = new Map<String, List<RecordType>>();

    private Schema.SObjectType sobjectType;
    private String sobjectName;

    public SObjectRecordTypes() {
        this.currentModule = NebulaCore.Module.RECORD_TYPES;
    }

    // TODO: finalize method
    public ISObjectRecordTypes setSObjectType(Schema.SObjectType sobjectType) {
        this.sobjectType = sobjectType;
        this.sobjectName = this.sobjectType.getDescribe().getName();

        Logger.addEntry(this, 'Getting record types for ' + this.sobjectName);

        this.populateCache();

        return this;
    }

    public Map<Id, RecordType> getAllById() {
        return new Map<Id, RecordType>(cachedRecordTypesBySObjectMap.get(this.sobjectName));
    }

    public Map<String, RecordType> getAllByDeveloperName() {
        Map<String, RecordType> allRecordTypesByDeveloperName = new Map<String, RecordType>();
        for(RecordType recordType : this.getAllById().values()) {
            if(recordType.SObjectType != this.sobjectName) continue;

            allRecordTypesByDeveloperName.put(recordType.DeveloperName, recordType);
        }

        return allRecordTypesByDeveloperName;
    }

    // TODO clean up all this mess for cache, getRecordTypes, getAllRecordTypesByDeveloperName, etc
    // Too many similarly named methods going on
    private void populateCache() {
        if(cachedRecordTypesBySObjectMap.containsKey(this.sobjectName)) return;

        Schema.SObjectType recordTypeSObjectType = Schema.getGlobalDescribe().get('RecordType');

        // If we don't have the SObject cached, then we need to query
        IQueryBuilder query = (IQueryBuilder)NebulaFactory.getQueryBuilder(this.sobjectType);

        if(NebulaSettings.RecordTypesSettings.LazyLoad__c) {
            query.filterBy(NebulaFactory.getQueryFilter().initialize(Schema.RecordType.SObjectType, QueryOperator.EQUALS, this.sobjectName));
            Logger.addEntry(this, 'NebulaSettings.RecordTypesSettings.LazyLoad__c=' + NebulaSettings.RecordTypesSettings.LazyLoad__c);
            Logger.addEntry(this, 'this.sobjectName=' + this.sobjectName);
        }

        if(!NebulaSettings.RecordTypesSettings.IncludeManagedRecordTypes__c) {
            query.filterBy(NebulaFactory.getQueryFilter().initialize(Schema.RecordType.NamespacePrefix, QueryOperator.EQUALS, null));
        }

        query.orderBy(Schema.RecordType.DeveloperName);

        Logger.addEntry(this, 'SObjectRecordTypes query=' + query.getQuery());

        if(!cachedRecordTypesBySObjectMap.containsKey(this.sobjectName)) cachedRecordTypesBySObjectMap.put(this.sobjectName, new List<RecordType>());
        List<RecordType> recordTypeList = (List<RecordType>)query.getQueryResults();
        for(RecordType recordType : recordTypeList) cachedRecordTypesBySObjectMap.get(this.sobjectName).add(recordType);

        Logger.addEntry(this, 'cachedRecordTypesBySObjectMap=' + cachedRecordTypesBySObjectMap);
    }

}