/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
public class SobjectRepositoryMocks {

    public virtual class Base extends SobjectDmlMock.Base implements ISobjectRepository {

        protected List<Sobject> records;
        protected List<Id> recordIdList;
        protected List<Soql.QueryFilter> queryFilters;

        public Base() {
            this.records = new List<Sobject>();
        }

        public Base(List<Sobject> records) {
            this.records = records;
        }

        public override Schema.SobjectType getSobjectType() {
            return Schema.User.SobjectType; // TODO change to be dynamic?
        }

        public virtual Soql getSoql() {
            return new Soql(this.getSobjectType());
        }

        public Base with(List<Sobject> records) {
            this.records = records;
            return this;
        }

        public virtual ISobjectRepository filterBy(Soql.QueryFilter queryFilter) {
            return this.filterBy(new List<Soql.QueryFilter>{queryFilter});
        }

        public virtual ISobjectRepository filterBy(List<Soql.QueryFilter> queryFilters) {
            this.queryFilters = queryFilters;
            return this;
        }

        // SOQL
        public virtual Sobject get(Id recordId) {
            return this.get(new List<Id>{recordId})[0];
        }

        public virtual List<Sobject> get(Set<Id> recordIdSet) {
            return this.get(new List<Id>(recordIdSet));
        }

        public virtual List<Sobject> get(List<Id> recordIdList) {
            this.recordIdList = recordIdList;

            if(this.records == null) this.createMockObjects();

            return this.records;
        }

        public virtual List<Sobject> get(List<Soql.QueryFilter> queryFilters) {
            this.queryFilters = queryFilters;
            return this.records;
        }

        public List<Sobject> get(Soql.QueryFilter queryFilter) {
            return this.get(new List<Soql.QueryFilter>{queryFilter});
        }

        public List<Sobject> get(Soql.QueryFilter queryFilterOne, Soql.QueryFilter queryFilterTwo) {
            return this.get(new List<Soql.QueryFilter>{queryFilterOne, queryFilterTwo});
        }

        public List<Sobject> get(Soql.QueryFilter queryFilterOne, Soql.QueryFilter queryFilterTwo, Soql.QueryFilter queryFilterThree) {
            return this.get(new List<Soql.QueryFilter>{queryFilterOne, queryFilterTwo, queryFilterThree});
        }

        public virtual List<Soql.QueryFilter> getQueryFilters() {
            return queryFilters;
        }

        public virtual List<Sobject> get(Set<Id> idList, List<Soql.QueryFilter> queryFilters) {
            return this.get(new List<Id>(idList), queryFilters);
        }

        public virtual List<Sobject> get(List<Id> idList, List<Soql.QueryFilter> queryFilters) {
            List<Sobject> records = this.get(idList);
            // TODO need to revisit - QueryFilter no longer has the methods needed below, so need a new solution
            // for(Sobject record : records) {
            //     for(Soql.QueryFilter queryFilter : queryFilters) {
            //         if(queryFilter.getSobjectField() == null) continue;
            //
            //         record.put(queryFilter.getSobjectField(), queryFilter.getProvidedValue());
            //     }
            // }

            return records;
        }

        // SOSL
        public virtual List<Sobject> search(String searchTerm) {
            return this.returnListOfSobjects();
        }

        public virtual List<Sobject> search(String searchTerm, Sosl.SearchGroup searchGroup) {
            return this.returnListOfSobjects();
        }

        public virtual List<Sobject> search(String searchTerm, Sosl.SearchGroup searchGroup, List<Soql.QueryFilter> queryFilters) {
            return this.returnListOfSobjects();
        }

        private void createMockObjects() {
            // We would expect that for the Ids passed in, there will be a corresponding number of records returned of the exact same
            // SobjectType as their Ids.
            this.records = new List<Sobject>();
            for(Id recordId : this.recordIdList) {
                SobjectType objType = recordId.getSobjectType();
                Sobject record = (Sobject)Type.forName(String.valueOf(objType)).newInstance();
                record.put('Id', recordId);

                this.records.add(record);
            }
        }

        private List<Sobject> returnListOfSobjects() {
            if(this.records == null) return new List<Sobject>();

            return this.records;
        }
    }

}