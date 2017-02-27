public interface ISObjectRepository {

    // SOQL
    SObject getRecord(Id recordId);
    List<SObject> getList(List<Id> recordIdList);
    // SOSL
    List<SObject> searchInAllFields(String searchTerm);

}