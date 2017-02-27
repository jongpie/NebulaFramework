public without sharing class LeadRepository extends SObjectRepository {

    private static final Schema.FieldSet DEFAULT_FIELD_SET = SObjectType.Lead.FieldSets.MyFieldSet;

    public LeadRepository() {
        super(LeadRepository.DEFAULT_FIELD_SET);
        // Any conditions added in the constructor will apply to all queries in this class
        this.whereIsConverted(false);
    }

    // Overload the constructor if you want to allow other code to specify the field set used
    public LeadRepository(Schema.FieldSet fieldSet, Boolean addCommonQueryFields) {
        super(fieldSet, addCommonQueryFields);
    }

    // ISObjectRepository requires at least 2 methods, getRecord & getList
    public Lead getRecord(Id leadId) {
        return (Lead)this
            .whereIdEquals(leadId)
            .setAsUpdate()
            .getFirstQueryResult();
    }

    public List<Lead> getList(List<Id> leadIdList) {
        return (List<Lead>)this
            .whereIdIn(leadIdList)
            .setAsUpdate()
            .getQueryResults();
    }

    // Add public methods needed that return the query results
    // Only methods that return an SObject or collection of SObjects should be made public
    public List<Lead> getListForSources(List<String> leadSourceList) {
        return (List<Lead>)this
            .whereFieldIn(Schema.Lead.LeadSource, leadSourceList)
            .orderBy(Schema.Lead.CreatedDate)
            .getQueryResults();
    }

    public List<Lead> getListForStatus(String status, Integer limitCount) {
        return (List<Lead>)this
            .whereIsConverted(false)
            .whereStatusEquals(status)
            .limitCount(limitCount)
            .orderBy(Schema.Lead.LastModifiedDate, SObjectRepository.SortOrder.DESCENDING)
            .setAsUpdate()
            .getQueryResults();
    }

    public List<Lead> searchInAllFields(String searchTerm) {
        return (List<Lead>)this
            .whereIsConverted(false)
            .orderBy(Schema.Lead.CreatedDate, SObjectRepository.SortOrder.DESCENDING)
            .limitCount(10)
            .setAsUpdate() // SOSL cannot use FOR UPDATE. This will execute, but a warning debug statement will indicate that it is ignored
            .getSearchResults(searchTerm, SObjectRepository.SearchGroup.ALL_FIELDS);
    }

    // You can add additional builder methods for any commonly used filters for this SObject
    // All builder methods should be kept as private or protected
    private LeadRepository whereIsConverted(Boolean bool) {
        return (LeadRepository)this.whereFieldEquals(Schema.Lead.IsConverted, bool);
    }

    private LeadRepository whereStatusEquals(String status) {
        return (LeadRepository)this.whereFieldEquals(Schema.Lead.Status, status);
    }

}