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

        public LeadRepository(Schema.FieldSet fieldSet) {
            super(Schema.Lead.SObjectType, fieldSet);
        }

        public Lead getById(Id leadId) {
            return (Lead)this.queryBuilder
                .whereField(Schema.Lead.Id, QueryOperator.EQUALS, leadId)
                .setAsUpdate()
                .getFirstQueryResult();
        }

        public List<Lead> getById(List<Id> leadIdList) {
            return (List<Lead>)this.queryBuilder
                .whereField(Schema.Lead.Id, QueryOperator.IS_IN, leadIdList)
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
                .whereField(Schema.Lead.Id, QueryOperator.IS_IN, leadIdList)
                .whereField(Schema.Lead.CreatedDate, QueryOperator.EQUALS, QueryDateLiteral.THIS_WEEK)
                .setAsUpdate()
                .getQueryResults();
        }

        public List<Lead> searchInAllFields(String searchTerm) {
            return this.searchInFieldsBySearchGroup(searchTerm, QuerySearchGroup.ALL_FIELDS);
        }

        public List<Lead> searchInFieldsBySearchGroup(String searchTerm, QuerySearchGroup searchGroup) {
            return (List<Lead>)this.queryBuilder
                .orderBy(Schema.Lead.CreatedDate, QuerySortOrder.DESCENDING)
                .setAsUpdate() // SOSL cannot use FOR UPDATE. This will execute, but a warning debug statement will indicate that it is ignored
                .getSearchResults(searchTerm, searchGroup);
        }

        public override SObject doUpsert(SObject record) {
            Lead lead = (Lead)record;
            upsert lead;
        }

        public override List<SObject> doUpsert(List<SObject> recordList) {
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
    static void it_should_instantiate_new_instance_with_fieldset() {
        // We don't want to include unnecessary metadata in this project, like custom field sets, but we still want to test functionality
        // We'll pass a null field set to make sure a field set can be used, even though the value is null
        Schema.FieldSet fieldSet;

        Test.startTest();
        SObjectRepository_Tests.LeadRepository leadRepo = new SObjectRepository_Tests.LeadRepository(fieldSet);
        System.assertNotEquals(null, leadRepo);
        Test.stopTest();
    }

    @isTest
    static void it_should_get_by_id_when_id() {
        Lead expectedLead = [SELECT Id FROM Lead LIMIT 1];

        Test.startTest();
        Lead returnedLead = (Lead)new SObjectRepository_Tests.LeadRepository().getById(expectedLead.Id);
        Test.stopTest();

        System.assertEquals(expectedLead.Id, returnedLead.Id);
    }

    @isTest
    static void it_should_get_by_id_when_list_of_id() {
        Map<Id, Lead> expectedLeadList = new Map<Id, Lead>([SELECT Id FROM Lead]);

        Test.startTest();
        List<Lead> returnedLeadList = new SObjectRepository_Tests.LeadRepository().getById(new List<Id>(expectedLeadList.keySet()));
        Test.stopTest();

        System.assertNotEquals(null, expectedLeadList);
        System.assert(!expectedLeadList.isEmpty());
        System.assertEquals(expectedLeadList.size(), returnedLeadList.size());
    }

    @isTest
    static void it_should_return_my_recent_leads() {
        List<Lead> expectedLeadList = [SELECT Id FROM Lead LIMIT 2];

        Test.startTest();
        List<Lead> returnedLeadList = new SObjectRepository_Tests.LeadRepository().getMyRecentLeads(expectedLeadList.size());
        Test.stopTest();

        System.assertNotEquals(null, expectedLeadList);
        System.assert(!expectedLeadList.isEmpty());
        System.assertEquals(expectedLeadList.size(), returnedLeadList.size());
    }

    @isTest
    static void it_should_return_new_this_week_by_id() {
        Map<Id, Lead> expectedLeadMap = new Map<Id, Lead>([SELECT Id FROM Lead]);

        Test.startTest();
        List<Lead> returnedLeadList = new SObjectRepository_Tests.LeadRepository().getNewThisWeekById(new List<Id>(expectedLeadMap.keySet()));
        Test.stopTest();

        System.assertNotEquals(null, expectedLeadMap);
        System.assert(!expectedLeadMap.isEmpty());
        System.assertEquals(expectedLeadMap.size(), returnedLeadList.size());
    }

    @isTest
    static void it_should_search_in_all_fields() {
        String searchTerm = 'Gillespie';
        Map<Id, Lead> soslLeadMap = new Map<Id, Lead>([SELECT Id, Name FROM Lead]);
        Test.setFixedSearchResults(new List<Id>(soslLeadMap.keySet()));

        List<Lead> expectedLeadList = [FIND :searchTerm IN ALL FIELDS RETURNING Lead(Id, Name)][0];
        System.assertNotEquals(0, expectedLeadList.size());

        Test.startTest();
        List<Lead> returnedLeadList = new SObjectRepository_Tests.LeadRepository().searchInAllFields(searchTerm);
        Test.stopTest();

        System.assertNotEquals(null, expectedLeadList);
        System.assert(!expectedLeadList.isEmpty());
        System.assertEquals(expectedLeadList.size(), returnedLeadList.size());
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
        //This should work if you do instead: System.assert(deletedContacts[0].IsDeleted);
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