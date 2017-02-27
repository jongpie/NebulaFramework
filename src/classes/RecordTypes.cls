public abstract class RecordTypes {

    private static Set<String> cachedSObjectTypes = new Set<String>();

    private Map<Id, RecordType> allRecordTypesById;
    private Map<String, RecordType> allRecordTypesByDeveloperName;
    private String sobjectLabel, sobjectName;
    private Schema.DescribeSObjectResult sobjectResult;

    protected RecordTypes(Schema.DescribeSObjectResult sobjectResult) {
        this.sobjectResult = sobjectResult;
    }

    public Map<Id, RecordType> getAllRecordTypesById() {
        if(this.allRecordTypesById == null) this.allRecordTypesById = new Map<Id, RecordType>(this.getAllRecordTypes());

        return this.allRecordTypesById;
    }

    public Map<String, RecordType> getAllRecordTypesByDeveloperName() {
        if(this.allRecordTypesByDeveloperName == null) {
            this.allRecordTypesByDeveloperName = new Map<String, RecordType>();

            for(RecordType recordType : this.allRecordTypesById.values()) {
                this.allRecordTypesByDeveloperName.put(recordType.DeveloperName, recordType);
            }
        }

        return this.allRecordTypesByDeveloperName;
    }

    public RecordType getRecordTypeByDeveloperName(String recordTypeDeveloperName) {
        if(!getAllRecordTypesByDeveloperName().containsKey(recordTypeDeveloperName)) {
            throw new Exceptions.RecordTypeException('The record type \'' + recordTypeDeveloperName + '\' was not found for ' + this.sobjectLabel);
        }

        return this.getAllRecordTypesByDeveloperName().get(recordTypeDeveloperName);
    }

    private List<RecordType> getAllRecordTypes() {
        return [
            SELECT Id, DeveloperName, Name, NamespacePrefix, BusinessProcessId, IsActive
            FROM RecordType
            WHERE SObjectType = :this.sobjectName
            ORDER BY DeveloperName
        ];
    }

}