/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface ISObjectRepository {

    // SOQL
    SObject getById(Id recordId);
    List<SObject> getById(List<Id> recordIdList);
    List<SObject> get(List<QueryPredicate> queryPredicates);
    List<SObject> get(QueryPredicate queryPredicate);
    List<SObject> get(QueryPredicate queryPredicateOne, QueryPredicate queryPredicateTwo);
    List<SObject> get(QueryPredicate queryPredicateOne, QueryPredicate queryPredicateTwo, QueryPredicate queryPredicateThree);
    List<SObject> getByFieldForIds(Schema.SObjectField field, Object value, List<Id> idList);
    List<SObject> getByFieldForIds(Schema.SObjectField field, Object value, Set<Id> idSet);
    List<SObject> getCreatedSinceTimeValue(Object value);
    List<SObject> getByFieldAndTypeForGivenTimePeriod(Schema.SObjectField field, Object firstValue, Object secondValue);
    // SOSL
    List<SObject> getSearchResults(String searchTerm, QuerySearchGroup searchGroup);

    // DML
    SObject doInsert(SObject record);
    List<SObject> doInsert(List<SObject> recordList);
    SObject doUpdate(SObject record);
    List<SObject> doUpdate(List<SObject> recordList);
    SObject doUpsert(SObject record);
    List<SObject> doUpsert(List<SObject> recordList);
    SObject doUndelete(SObject record);
    List<SObject> doUndelete(List<SObject> recordList);

    void doDelete(SObject record);
    void doDelete(List<SObject> recordList);
    void doHardDelete(SObject record);
    void doHardDelete(List<SObject> recordList);
}