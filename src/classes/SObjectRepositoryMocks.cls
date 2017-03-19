public class SObjectRepositoryMocks {
    public virtual class Base implements ISObjectRepository {
        protected List<SObject> records;
        protected List<Id> recordIdList;

        public Base with (List<SObject> records) {
            this.records = records;
            return this;
        }

        // SOQL
        public SObject getById(Id recordId) {
            return this.getById(new List<Id>{recordId})[0];
        }

        public List<SObject> getById(List<Id> recordIdList) {
            this.recordIdList = recordIdList;

            if(this.records == null) this.createMockObjects();

            return this.records;
        }

        public List<SObject> getByFieldForIds(Schema.SObjectField field, Object value, Set<Id> idList) {
            return this.getByFieldForIds(field,value,new List<Id>(idList));
        }

        public List<SObject> getByFieldForIds(Schema.SObjectField field, Object value, List<Id> idList) {
            List<SObject> records = this.getById(idList);

            for(SObject record : records) record.put(field,value);

            return records;
        }

        public List<SObject> getByFieldAndTypeForGivenTimePeriod(Schema.SObjectField field, Object operator, Object value) {
            //Standard Salesforce fields are available on more than one object.
            //We will default to returning the first object type for now.
            SObjectType objType = field.getDescribe().getReferenceTo()[0];

            if(this.records != null) return this.records;

            this.records = new List<SObject>();
            SObject record = (SObject)Type.forName(String.valueOf(objType)).newInstance();
            this.setId(new List<SObject>{record});
            this.records.add(record);

            return this.records;
        }

        public List<SObject> getCreatedSinceTimeValue(Object value) {

            return this.returnListOfSObjects();
        }

        // SOSL
        public List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup) {

            return this.returnListOfSObjects();
        }

        // DML
        public void doInsert(SObject record) { this.doInsert(new List<SObject>{record}); }

        public void doInsert(List<SObject> recordList) {
            this.setId(recordList);
            TestingUtils.insertedRecords.addAll(recordList);
        }

        public void doUpdate(SObject record) { this.doUpdate(new List<SObject>{record});}
        public void doUpdate(List<SObject> recordList) { TestingUtils.updatedRecords.addAll(recordList); }

        public void doUpsert(SObject record) { this.doUpsert(new List<SObject>{record}); }
        public void doUpsert(List<SObject> recordList) {
            this.setId(recordList);
            TestingUtils.upsertedRecords.addAll(recordList);
        }

        public void doDelete(SObject record) { this.doDelete(new List<SObject>{record}); }
        public void doDelete(List<SObject> recordList) { TestingUtils.deletedRecords.addAll(recordList); }

        public void doHardDelete(SObject record) { this.doDelete(record); }
        public void doHardDelete(List<SObject> recordList) { this.doDelete(recordList); }
        public void doUndelete(SObject record) { this.doUndelete(new List<SObject>{record}); }
        public void doUndelete(List<SObject> recordList) { TestingUtils.undeletedRecords.addAll(recordList); }

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
            if(this.records.isEmpty()) return new List<SObject>();

            return this.records;
        }

        private void setId(List<SObject> records) {
                for(SObject record : records) {
                    if(record.Id != null) continue;
                    record.Id = TestingUtils.generateId(record.getSObjectType());
                }
            }
        }
}