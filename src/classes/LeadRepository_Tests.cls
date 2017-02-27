@isTest
private class LeadRepository_Tests {

    @testSetup
    static void setup() {
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

        Test.startTest();

        Lead returnedLead = new LeadRepository().getRecord(expectedLead.Id);
        System.assertEquals(expectedLead.Id, returnedLead.Id);

        Test.stopTest();
    }

    @isTest
    static void getRecord_WHEN_fieldSetIsSpecified() {
        Schema.FieldSet expectedFieldSet = SObjectType.Lead.FieldSets.AnotherFieldSet;
        Lead expectedLead = [SELECT Id FROM Lead LIMIT 1];

        Test.startTest();

        Lead returnedLead = new LeadRepository(expectedFieldSet, false).getRecord(expectedLead.Id);
        System.assertEquals(expectedLead.Id, returnedLead.Id);

        Test.stopTest();
    }

    @isTest
    static void getList() {
        List<Lead> expectedLeadList = [SELECT Id FROM Lead];
        List<Id> expectedLeadIdList = new List<Id>(new Map<Id, Lead>(expectedLeadList).keySet());

        Test.startTest();

        List<Lead> returnedLeadList = new LeadRepository().getList(expectedLeadIdList);
        System.assertEquals(expectedLeadList.size(), returnedLeadList.size());

        Test.stopTest();
    }

    @isTest
    static void getListForSources() {
        String expectedLeadSource = 'GitHub';

        List<Lead> leadList = [SELECT Id, LeadSource FROM Lead LIMIT 2];
        for(Lead lead : leadList) lead.LeadSource = expectedLeadSource;
        update leadList;

        Integer leadCountForExpectedLeadSource = [SELECT COUNT() FROM Lead WHERE LeadSource = :expectedLeadSource];

        Test.startTest();

        List<Lead> returnedLeadList     = new LeadRepository().getListForSources(new List<String>{expectedLeadSource});
        System.assertEquals(leadCountForExpectedLeadSource, returnedLeadList.size());

        Test.stopTest();
    }

    @isTest
    static void getListForStatus() {
        String expectedStatus = [SELECT Status FROM Lead LIMIT 1].Status;
        Integer leadCountForExpectedStatus = [SELECT COUNT() FROM Lead WHERE Status = :expectedStatus];
        System.assert(leadCountForExpectedStatus > 0);
        Integer limitCount = leadCountForExpectedStatus - 1;

        Test.startTest();

        List<Lead> returnedLeadList = new LeadRepository().getListForStatus(expectedStatus, limitCount);
        System.assertEquals(limitCount, returnedLeadList.size());

        Test.stopTest();
    }

    @isTest
    static void searchInAllFields() {
        String searchTerm = [SELECT LastName FROM Lead WHERE LastName != null LIMIT 1].LastName;
        List<Lead> expectedLeadList = (List<Lead>)[FIND :searchTerm IN ALL FIELDS RETURNING Lead(Id WHERE IsConverted = false)][0];

        Test.startTest();

        List<Lead> returnedLeadList = new LeadRepository().searchInAllFields(searchTerm);
        System.assertEquals(expectedLeadList.size(), returnedLeadList.size());

        Test.stopTest();
    }

}