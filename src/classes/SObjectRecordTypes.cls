/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/

/**
*
* @group Record Types
*
* @description TODO
*
*/
public abstract class SObjectRecordTypes extends NebulaCore implements ISObjectRecordTypes {

    private String sobjectName;

    public SObjectRecordTypes() {
        this.currentModule = NebulaCore.Module.RECORD_TYPES;

        this.sobjectName = this.getSObjectType().getDescribe().getName();
    }

    public abstract Schema.SObjectType getSObjectType();

    public Map<Id, RecordType> getAllById() {
        return new Map<Id, RecordType>(getRecordTypes());
    }

    public Map<String, RecordType> getAllByDeveloperName() {
        Map<String, RecordType> allRecordTypesByDeveloperName = new Map<String, RecordType>();
        for(RecordType recordType : this.getAllById().values()) {
            if(recordType.SObjectType != this.sobjectName) continue;

            allRecordTypesByDeveloperName.put(recordType.DeveloperName, recordType);
        }

        return allRecordTypesByDeveloperName;
    }

    private List<RecordType> getRecordTypes() {
        Schema.SObjectType recordTypeSObjectType = Schema.SObjectType.RecordType.getSObjectType();
        ISObjectQueryBuilder query = new SObjectQueryBuilder(recordTypeSObjectType).orderBy(new QueryField(Schema.RecordType.DeveloperName));

        // If we don't have the SObject cached, then we need to query
        if(NebulaSettings.RecordTypesSettings.LazyLoad__c) {
            query.filterBy(new QueryFilter().filterByField(new QueryField(Schema.RecordType.SObjectType), QueryOperator.EQUALS, this.sobjectName));
            Logger.addEntry(this, 'NebulaSettings.RecordTypesSettings.LazyLoad__c=' + NebulaSettings.RecordTypesSettings.LazyLoad__c);
            Logger.addEntry(this, 'this.sobjectName=' + this.sobjectName);
        }

        if(!NebulaSettings.RecordTypesSettings.IncludeManagedRecordTypes__c) {
            query.filterBy(new QueryFilter().filterByField(new QueryField(Schema.RecordType.NamespacePrefix), QueryOperator.EQUALS, null));
        }

        Logger.addEntry(this, 'Loading SObjectRecordTypes for=' + this.getSObjectType());

        return (List<RecordType>)query.cacheResults().getQueryResults();
    }

}