public interface ISObjectRecordTypes {

    ISObjectRecordTypes setSObjectType(Schema.SObjectType sobjectType);

    Map<Id, RecordType> getAllById();
    Map<String, RecordType> getAllByDeveloperName();

}