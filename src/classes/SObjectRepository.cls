/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public virtual class SObjectRepository extends NebulaCore implements ISObjectRepository, ICrud {

    protected IQueryBuilder queryBuilder;

    protected SObjectRepository(Schema.SObjectType sobjectType, Schema.FieldSet fieldSet) {
        this(sobjectType, fieldSet, null);
    }

    protected SObjectRepository(Schema.SObjectType sobjectType, List<Schema.SObjectField> sobjectFieldList) {
        this(sobjectType, null, sobjectFieldList);
    }

    private SObjectRepository(Schema.SObjectType sobjectType, Schema.FieldSet fieldSet, List<Schema.SObjectField> sobjectFieldList) {
        this.currentModule = NebulaCore.Module.REPOSITORY;

        this.sObjectType = sObjectType;
        this.fieldSet = fieldSet;
        this.sObjectFieldList = sObjectFieldList;
        this.idField = this.getField(this.sObjectType, 'Id');
    }

    protected IQueryBuilder queryFactory {
        get {
            return new QueryBuilder(sObjectType, fieldSet, sObjectFieldList);
        }
    }

    //SOQL
    public virtual SObject getById(Id recordId) {
        return this.queryFactory
            .whereField(new List<QueryPredicate>{QueryPredicate.EQUALS(this.idField, recordId)})
            .getFirstOrDefault();
    }

    public virtual List<SObject> getById(List<Id> recordIds) {
        return this.queryFactory
            .whereField(new List<QueryPredicate>{QueryPredicate.EQUALS(this.idField, recordIds)})
            .getQueryResults();
    }

    public virtual List<SObject> get(List<QueryPredicate> queryPredicates) {
        return this.queryFactory
            .whereField(queryPredicates)
            .getQueryResults();
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

    public virtual List<SObject> getByFieldForIds(Schema.SObjectField field, Object value, Set<Id> idSet) {
        return this.getByFieldForIds(field, value, new List<Id>(idSet));
    }

    public virtual List<SObject> getByFieldForIds(Schema.SObjectField field, Object value, List<Id> recordIds) {
        return this.queryFactory
            .whereField(this.idField, new QueryOperator().IS_IN, recordIds)
            .whereField(field, new QueryOperator().EQUALS, value)
            .getQueryResults();
    }

    public List<SObject> getCreatedSinceTimeValue(Object timeValue) {
        Schema.SObjectField createdDate = this.getCreatedDate();
        return this.queryFactory
            .whereField(createdDate, new QueryOperator().GREATER_THAN_OR_EQUAL_TO, timeValue)
            .getQueryResults();
    }

    public List<SObject> getByFieldAndTypeForGivenTimePeriod(Schema.SObjectField field, Object firstValue, Object secondValue) {
        Schema.SObjectField createdDate = this.getCreatedDate();
        return this.queryFactory
            .whereField(field, new QueryOperator().EQUALS, firstValue)
            .whereField(createdDate, new QueryOperator().GREATER_THAN_OR_EQUAL_TO, secondValue)
            .getQueryResults();
    }

    //SOSL
    public virtual List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup) {
        return (List<SObject>)this.queryFactory
            .limitCount(10)
            .getSearchResults(searchTerm, searchGroup);
    }

    private Schema.SObjectField getCreatedDate() {
        return this.getField(this.sObjectType, 'CreatedDate');
    }

    private Schema.SObjectField getField(Schema.SObjectType objType, String fieldName) {
        return DescribeUtils.getFieldForSObjectType(objType, fieldName);
    }

    //CRUD - virtual so that DML options / upserting on specific foreign Id's can be allowed through overriding
        public virtual SObject doInsert(SObject record) { return this.doInsert(new List<SObject>{record})[0];}
    public virtual List<SObject> doInsert(List<SObject> records) {
        Database.insert(records);
        return records;
    }

    public virtual SObject doUpdate(SObject record) { return this.doUpdate(new List<SObject>{record})[0]; }
    public virtual List<SObject> doUpdate(List<SObject> records) {
        Database.update(records);
        return records;
    }

    public virtual SObject doUpsert(SObject record) {
        //Salesforce will only allow upsert calls for SObjects if a declared-type list is passed in.
        //This is fine for the bulk method, where we can assume the caller is passing in an explicit list, but for a single record,
        //the only way to successfully perform the upsert is to dynamically spin up a list of the SObject's type
        String listType = 'List<' + record.getSObjectType() + '>';
        List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
        castRecords.add(record);
        return this.doUpsert(castRecords)[0];
    }

    public virtual List<SObject> doUpsert(List<SObject> records) {
        Database.upsert(records);
        return records;
    }

    public virtual SObject doUndelete(SObject record) { return this.doUnDelete(new List<SObject>{record})[0]; }
    public virtual List<SObject> doUndelete(List<SObject> records) {
        Database.undelete(records);
        return records;
    }

    public virtual void doDelete(SObject record) { this.doDelete(new List<SObject>{record}); }
    public virtual void doDelete(List<SObject> records) {
        if(records.isEmpty() == false) {
            Database.delete(records);
        }
    }

    public virtual void doHardDelete(SObject record) { this.doHardDelete(new List<SObject>{record}); }
    public virtual void doHardDelete(List<SObject> records) {
        this.doDelete(records);
        if(records.isEmpty() == false) {
            Database.emptyRecycleBin(records);
        }
    }
}