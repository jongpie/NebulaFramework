public class SObjectRepositoryMocks {
    public virtual class Base extends CrudMock implements ISObjectRepository {
        protected List<SObject> records;
        protected List<Id> recordIdList;
        protected List<QueryPredicate> predicates;

        public Base() {
            this.records = new List<SObject>();
        }

        public Base(List<SObject> records) {
            this.records = records;
        }
        public Base with (List<SObject> records) {
            this.records = records;
            return this;
        }

        //SOQL
        public virtual SObject getById(Id recordId) {
            return this.getById(new List<Id>{recordId})[0];
        }

        public virtual List<SObject> getById(List<Id> recordIdList) {
            this.recordIdList = recordIdList;

            if(this.records == null) {
                this.createMockObjects();
            }

            return this.records;
        }

        public virtual List<SObject> get(List<QueryPredicate> predicates) {
            this.predicates = predicates;
            return this.records;
        }

        public List<SObject> get(QueryPredicate queryPredicate) {
            return this.get(new List<QueryPredicate> { queryPredicate });
        }

        public List<SObject> get(QueryPredicate queryPredicateOne, QueryPredicate queryPredicateTwo) {
            return this.get(new List<QueryPredicate> { queryPredicateOne, queryPredicateTwo });
        }

        public List<SObject> get(QueryPredicate queryPredicateOne, QueryPredicate queryPredicateTwo, QueryPredicate queryPredicateThree) {
            return this.get(new List<QueryPredicate> { queryPredicateOne, queryPredicateTwo, queryPredicateThree });
        }

        public virtual List<QueryPredicate> getPredicates() {
            return predicates;
        }

        public virtual List<SObject> getByFieldForIds(Schema.SObjectField field, Object value, Set<Id> idList) {
            return this.getByFieldForIds(field,value,new List<Id>(idList));
        }

        public virtual List<SObject> getByFieldForIds(Schema.SObjectField field, Object value, List<Id> idList) {
            List<SObject> records = this.getById(idList);

            for(SObject record : records) {
                record.put(field,value);
            }

            return records;
        }

        public virtual List<SObject> getByFieldAndTypeForGivenTimePeriod(Schema.SObjectField field, Object firstValue, Object secondValue) {
            if(this.records != null) return this.records;
            //Setup record and fields to be returned
            SObjectType sobjType = DescribeUtils.getSObjectType(field);
            SObject record = sobjType.newSObject();
            record.Id = TestingUtils.generateId(record.getSObjectType());
            String fieldName = field.getDescribe().getName();
            record = TestingUtils.setReadOnlyField(record, fieldName, String.valueOf(firstValue));

            this.records = new List<SObject>{record};
            return this.records;
        }

        public virtual List<SObject> getCreatedSinceTimeValue(Object value) {
            return this.returnListOfSObjects();
        }

        // SOSL
        public virtual List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup) {
            return this.returnListOfSObjects();
        }

        private void createMockObjects() {
            //We would expect that for the Ids passed in, there will be a corresponding number of records returned of the exact same
            //SObjectType as their Ids.
            this.records = new List<SObject>();
            for(Id thing : this.recordIdList) {
                SObjectType objType = thing.getSObjectType();
                SObject record = (SObject)Type.forName(String.valueOf(objType)).newInstance();
                record.put('Id', thing);

                this.records.add(record);
            }
        }

        private List<SObject> returnListOfSObjects() {
            if(CollectionUtils.isNullOrEmpty(this.records)) return new List<SObject>();

            return this.records;
        }
    }
}