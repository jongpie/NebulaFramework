public interface ISObjectRepository {

    // SOQL
    SObject getById(Id recordId);
    List<SObject> getById(List<Id> recordIdList);

    // SOSL
    List<SObject> searchInAllFields(String searchTerm);
    List<SObject> searchInFieldsBySearchGroup(String searchTerm, QueryBuilder.SearchGroup searchGroup);

    // DML
    void doInsert(SObject record);
    void doInsert(List<SObject> recordList);
    void doUpdate(SObject record);
    void doUpdate(List<SObject> recordList);
    void doUpsert(SObject record);
    void doUpsert(List<SObject> recordList);
    void doDelete(SObject record);
    void doDelete(List<SObject> recordList);
    void doHardDelete(SObject record);
    void doHardDelete(List<SObject> recordList);
    void doUndelete(SObject record);
    void doUndelete(List<SObject> recordList);

}