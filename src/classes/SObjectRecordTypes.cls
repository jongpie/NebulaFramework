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

        this.sobjectType = getSObjectType();
        this.sobjectName = this.sobjectType.getDescribe().getName();

        Logger.addEntry(this, 'Getting record types for ' + this.sobjectName);

        this.populateCache();
    }

    public abstract Schema.SObjectType getSObjectType();

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

        // Trying to call Schema.RecordType.SObjectType confuses Apex, so we have to get it do an extra describe call
        Schema.SObjectType recordTypeSObjectType = Schema.SObjectType.RecordType.getSObjectType();
        ISObjectQueryBuilder query = (ISObjectQueryBuilder)new QueryBuilder();//NebulaFactory.getSObjectQueryBuilder().setSObjectType(recordTypeSObjectType);

        // If we don't have the SObject cached, then we need to query
        if(NebulaSettings.RecordTypesSettings.LazyLoad__c) {
            query.filterBy(NebulaFactory.getQueryFilter().setValue(Schema.RecordType.SObjectType, QueryOperator.EQUALS, this.sobjectName));
            Logger.addEntry(this, 'NebulaSettings.RecordTypesSettings.LazyLoad__c=' + NebulaSettings.RecordTypesSettings.LazyLoad__c);
            Logger.addEntry(this, 'this.sobjectName=' + this.sobjectName);
        }

        if(!NebulaSettings.RecordTypesSettings.IncludeManagedRecordTypes__c) {
            query.filterBy(NebulaFactory.getQueryFilter().setValue(Schema.RecordType.NamespacePrefix, QueryOperator.EQUALS, null));
        }

        query.orderBy(Schema.RecordType.DeveloperName);

        Logger.addEntry(this, 'SObjectRecordTypes query=' + query.getQuery());

        if(!cachedRecordTypesBySObjectMap.containsKey(this.sobjectName)) cachedRecordTypesBySObjectMap.put(this.sobjectName, new List<RecordType>());
        List<RecordType> recordTypeList = (List<RecordType>)query.getQueryResults();
        for(RecordType recordType : recordTypeList) cachedRecordTypesBySObjectMap.get(this.sobjectName).add(recordType);

        Logger.addEntry(this, 'cachedRecordTypesBySObjectMap=' + cachedRecordTypesBySObjectMap);
    }

}