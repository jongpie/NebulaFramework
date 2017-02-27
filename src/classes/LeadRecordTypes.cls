public with sharing class LeadRecordTypes extends RecordTypes {

    // Each class should have at least 2 constants: ALL_RECORD_TYPES and ALL_RECORD_TYPES_BY_DEVELOPER_NAME
    public static final Map<Id, RecordType> ALL_RECORD_TYPES                       = INSTANCE.getAllRecordTypesById();
    public static final Map<String, RecordType> ALL_RECORD_TYPES_BY_DEVELOPER_NAME = INSTANCE.getAllRecordTypesByDeveloperName();

    // Each class provides constants for any important record types that need to be referenced in code
    // The inevitable hardcoding of the developer name strings are centralised only in this class
    // All other code uses these constants to minimize hardcoding
    public static final RecordType MY_FIRST_RECORD_TYPE  = INSTANCE.getRecordTypeByDeveloperName('My_First_Record_Type');
    public static final RecordType MY_SECOND_RECORD_TYPE = INSTANCE.getRecordTypeByDeveloperName('My_Second_Record_Type');
    public static final RecordType MY_THIRD_RECORD_TYPE  = INSTANCE.getRecordTypeByDeveloperName('My_Third_Record_Type');
    public static final RecordType MY_FOURTH_RECORD_TYPE = INSTANCE.getRecordTypeByDeveloperName('My_Fourth_Record_Type');

    // Collections of important or related record types can be centralised in each class via a list, set or map
    public static final Set<Id> MY_RELATED_RECORD_TYPE_IDS = new Set<Id>{LeadRecordTypes.MY_FIRST_RECORD_TYPE, LeadRecordTypes.MY_SECOND_RECORD_TYPE};

    // The instance is set at static initialization and then cached in a constant
    private static final LeadRecordTypes INSTANCE = new LeadRecordTypes();

    private LeadRecordTypes() {
        // Update the SObject type to be the revelant SObject
        super(Schema.SObjectType.Lead);
    }

}