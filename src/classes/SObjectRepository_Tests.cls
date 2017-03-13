@isTest
private class SObjectRepository_Tests {

    private without sharing class LeadRepository extends SObjectRepository {
        // Test subclass that extends SObjectRepository
        public LeadRepository() {
            super(Schema.Lead.SObjectType, new List<Schema.SObjectField>{Schema.Lead.Status});
        }

        public Lead getById(Id leadId) {
            return (Lead)this.queryBuilder
                .whereField(Schema.Lead.Id, new QueryOperator().EQUALS, leadId)
                .setAsUpdate()
                .getFirstQueryResult();
        }

        public List<Lead> getById(List<Id> leadIdList) {
            return (List<Lead>)this.queryBuilder
                .whereField(Schema.Lead.Id, new QueryOperator().IS_IN, leadIdList)
                .setAsUpdate()
                .getQueryResults();
        }

        public List<Lead> getNewThisWeekById(List<Id> leadIdList) {
            return (List<Lead>)this.queryBuilder
                .whereField(Schema.Lead.Id, new QueryOperator().IS_IN, leadIdList)
                .whereField(Schema.Lead.CreatedDate, new QueryOperator().EQUALS, new QueryDateLiteral().THIS_WEEK)
                .setAsUpdate()
                .getQueryResults();
        }

        public List<Lead> searchInAllFields(String searchTerm) {
            return this.searchInFieldsBySearchGroup(searchTerm, QuerySearchGroup.ALL_FIELDS);
        }

        public List<Lead> searchInFieldsBySearchGroup(String searchTerm, QuerySearchGroup searchGroup) {
            return (List<Lead>)this.queryBuilder
                .orderBy(Schema.Lead.CreatedDate, QuerySortOrder.DESCENDING)
                .limitCount(10)
                .setAsUpdate() // SOSL cannot use FOR UPDATE. This will execute, but a warning debug statement will indicate that it is ignored
                .getSearchResults(searchTerm, searchGroup);
        }

        public override void doUpsert(SObject record) {
            Lead lead = (Lead)record;
            upsert lead;
        }

        public override void doUpsert(List<SObject> recordList) {
            List<Lead> leadList = (List<Lead>)recordList;
            upsert leadList;
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
    static void getById_when_id() {
        Lead expectedLead = [SELECT Id FROM Lead LIMIT 1];
        // Implement test code
        //System.assert(false, 'Finish writing your test!');
        Lead returnedLead = new SObjectRepository_Tests.LeadRepository().getById(expectedLead.Id);
    }

    @isTest
    static void getById_when_list_of_id() {
        Map<Id, Lead> expectedLeadList = new Map<Id, Lead>([SELECT Id FROM Lead]);
        // Implement test code
        //System.assert(false, 'Finish writing your test!');
        List<Lead> returnedLeadList = new SObjectRepository_Tests.LeadRepository().getById(new List<Id>(expectedLeadList.keySet()));
    }

    @isTest
    static void getNewThisWeekById() {
        Map<Id, Lead> expectedLeadList = new Map<Id, Lead>([SELECT Id FROM Lead]);
        // Implement test code
        //System.assert(false, 'Finish writing your test!');
        List<Lead> returnedLeadList = new SObjectRepository_Tests.LeadRepository().getNewThisWeekById(new List<Id>(expectedLeadList.keySet()));
    }

    @isTest
    static void searchInAllFields() {
        Map<Id, Lead> expectedLeadList = new Map<Id, Lead>([SELECT Id FROM Lead]);
        // Implement test code
        //System.assert(false, 'Finish writing your test!');
        List<Lead> returnedLeadList = new SObjectRepository_Tests.LeadRepository().searchInAllFields('Gillespie');
    }

}