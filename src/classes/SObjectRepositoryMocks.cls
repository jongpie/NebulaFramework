/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/


/**
*
* @group Repository
*
* @description TODO
*/
@isTest
public class SObjectRepositoryMocks {

    public virtual class Base extends DMLMock.Base implements ISObjectRepository {

        protected List<SObject> records;
        protected List<Id> recordIdList;
        protected List<IQueryFilter> queryFilters;

        public Base() {
            this.records = new List<SObject>();
        }

        public Base(List<SObject> records) {
            this.records = records;
        }

        public Schema.SObjectType getSObjectType() {
            // TODO fix this
            return Schema.User.SObjectType;
        }

        public Base with(List<SObject> records) {
            this.records = records;
            return this;
        }

        public virtual ISObjectRepository filterBy(IQueryFilter queryFilter) {
            return this.filterBy(new List<IQueryFilter>{queryFilter});
        }

        public virtual ISObjectRepository filterBy(List<IQueryFilter> queryFilters) {
            this.queryFilters = queryFilters;
            return this;
        }

        // SOQL
        public virtual SObject getById(Id recordId) {
            return this.getById(new List<Id>{recordId})[0];
        }

        public virtual List<SObject> getById(List<Id> recordIdList) {
            this.recordIdList = recordIdList;

            if(this.records == null) this.createMockObjects();

            return this.records;
        }

        public virtual List<SObject> get(List<IQueryFilter> queryFilters) {
            this.queryFilters = queryFilters;
            return this.records;
        }

        public List<SObject> get(IQueryFilter queryFilter) {
            return this.get(new List<IQueryFilter>{queryFilter});
        }

        public List<SObject> get(IQueryFilter queryFilterOne, IQueryFilter queryFilterTwo) {
            return this.get(new List<IQueryFilter>{queryFilterOne, queryFilterTwo});
        }

        public List<SObject> get(IQueryFilter queryFilterOne, IQueryFilter queryFilterTwo, IQueryFilter queryFilterThree) {
            return this.get(new List<IQueryFilter>{queryFilterOne, queryFilterTwo, queryFilterThree});
        }

        public virtual List<IQueryFilter> getQueryFilters() {
            return queryFilters;
        }

        public virtual List<SObject> getByIdAndQueryFilters(Set<Id> idList, List<IQueryFilter> queryFilters) {
            return this.getByIdAndQueryFilters(new List<Id>(idList), queryFilters);
        }

        public virtual List<SObject> getByIdAndQueryFilters(List<Id> idList, List<IQueryFilter> queryFilters) {
            List<SObject> records = this.getById(idList);
            for(SObject record : records) {
                for(IQueryFilter queryFilter : queryFilters) {
                    if(queryFilter.getSObjectField() == null) continue;

                    record.put(queryFilter.getSObjectField(), queryFilter.getProvidedValue());
                }
            }

            return records;
        }

        // SOSL
        public virtual List<SObject> getSearchResults(String searchTerm) {
            return this.returnListOfSObjects();
        }

        public virtual List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup) {
            return this.returnListOfSObjects();
        }

        public virtual List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup, List<IQueryFilter> queryFilters) {
            return this.returnListOfSObjects();
        }
//TODO this should be deleted?
        public virtual ISObjectQueryBuilder getQueryBuilder() {
            return new SObjectQueryBuilder().setSObjectType(this.records.getSObjectType());
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