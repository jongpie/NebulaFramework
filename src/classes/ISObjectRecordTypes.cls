

/**
*
* @group Record Types
*
* @description TODO
*/
public interface ISObjectRecordTypes {

    // Setup methods
    Schema.SObjectType getSObjectType();

    // Getter methods
    Map<Id, RecordType> getAllById();
    Map<String, RecordType> getAllByDeveloperName();

}