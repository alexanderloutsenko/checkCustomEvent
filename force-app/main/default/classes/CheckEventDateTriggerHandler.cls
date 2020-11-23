public with sharing class CheckEventDateTriggerHandler {
	private TriggerOperation currentTriggerOperation;
    static final String ERROR_MSG = 'The event you are trying to create clushes with another event scheduled earlier for the same dates.';
    static Set<Date> existingDatesSet = new Set<Date>();

    public CheckEventDateTriggerHandler() {
        currentTriggerOperation = Trigger.operationType;
        setExistingEvents();
    }

    public void dispatch(Event__c[] triggerNew) {
        if(currentTriggerOperation == TriggerOperation.BEFORE_INSERT){
            onBeforeInsert(triggerNew);
        }
        if(currentTriggerOperation == TriggerOperation.BEFORE_UPDATE) {
            onBeforeUpdate(triggerNew, Trigger.oldMap);            
        }
    }
    
    public void onBeforeInsert(Event__c[] newEvents){
        // check whether any date from a new event exists within the existing dates' range
        for(Event__c event : newEvents) {
            checkNewDatesAgainstExistingDates(event, existingDatesSet);
        }
    }

    public void onBeforeUpdate(Event__c[] triggerNew, Map<Id, SObject> triggerOldMap){

        for(Event__c newEventObj : triggerNew) {
            Set<Date> newExistingDatesSet = existingDatesSet.clone();
            List<Date> oldDates = new List<Date>();

            // exclude old event's dates from existing dates' set
            Event__c oldEventObj = (Event__c)triggerOldMap.get(newEventObj.Id);           
                for(Integer i = 0; oldEventObj.StartDate__c.addDays(i) <= oldEventObj.EndDate__c; i++) {
                    oldDates.add(oldEventObj.StartDate__c.addDays(i));
                }           
            newExistingDatesSet.removeAll(oldDates); 
            
            // check whether any date from a new event exists within the existing dates' range
            checkNewDatesAgainstExistingDates(newEventObj, newExistingDatesSet);
        }
    }

    public void setExistingEvents () {
        // select all existing dates from db (in assumption that there is no active events more than 50k)
        List<Event__c> existingEvents = [SELECT StartDate__c,
                                 EndDate__c,
                                 CreatedDate
                            FROM Event__c
                            WHERE StartDate__c >= TODAY
                            ORDER BY CreatedDate ASC 
                            LIMIT 50000];
        // put all existing dates into a set	
        for(Event__c event : existingEvents) {
            for(Integer i = 0; event.StartDate__c.addDays(i) <= event.EndDate__c; i++) {
                existingDatesSet.add(event.StartDate__c.addDays(i));               
            }
        }
    }

    public void checkNewDatesAgainstExistingDates (Event__c newEvent, Set<Date> existingDates) {
        for(Integer i = 0; newEvent.StartDate__c.addDays(i) <= newEvent.EndDate__c; i++) { 
            if(existingDates.contains(newEvent.StartDate__c.addDays(i))) {
                newEvent.addError(ERROR_MSG);
                break;                 
            }                           
        }
    }
}