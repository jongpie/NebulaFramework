/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
public class SObjectRepositoryMocks {

    public virtual class Base extends SObjectDmlMock.Base implements ISObjectRepository {

        protected List<SObject> records;
        protected List<Id> recordIdList;
        protected List<Soql.QueryFilter> queryFilters;

        public Base() {
            this.records = new List<SObject>();
        }

        public Base(List<SObject> records) {
            this.records = records;
        }

        public override Schema.SObjectType getSObjectType() {
            return Schema.User.SObjectType; // TODO change to be dynamic?
        }

        public virtual Query getQuery() {
            return new Query(this.getSObjectType());
        }

        public virtual RecordSearch getRecordSearch(String searchTerm) {
            return new RecordSearch(searchTerm, this.getQuery());
        }

        public Base with(List<SObject> records) {
            this.records = records;
            return this;
        }

        public virtual ISObjectRepository filterBy(Soql.QueryFilter queryFilter) {
            return this.filterBy(new List<Soql.QueryFilter>{queryFilter});
        }

        public virtual ISObjectRepository filterBy(List<Soql.QueryFilter> queryFilters) {
            this.queryFilters = queryFilters;
            return this;
        }

        // SOQL
        public virtual SObject get(Id recordId) {
            return this.get(new List<Id>{recordId})[0];
        }

        public virtual List<SObject> get(Set<Id> recordIdSet) {
            return this.get(new List<Id>(recordIdSet));
        }

        public virtual List<SObject> get(List<Id> recordIdList) {
            this.recordIdList = recordIdList;

            if(this.records == null) this.createMockObjects();

            return this.records;
        }

        public virtual List<SObject> get(List<Soql.QueryFilter> queryFilters) {
            this.queryFilters = queryFilters;
            return this.records;
        }

        public List<SObject> get(Soql.QueryFilter queryFilter) {
            return this.get(new List<Soql.QueryFilter>{queryFilter});
        }

        public List<SObject> get(Soql.QueryFilter queryFilterOne, Soql.QueryFilter queryFilterTwo) {
            return this.get(new List<Soql.QueryFilter>{queryFilterOne, queryFilterTwo});
        }

        public List<SObject> get(Soql.QueryFilter queryFilterOne, Soql.QueryFilter queryFilterTwo, Soql.QueryFilter queryFilterThree) {
            return this.get(new List<Soql.QueryFilter>{queryFilterOne, queryFilterTwo, queryFilterThree});
        }

        public virtual List<Soql.QueryFilter> getQueryFilters() {
            return queryFilters;
        }

        public virtual List<SObject> get(Set<Id> idList, List<Soql.QueryFilter> queryFilters) {
            return this.get(new List<Id>(idList), queryFilters);
        }

        public virtual List<SObject> get(List<Id> idList, List<Soql.QueryFilter> queryFilters) {
            List<SObject> records = this.get(idList);
            // TODO need to revisit - QueryFilter no longer has the methods needed below, so need a new solution
            // for(SObject record : records) {
            //     for(Soql.QueryFilter queryFilter : queryFilters) {
            //         if(queryFilter.getSObjectField() == null) continue;
            //
            //         record.put(queryFilter.getSObjectField(), queryFilter.getProvidedValue());
            //     }
            // }

            return records;
        }

        // SOSL
        public virtual List<SObject> search(String searchTerm) {
            return this.returnListOfSObjects();
        }

        public virtual List<SObject> search(String searchTerm, Sosl.SearchGroup searchGroup) {
            return this.returnListOfSObjects();
        }

        public virtual List<SObject> search(String searchTerm, Sosl.SearchGroup searchGroup, List<Soql.QueryFilter> queryFilters) {
            return this.returnListOfSObjects();
        }

        private void createMockObjects() {
            // We would expect that for the Ids passed in, there will be a corresponding number of records returned of the exact same
            // SObjectType as their Ids.
            this.records = new List<SObject>();
            for(Id recordId : this.recordIdList) {
                SObjectType objType = recordId.getSObjectType();
                SObject record = (SObject)Type.forName(String.valueOf(objType)).newInstance();
                record.put('Id', recordId);

                this.records.add(record);
            }
        }

        private List<SObject> returnListOfSObjects() {
            if(this.records == null) return new List<SObject>();

            return this.records;
        }
    }

}