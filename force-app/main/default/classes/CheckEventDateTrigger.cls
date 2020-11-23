trigger CheckEventDateTrigger on Event__c (before insert, before update) {
    
    CheckEventDateTriggerHandler handler = new CheckEventDateTriggerHandler();
	handler.dispatch(Trigger.new);

}