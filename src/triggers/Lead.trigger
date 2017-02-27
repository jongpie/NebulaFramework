trigger Lead on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    // Triggers should call all before & after operations. The code within the handler class can then implement any methods needed without updating the trigger
    // Triggers should have no logic other than to call the corresponding handler class's execute method
    new LeadTriggerHandler().execute();

}