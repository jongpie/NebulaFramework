@isTest
private class SObjectRepository_Tests {

    private without sharing class LeadRepository extends SObjectRepository {
        // Test subclass that extends SObjectRepository
        public LeadRepository() {
            super(Schema.Lead.SObjectType, new List<Schema.SObjectField>{Schema.Lead.Status});
        }

        public Lead getRecord(Id leadId) {
            return (Lead)this.queryBuilder
                .whereField(Schema.Lead.Id, EQUALS, leadId)
                .setAsUpdate()
                .getFirstQueryResult();
        }

        public List<Lead> getList(List<Id> leadIdList) {
            return (List<Lead>)this.queryBuilder
                .whereField(Schema.Lead.Id, IS_IN, leadIdList)
                .setAsUpdate()
                .getQueryResults();
        }

        public List<Lead> searchInAllFields(String searchTerm) {
            return this.searchInAllFieldsBySearchGroup(Nebula.QueryBuilder.SearchGroup.ALL_FIELDS);
        }

        public List<Lead> searchInAllFieldsBySearchGroup(String searchTerm, Nebula.QueryBuilder.SearchGroup searchGroup) {
            return (List<Lead>)this.queryBuilder
                .orderBy(Schema.Lead.CreatedDate, Nebula.QueryBuilder.SortOrder.DESCENDING)
                .limitCount(10)
                .setAsUpdate() // SOSL cannot use FOR UPDATE. This will execute, but a warning debug statement will indicate that it is ignored
                .getSearchResults(searchTerm, searchGroup);
        }
    }

    @testSetup
    static void setupData() {
        List<Lead> leadList = new List<Lead>();
        for(Integer i = 0; i < 5; i++) {
            Lead lead = new Lead(
                Company  = 'My Test Company',
                LastName = 'Gillespie'
            );
            leadList.add(lead);
        }
        insert leadList;
    }

    @isTest
    static void getRecord() {
        Lead expectedLead = [SELECT Id FROM Lead LIMIT 1];
        // Implement test code
        //System.assert(false, 'Finish writing your test!');
        Lead returnedLead = new SObjectRepository_Tests.LeadRepository().getRecord(expectedLead.Id);
    }

    @isTest
    static void getList() {
        Map<Id, Lead> expectedLeadList = new Map<Id, Lead>([SELECT Id FROM Lead]);
        // Implement test code
        //System.assert(false, 'Finish writing your test!');
        List<Lead> returnedLeadList = new SObjectRepository_Tests.LeadRepository().getList(new List<Id>(expectedLeadList.keySet()));
    }

    @isTest
    static void searchInAllFields() {
        Map<Id, Lead> expectedLeadList = new Map<Id, Lead>([SELECT Id FROM Lead]);
        // Implement test code
        //System.assert(false, 'Finish writing your test!');
        List<Lead> returnedLeadList = new SObjectRepository_Tests.LeadRepository().searchInAllFields('Gillespie');
    }

}