/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
@isTest
public class SobjectRepositoryMocks {

    public virtual class Base extends DmlMock.Base implements ISobjectRepository {

        protected List<Sobject> records;
        protected List<Id> recordIdList;
        protected List<IQueryFilter> queryFilters;

        public Base() {
            this.records = new List<Sobject>();
        }

        public Base(List<Sobject> records) {
            this.records = records;
        }

        public override Schema.SobjectType getSobjectType() {
            return Schema.User.SobjectType; // TODO change to be dynamic?
        }

        public Base with(List<Sobject> records) {
            this.records = records;
            return this;
        }

        public virtual ISobjectRepository filterBy(IQueryFilter queryFilter) {
            return this.filterBy(new List<IQueryFilter>{queryFilter});
        }

        public virtual ISobjectRepository filterBy(List<IQueryFilter> queryFilters) {
            this.queryFilters = queryFilters;
            return this;
        }

        // SOQL
        public virtual Sobject getById(Id recordId) {
            return this.getById(new List<Id>{recordId})[0];
        }

        public virtual List<Sobject> getById(List<Id> recordIdList) {
            this.recordIdList = recordIdList;

            if(this.records == null) this.createMockObjects();

            return this.records;
        }

        public virtual List<Sobject> get(List<IQueryFilter> queryFilters) {
            this.queryFilters = queryFilters;
            return this.records;
        }

        public List<Sobject> get(IQueryFilter queryFilter) {
            return this.get(new List<IQueryFilter>{queryFilter});
        }

        public List<Sobject> get(IQueryFilter queryFilterOne, IQueryFilter queryFilterTwo) {
            return this.get(new List<IQueryFilter>{queryFilterOne, queryFilterTwo});
        }

        public List<Sobject> get(IQueryFilter queryFilterOne, IQueryFilter queryFilterTwo, IQueryFilter queryFilterThree) {
            return this.get(new List<IQueryFilter>{queryFilterOne, queryFilterTwo, queryFilterThree});
        }

        public virtual List<IQueryFilter> getQueryFilters() {
            return queryFilters;
        }

        public virtual List<Sobject> getByIdAndQueryFilters(Set<Id> idList, List<IQueryFilter> queryFilters) {
            return this.getByIdAndQueryFilters(new List<Id>(idList), queryFilters);
        }

        public virtual List<Sobject> getByIdAndQueryFilters(List<Id> idList, List<IQueryFilter> queryFilters) {
            List<Sobject> records = this.getById(idList);
            // TODO need to revisit - QueryFilter no longer has the methods needed below, so need a new solution
            // for(Sobject record : records) {
            //     for(IQueryFilter queryFilter : queryFilters) {
            //         if(queryFilter.getSobjectField() == null) continue;
            //
            //         record.put(queryFilter.getSobjectField(), queryFilter.getProvidedValue());
            //     }
            // }

            return records;
        }

        // SOSL
        public virtual List<Sobject> getSearchResults(String searchTerm) {
            return this.returnListOfSobjects();
        }

        public virtual List<Sobject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup) {
            return this.returnListOfSobjects();
        }

        public virtual List<Sobject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup, List<IQueryFilter> queryFilters) {
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