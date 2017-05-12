# Nebula Framework for Salesforce Apex
<a href="https://githubsfdeploy.herokuapp.com?owner=jongpie&repo=NebulaFramework">
     <img alt="Deploy to Salesforce"src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

Salesforce enforces a curious double standard when it comes to programming and testing - in order to deploy any changes to your production environment, it's required that your code have 75% code coverage.  Given this unique pre-requisite, the sheer lack of support within Apex for performing robust unit testing remains a remarkable (read: puzzling) offense.  The standard Test class offers very little in the way of supporting methodology.  As an example, you can use Test.setCreatedDate(SObject, Datetime) to mock the created date of a record, but it must be inserted first, and the existence of this method begs the question - why not have a corresponding method for mocking the LastModifiedDate?  What if you have behavior in your program that is checking that audit field, as opposed to the created date? Curiosities like this abound when writing tests within Apex.  Furthermore, large projects tend to have correspondingly long-running test times - making it difficult to refactor code, change business logic, or work iteratively.  With each change comes the likelihood that some existing test has broken, and the automated nature of testing - the boon of the Test Driven Development movement - now becomes the bane of the avid Salesforce programmer.  As a developer who was previously working on a project where environment differences between QA and Production were routinely causing test failures to halt deploys, with waiting times of an hour or more just to run the tests, it quickly became apparent that the two chief evils contained within our testing suite were:

1)	Complex custom object with multiple required fields – often lookups to standard objects like Account or Lead.
2)	High reliance on formula fields and other information only available to records in a post-insert reality – oftentimes requiring re-querying to retrieve the correct value.

The Nebula framework aims to address these issues – and many more - with proven methodologies for producing scalable, quick tests.  Those familiar with Apex will likely already have at least a passing familiarity with the tribal rationale that it's important to keep your business logic independent from the invocation of your triggers, which has been handed down from masters at the craft like Dan Appleman, the author of Advanced Apex Programming.  To some extent, this loose coupling is encouraged by SFDC itself in the sense that code within triggers does not need to be tested – which would indicate that your triggers shouldn’t be responsible for anything beyond initializing handlers.  The Command pattern is employed to invoke handlers to do things like update your accounts and contacts. Neubla's <a href="https://github.com/jongpie/NebulaFramework/blob/master/src/classes/SObjectTriggerHandler.cls">SObjectTriggerHandler</a> provides the unified basis for handlers to extend when inserting / updating / upserting / deleting records for the base SObject classes - Account, Lead, Contact, Case, etc ...

Oftentimes, within projects, you will find that updates to one SObject will create the need to update related records.  Traditionally in Apex, these kind of updates are provided for by injecting SOQL into your Apex code directly.  This is chiefly considered to be undesirable when it comes to the creation and maintenance of custom fields on SObjects – if you delete a custom field that is referenced in a SOQL query in your Apex code, you now have to replace that reference in each of your classes.  If you are constantly querying for Contacts related to your accounts, you are now duplicating the same SOQL statement in multiple different places in order to satisfy the needs of your WHERE clause.  Enter Nebula's <a href="https://github.com/jongpie/NebulaFramework/blob/master/src/classes/SObjectRepository.cls">SObjectRepository!</a>  Now, you have a Type-safe method for finding related records – and you can initialize your repositories through either Salesforce FieldSets (where you can declaratively setup fields to include in queries from within the safety of your Setup menu in the Salesforce UI), or by passing in a list of SObjectFields.  The SObjectRepository is combined with a powerful ORM (Object relational mapping) layer – the DML class.  This allows your repositories to be responsible for the actual creation, updating, upserting, and deletion of SObject records.

But what does this have to do with reducing test time, you might ask?  For any instance where you have related records being retrieved and then modified depending on the changes being made in your handler classes, you can now appropriately mock the SOQL retrieval and actual update / insertion.  That is to say – while it would still be difficult to mock the actual database operations associated with your standard handler classes, any SUBSEQUENT database manipulations made to corresponding objects can be mocked through the combined use of the SObjectRepositoryMocks class, and its doInsert / doUpdate / doUpsert / doDelete operations.  How does this work?  Let’s break down a hypothetical class you might be dispatching messages to from your  Account trigger – each time an account, or a list of accounts, is updated, you are invoking an AccountHandler which extends the SObjectTriggerHandler.  Within this account handler, you have some logic in the before update context of your trigger which is checking each account to determine if the Account Rating field has changed – if it does, you’d like to reset the probability of any open opportunities related to that account to 0%.  While this is a relatively abstract example, it is our hope that you may imagine the clean ease with which the pattern can be employed to power actual business logic for your organization.

Here’s how that code might look in your handler class (and the associated classes and tests).  Keep in mind that we expect that there will be many such methods in a beforeUpdate method, in addition to the one listed below – the code that appears only includes what is absolutely necessary for the example:

public class AccountHandler extends SObjectTriggerHandler {
    
    List<SObject> insertedRecords, updatedRecords;
    Map<Id,Sobject> oldAccountsMap;

    protected override void beforeUpdate(List<SObject> updatedRecords, Map<Id, SObject> updatedRecordsMap, List<SObject> oldRecords, Map<Id, SObject> oldRecordsMap) {
        this.updatedAccounts = (List<Account>) updatedRecords;
        this.oldAccountsMap = (Map<Id,Account>) oldRecordsMap;

        this.updateOppProbabilityForRatingChanges(this.updatedAccounts, this.oldAccountsMap);
    }

    private void updateOppProbabilityForRatingChanges(List<Account> accounts, Map<Id,Account> oldAccountsMap) {
        List<Id> accountIds = new List<Id>();
        for(Account account : accounts) {
            Account oldAccount = oldAccountsMap.get(account.Id);
            if(account.Rating != oldAccount.Rating) {
                accountIds.add(account.Id);
            }

        if(!accountIds.isEmpty())
            new OpportunityProbabilityUpdater().update(accountIds);
        }
    }

public class OpportunityProbabilityUpdater {

    ISObjectRepository oppRepo;

    public OpportunityProbabilityUpdater(ISObjectRepository oppRepo) {
        this.oppRepo = oppRepo;
    }

    public void update(List<Id> accountIds) {
        QueryPredicate accountsToSearch = QueryPredicate.EQUALS(Opportunity.AccountId, accountIds);
        List<Opportunity> oppsToUpdate = (List<Opportunity>) this.oppRepo.get(accountsToSearch);

        for(Opportunity opp : oppsToUpdate) {
            opp.Probability = 0;
        }

        this.oppRepo.doUpdate(opps);
    }
}

@isTest

private class OpportunityProbabilityUpdater_Tests {

    @isTest
    static void it_should_update_probability_for_found_opps() {
        SObjectRepositoryMocks mockRepo = new SObjectRepositoryMocks.Base();
        Id accountId = TestingUtils.generateId(Account.SObjectType);
        Opportunity opp = new Opportunity(AccountId = accountId, Probability = 30);
        mockRepo.with(new List<SObject>{ opp });

        Test.startTest();
        //SObjectRepositoryMocks and SObjectRepository inherit from the same interface – you can now construct the class just shown
        //using the fake repository instead of the real one
        new OpportunityProbabilityUpdater(mockRepo).update();
        Test.stopTest();

        Opportunity updatedOpp = (Opportunity) TestingUtils.updatedRecords[0];
        System.assert(updatedOpp.AccountId == accountId);
        System.assert(updatedOpp.Probability == 0, 'Probability should have been updated!');
    }
}

That’s a lot of foo there!  Hopefully it proves useful as an example of just one of the many wonderful things you can do with the SObjectRepository, while still keeping your test methods isolated to more of a true unit testing standard.  Because no objects are actually being inserted / updated - and because object initialization is quite inexpensive in terms of testing time, your test runs quickly - on the order of hundredths of a second.  By isolating your DML operations to repositories which can easily be mocked within tests, you can cut down on your overall testing time by exponential amounts.  Our current project's test suite is still quite modest - weighing in at a mere 250 tests - a mere 1/4th the size of our old, "sixty minutes or more," project's tests - but the new application's tests take less than 30 seconds to run, and the old project .... well, suffice to say, you'd best hope there's no failing test if you need to deploy in the next hour or two.

## Branches
| Name     | Build Status                                                                |
| -------- | --------                                                                    |
| master   | <img src="https://travis-ci.org/jongpie/NebulaFramework.svg?branch=master"> |
| dev      | <img src="https://travis-ci.org/jongpie/NebulaFramework.svg?branch=dev">    |
