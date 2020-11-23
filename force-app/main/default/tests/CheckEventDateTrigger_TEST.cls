@isTest
public class CheckEventDateTrigger_TEST {

    private static final Date THE_DATE = Date.today();
    private static final Date MIN_EXISTING_START_DATE = Date.today().addDays(5);
	private static final Date MAX_EXISTING_END_DATE = Date.today().addDays(10);    
    private static final String ERROR_MSG = 'The event you are trying to create clushes with another event scheduled earlier for the same dates.';
    /**
     * Test data preparation
     */
    @TestSetup
    private static void createTestData(){          
		Event__c existingEvent = new Event__c();
        existingEvent.Name = 'Existing Event';
        existingEvent.StartDate__c = MIN_EXISTING_START_DATE;
        existingEvent.EndDate__c = MAX_EXISTING_END_DATE;  
        insert existingEvent;
    }
    
    private static Event__c getNewEvent(Date startDate, Date endDate) {
		Event__c newEvent = new Event__c();
        newEvent.Name = 'New Event';
        newEvent.StartDate__c = startDate;
        newEvent.EndDate__c = endDate;
		return newEvent;        
    }
    /**
     * Positive tests
     */
    @IsTest
    private static void newDatesBeforeExistingDateRange () {
		Event__c eventToInsert = getNewEvent(THE_DATE, THE_DATE.addDays(4));
        
        Test.startTest();
        insert eventToInsert;
		Test.stopTest();

        List<Event__c> eventList = [SELECT Id FROM Event__c];
        System.assertEquals(2, eventList.size());     
    }   

    @IsTest
    private static void newDatesAfterExistingDateRange () {
		Event__c eventToInsert = getNewEvent(THE_DATE.addDays(11), THE_DATE.addDays(12));
        
        Test.startTest();
        insert eventToInsert;
		Test.stopTest();

        List<Event__c> eventList = [SELECT Id FROM Event__c];
        System.assertEquals(2, eventList.size());     
    }   

    @IsTest
    private static void newStartDateEqualsToNewEndDate () {
		Event__c eventToInsert = getNewEvent(THE_DATE.addDays(11), THE_DATE.addDays(11));
        
        Test.startTest();
        insert eventToInsert;
		Test.stopTest();

        List<Event__c> eventList = [SELECT Id FROM Event__c];
        System.assertEquals(2, eventList.size());     
    }   
    
    @IsTest
    private static void newDatesBetweenExistingDateRanges () {
		Event__c secondExistingEvent = getNewEvent(THE_DATE.addDays(13), THE_DATE.addDays(15));
        insert secondExistingEvent;
        
        Event__c eventToInsert = getNewEvent(THE_DATE.addDays(11), THE_DATE.addDays(12));
        
        Test.startTest();
        insert eventToInsert;
		Test.stopTest();

        List<Event__c> eventList = [SELECT Id FROM Event__c];
        System.assertEquals(3, eventList.size());     
    }  
    
    @IsTest 
    private static void updateDatesPositive () {
		Boolean expectedError = false;
        Event__c eventToInsert = getNewEvent(THE_DATE.addDays(14), THE_DATE.addDays(15));
        insert eventToInsert;
		List<Date> oldDates = new List<Date> {	eventToInsert.StartDate__c,
												eventToInsert.EndDate__c };

		Event__c eventToUpdate = new Event__c(id = eventToInsert.Id,
                                             StartDate__c = THE_DATE.addDays(1),
                                             EndDate__c = THE_DATE.addDays(4));    

        Test.startTest();
        update eventToUpdate;
        Test.stopTest();

		Event__c updatedEvent = [SELECT StartDate__c, 
										EndDate__c 
									FROM Event__c
        						WHERE Id =: eventToInsert.Id];
        System.assertNotEquals(oldDates[0], updatedEvent.StartDate__c);
        System.assertNotEquals(oldDates[1], updatedEvent.EndDate__c);
    }   
    
    /**
     * Negative tests
     */    
    @IsTest 
    private static void newDatesInsideExistingDateRange () {
		Boolean expectedError = false;
        String errMsg = '';
		Event__c eventToInsert = getNewEvent(THE_DATE.addDays(5), THE_DATE.addDays(10));

        try {
            Test.startTest();
            insert eventToInsert;
            Test.stopTest();
        } catch (Exception e) {
			expectedError = e.getMessage().contains(ERROR_MSG);
            errMsg = e.getMessage();
        }
        System.debug(errMsg);
        System.assert(expectedError, 'Custom error message doesn\'t appear');
        List<Event__c> eventList = [SELECT Id FROM Event__c];
        System.assertNotEquals(2, eventList.size());     
    } 
    
    @IsTest
    private static void newEndDateInsideExistingDateRange () {
		Boolean expectedError = false;
        String errMsg = '';
		Event__c eventToInsert = getNewEvent(THE_DATE, THE_DATE.addDays(7));

        try {
            Test.startTest();
            insert eventToInsert;
            Test.stopTest();
        } catch (DMLException e) {
			expectedError = e.getMessage().contains(ERROR_MSG);
            errMsg = e.getMessage();
        }
        System.debug(' -- AL: Inside of TEST class -- error message is ' + errMsg);
        System.assert(expectedError, 'Custom error message doesn\'t appear');
        List<Event__c> eventList = [SELECT Id FROM Event__c];
        System.assertNotEquals(2, eventList.size());     
    } 
    
    @IsTest 
    private static void newStartDateInsideExistingDateRange () {
		Boolean expectedError = false;
        String errMsg = '';
		Event__c eventToInsert = getNewEvent(THE_DATE.addDays(6), THE_DATE.addDays(12));

        try {
            Test.startTest();
            insert eventToInsert;
            Test.stopTest();
        } catch (Exception e) {
			expectedError = e.getMessage().contains(ERROR_MSG);
            errMsg = e.getMessage();
        }
        System.debug(errMsg);
        System.assert(expectedError, 'Custom error message doesn\'t appear');
        List<Event__c> eventList = [SELECT Id FROM Event__c];
        System.assertNotEquals(2, eventList.size());     
    } 

    @IsTest 
    private static void newDatesIncludeExistingDateRange () {
		Boolean expectedError = false;
        String errMsg = '';
		Event__c eventToInsert = getNewEvent(THE_DATE.addDays(4), THE_DATE.addDays(11));

        try {
            Test.startTest();
            insert eventToInsert;
            Test.stopTest();
        } catch (Exception e) {
			expectedError = e.getMessage().contains(ERROR_MSG);
            errMsg = e.getMessage();
        }
        System.debug(errMsg);
        System.assert(expectedError, 'Custom error message doesn\'t appear');
        List<Event__c> eventList = [SELECT Id FROM Event__c];
        System.assertNotEquals(2, eventList.size());     
    }
    
   	@IsTest 
    private static void updateDatesNegative () {
		Boolean expectedError = false;
        String errMsg = '';
        Event__c eventToInsert = getNewEvent(THE_DATE.addDays(14), THE_DATE.addDays(15));
        insert eventToInsert;
		List<Date> oldDates = new List<Date> {	eventToInsert.StartDate__c,
												eventToInsert.EndDate__c };

		Event__c eventToUpdate = new Event__c(id = eventToInsert.Id,
                                             StartDate__c = THE_DATE.addDays(5),
                                             EndDate__c = THE_DATE.addDays(6));    
        try {
            Test.startTest();
            update eventToUpdate;
            Test.stopTest();
        } catch (Exception e) {
			expectedError = e.getMessage().contains(ERROR_MSG);
            errMsg = e.getMessage();
        }
        System.debug(errMsg);
        System.assert(expectedError, 'Custom error message doesn\'t appear');

		Event__c updatedEvent = [SELECT StartDate__c, 
										EndDate__c 
									FROM Event__c
        						WHERE Id =: eventToInsert.Id];
        System.assertEquals(oldDates[0], updatedEvent.StartDate__c);
        System.assertEquals(oldDates[1], updatedEvent.EndDate__c);
    }   
    
    /** 
     * bulk tests
     */
    @IsTest  
    private static void bulkInsertPositiveTest () {       
        Event__c validEvent1 = getNewEvent(THE_DATE, THE_DATE.addDays(4));
		Event__c validEvent2 = getNewEvent(THE_DATE.addDays(11), THE_DATE.addDays(12));
        List<Event__c> eventsToInsert = new List<Event__c>{validEvent1, validEvent2};

        Test.startTest();
        insert eventsToInsert;
        Test.stopTest();

        List<Event__c> eventList = [SELECT Id FROM Event__c];
        System.assertEquals(3, eventList.size());           
    }  
    
    @IsTest 
    private static void bulkInsertNegativeTest () {
		Boolean expectedError = false;
        String errMsg = '';
        
        Event__c validEvent = getNewEvent(THE_DATE, THE_DATE.addDays(4));
		Event__c invalidEvent = getNewEvent(THE_DATE.addDays(6), THE_DATE.addDays(8));
        List<Event__c> eventsToInsert = new List<Event__c>{validEvent, invalidEvent};

        try {   
            Test.startTest();
            insert eventsToInsert;
            Test.stopTest();
        } catch (DMLException e) {
			expectedError = e.getMessage().contains(ERROR_MSG);
            errMsg = e.getMessage();            
        }
        List<Event__c> eventList = [SELECT Id FROM Event__c];
        System.debug(' -- bulkInsertNegativeTest -- total events in db is ' + eventList.size());
        //System.assertEquals(2, eventList.size());
        System.assert(expectedError, 'Custom error message doesn\'t appear');             
    } 
    
    @IsTest 
    private static void bulkUpdateDatesNegative () {
		Boolean expectedError = false;
        String errMsg = '';
        Event__c eventToInsert1 = getNewEvent(THE_DATE.addDays(12), THE_DATE.addDays(13));
        Event__c eventToInsert2 = getNewEvent(THE_DATE.addDays(1), THE_DATE.addDays(2));
        insert new List<Event__c> {eventToInsert1, eventToInsert2};

		Event__c eventToUpdate1 = new Event__c(id = eventToInsert1.Id,
                                             StartDate__c = THE_DATE.addDays(11));        
		Event__c eventToUpdate2 = new Event__c(id = eventToInsert2.Id,
                                             EndDate__c = THE_DATE.addDays(6));  
        try {
            Test.startTest();
            	System.debug(':: TEST class -- after startTest() before update  and stopTest() is ' + errMsg);
            update new List<Event__c> {eventToUpdate1, eventToUpdate2};
                System.debug(':: TEST class -- between startTest() and stopTest() is ' + errMsg);
            Test.stopTest();
        } catch (Exception e) {
			expectedError = e.getMessage().contains(ERROR_MSG);
                        errMsg = e.getMessage();   
        }
                System.debug(':: TEST class -- errMsg is ' + errMsg);
        System.assert(expectedError, 'Custom error message doesn\'t appear');     
    }   
}