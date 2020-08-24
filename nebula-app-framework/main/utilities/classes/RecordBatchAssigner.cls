/********************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.                    *
* See LICENSE file or go to https://github.com/jongpie/NebulaTriggerFramework for full license details. *
********************************************************************************************************/
public without sharing class RecordBatchAssigner implements Database.Batchable<SObject>, Database.Stateful {

    private Schema.SObjectType sobjectType;
    private List<Id> sobjectRecordIds;
    private Set<Id> potentialAssigneeIds;

    public RecordBatchAssigner(Schema.SObjectType sobjectType, Set<Id> potentialAssigneeIds) {
        this.sobjectType          = sobjectType;
        this.potentialAssigneeIds = potentialAssigneeIds;
    }

    public RecordBatchAssigner(List<Id> sobjectRecordIds, Set<Id> potentialAssigneeIds) {
        this(sobjectRecordIds.get(0).getSObjectType(), potentialAssigneeIds);

        this.sobjectRecordIds = sobjectRecordIds;
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        String sobjectName = this.sobjectType.getDescribe().getName();
        String query       = 'SELECT Id, OwnerId FROM ' + sobjectName + ' WHERE OwnerId NOT IN :potentialAssigneeIds';

        if(this.sobjectRecordIds != null && !this.sobjectRecordIds.isEmpty()) {
            query += ' AND Id IN :sobjectRecordIds';
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchableContext, List<SObject> scope) {
        Map<Id, Integer> assignedRecordCountsByOwnerId = this.getAssignedRecordCountsByOwnerId();

        for(SObject record : scope) {
            Id selectedOwnerId               = this.selectOwnerId(assignedRecordCountsByOwnerId);
            Integer selectedOwnerRecordCount = assignedRecordCountsByOwnerId.get(selectedOwnerId);

            // Update the record OwnerId, then increment the ownerId record count
            record.put('OwnerId', selectedOwnerId);
            assignedRecordCountsByOwnerId.put(selectedOwnerId, selectedOwnerRecordCount + 1);
        }
        update scope;
    }

    public void finish(Database.BatchableContext batchableContext) { }

    private Map<Id, Integer> getAssignedRecordCountsByOwnerId() {
        Map<Id, Integer> assignedRecordCountByOwnerId = new Map<Id, Integer>();

        // Add all owner IDs (and default count of 0) to make sure the map contains all potential assignee IDs
        for(Id ownerId : this.potentialAssigneeIds) {
            assignedRecordCountByOwnerId.put(ownerId, 0);
        }

        // Dynamically query the aggregate data
        String aggregateQueryString = 'SELECT OwnerId ownerId, COUNT(Id) recordCount'
            + ' FROM ' + this.sobjectType
            + ' WHERE OwnerId IN :potentialAssigneeIds'
            + ' GROUP BY OwnerId';
        List<AggregateResult> assignedRecordCountResults = (List<AggregateResult>)Database.query(aggregateQueryString);

        // Use the aggregate results to set the count of records owned by each assignee
        for(AggregateResult result : assignedRecordCountResults) {
            Id ownerId = (Id)result.get('ownerId');
            Integer assignedRecordCount = Integer.valueOf(result.get('recordCount'));

            assignedRecordCountByOwnerId.put(ownerId, assignedRecordCount);
        }

        return assignedRecordCountByOwnerId;
    }

    private Id selectOwnerId(Map<Id, Integer> assignedRecordCountsByOwnerId) {
        Id selectedOwnerId;
        Integer lowestRecordCount;

        for(Id ownerId : this.potentialAssigneeIds) {
            Integer currentOwnerRecordCount = assignedRecordCountsByOwnerId.get(ownerId);

            if(lowestRecordCount == null || currentOwnerRecordCount < lowestRecordCount) {
                selectedOwnerId   = ownerId;
                lowestRecordCount = currentOwnerRecordCount;
            }
        }

        return selectedOwnerId;
    }

}