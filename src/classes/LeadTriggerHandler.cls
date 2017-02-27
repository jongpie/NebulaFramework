public without sharing class LeadTriggerHandler extends TriggerHandler {

    protected override void executeBeforeInsert(List<SObject> newRecordList) {
        List<Lead> newLeadList = (List<Lead>)newRecordList;

        for(Lead newLead : newLeadList) {
            this.setStatus(newLead);
        }
    }

    protected override void executeBeforeUpdate(List<SObject> updatedRecordList, Map<Id, SObject> updatedRecordListMap, List<SObject> oldRecordList, Map<Id, SObject> oldRecordMap) {
        List<Lead> updatedLeadList = (List<Lead>)updatedRecordList;
        Map<Id, Lead> oldLeadMap   = (Map<Id, Lead>)oldRecordMap;

        for(Lead updatedLead : updatedLeadList) {
            Lead oldLead = oldLeadMap.get(updatedLead.Id);

            this.setStatus(updatedLead, oldLead);
        }
    }

    private void setStatus(Lead updatedLead, Lead oldLead) {
        // Add logic here. Methods can be overloaded to handle updates & inserts
        if(updatedLead.LeadSource != oldLead.LeadSource) {
            this.setStatus(updatedLead);
        }
    }

    private void setStatus(Lead lead) {
        // Add logic here. Methods should be simple & independent from each other (except for overloaded methods)
        if(lead.LeadSource == 'Web') lead.Status = 'Open - Not Contacted';
    }

}