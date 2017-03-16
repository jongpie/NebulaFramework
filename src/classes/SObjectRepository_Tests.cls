/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
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
                .orderBy(Schema.Lead.LastActivityDate, QuerySortOrder.DESCENDING, QueryNullSortOrder.LAST)
                .getQueryResults();
        }

        public List<Lead> getMyRecentLeads(Integer limitCount) {
            return (List<Lead>)this.queryBuilder
                .usingScope(QueryFilterScope.MINE)
                .limitCount(limitCount)
                .orderBy(Schema.Lead.LastActivityDate)
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

    static Lead createLead() {
        Lead lead = new Lead(
            Company  = 'My Test Company',
            LastName = 'Gillespie'
        );
        return lead;
    }

    @testSetup
    static void setupData() {
        List<Lead> leadList = new List<Lead>();
        for(Integer i = 0; i < 5; i++) {
            leadList.add(createLead());
        }
        insert leadList;
    }

    @isTest
    static void it_should_get_by_id_when_id() {
        Lead expectedLead = [SELECT Id FROM Lead LIMIT 1];
        // Implement test code
        //System.assert(false, 'Finish writing your test!');
        Lead returnedLead = new SObjectRepository_Tests.LeadRepository().getById(expectedLead.Id);
    }

    @isTest
    static void it_should_get_by_id_when_list_of_id() {
        Map<Id, Lead> expectedLeadList = new Map<Id, Lead>([SELECT Id FROM Lead]);
        // Implement test code
        //System.assert(false, 'Finish writing your test!');
        List<Lead> returnedLeadList = new SObjectRepository_Tests.LeadRepository().getById(new List<Id>(expectedLeadList.keySet()));
    }

    @isTest
    static void it_should_return_my_recent_leads() {
        List<Lead> expectedLeadList = [SELECT Id FROM Lead];
        // Implement test code
        //System.assert(false, 'Finish writing your test!');
        List<Lead> returnedLeadList = new SObjectRepository_Tests.LeadRepository().getMyRecentLeads(3);
    }

    @isTest
    static void it_should_return_new_this_week_by_Id() {
        Map<Id, Lead> expectedLeadMap = new Map<Id, Lead>([SELECT Id FROM Lead]);
        // Implement test code
        //System.assert(false, 'Finish writing your test!');
        List<Lead> returnedLeadList = new SObjectRepository_Tests.LeadRepository().getNewThisWeekById(new List<Id>(expectedLeadMap.keySet()));
    }

    @isTest
    static void it_should_search_in_all_fields() {
        Map<Id, Lead> expectedLeadList = new Map<Id, Lead>([SELECT Id FROM Lead]);
        // Implement test code
        //System.assert(false, 'Finish writing your test!');
        List<Lead> returnedLeadList = new SObjectRepository_Tests.LeadRepository().searchInAllFields('Gillespie');
    }

    @isTest
    static void it_should_insert_a_single_record() {
        Lead lead = createLead();
        System.assertEquals(null, lead.Id);

        Test.startTest();
        new SObjectRepository_Tests.LeadRepository().doInsert(lead);
        Test.stopTest();

        System.assertNotEquals(null, lead.Id);

        List<Lead> queriedLeadList = [SELECT Id FROM Lead WHERE Id = :lead.Id];
        System.assertEquals(1, queriedLeadList.size());
        System.assertEquals(queriedLeadList[0].Id, lead.Id);
    }

    @isTest
    static void it_should_update_a_single_record() {
        Lead existingLead = [SELECT Id, LastModifiedDate FROM Lead LIMIT 1];
        Datetime originalLastModifiedDate = existingLead.LastModifiedDate;

        Test.startTest();
        new SObjectRepository_Tests.LeadRepository().doUpdate(existingLead);
        Test.stopTest();

        existingLead = [SELECT Id, LastModifiedDate FROM Lead WHERE Id = :existingLead.Id];
        System.assert(existingLead.LastModifiedDate > originalLastModifiedDate);
    }

    @isTest
    static void it_should_delete_a_single_record() {
        Lead existingLead = [SELECT Id, IsDeleted FROM Lead LIMIT 1];
        System.assertEquals(false, existingLead.IsDeleted);

        Test.startTest();
        new SObjectRepository_Tests.LeadRepository().doDelete(existingLead);
        Test.stopTest();

        existingLead = [SELECT Id, IsDeleted FROM Lead WHERE Id = :existingLead.Id ALL ROWS];
        System.assertEquals(true, existingLead.IsDeleted);
    }

    @isTest
    static void it_should_hard_delete_a_single_record() {
        Lead existingLead = [SELECT Id, IsDeleted FROM Lead LIMIT 1];
        System.assertEquals(false, existingLead.IsDeleted);

        Test.startTest();
        new SObjectRepository_Tests.LeadRepository().doHardDelete(existingLead);
        Test.stopTest();

        List<Lead> existingLeadList = [SELECT Id, IsDeleted FROM Lead WHERE Id = :existingLead.Id ALL ROWS];
        //System.assertEquals(0, existingLeadList.size());
        // TODO figure out why the hard delete doesn't work in unit tests
    }


    @isTest
    static void it_should_undelete_a_single_record() {
        Lead existingLead = [SELECT Id, IsDeleted FROM Lead LIMIT 1];
        System.assertEquals(false, existingLead.IsDeleted);

        delete existingLead;

        existingLead = [SELECT Id, IsDeleted FROM Lead WHERE Id = :existingLead.Id ALL ROWS];
        System.assertEquals(true, existingLead.IsDeleted);

        Test.startTest();
        new SObjectRepository_Tests.LeadRepository().doUndelete(existingLead);
        Test.stopTest();

        existingLead = [SELECT Id, IsDeleted FROM Lead WHERE Id = :existingLead.Id ALL ROWS];
        System.assertEquals(false, existingLead.IsDeleted);
    }

}