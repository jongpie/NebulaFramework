public interface ISObjectRepository {

    // SOQL
    SObject getRecord(Id recordId);
    List<SObject> getList(List<Id> recordIdList);

    // SOSL
    List<SObject> searchInAllFields(String searchTerm);

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