@IsTest
private class SchedulerManagerControllerTest {
    @TestSetup
    static void setup(){
        Contact testContact = new Contact(FirstName = 'TestFirstName',
                                            LastName = 'TestLastName', 
                                            Email = 'test@gmail.com', 
                                            Birthdate = Date.today());
        insert testContact;
    }
    @IsTest
    static void testRunOnceBatch(){
        Test.startTest();
            SchedulerManagerController.runOnceBatch('ContactBirthdayEmailBatch');
        
        Test.stopTest();
        //Integer invocations = Limits.getEmailInvocations();
        //System.assertEquals(1, invocations); 
        //Id contactId = [SELECT Id FROM Contact WHERE LastName = 'TestLastName'].Id;
        // Integer result = [SELECT count() FROM EmailMessage];
        // System.assertEquals(1, result);
    }
    
    @IsTest
    static void testScheduler(){
        Test.startTest();
        Id testJobID = SchedulerManagerController.scheduleBatch('BatchScheduler', '0 0 10 * * ? *', 'Birthday Email');
        Id resultJob = [SELECT Id FROM CronTrigger LIMIT 1].Id;
        System.assertEquals(testJobID, resultJob);
        System.assertEquals(testJobID, SchedulerManagerController.getJobState('Birthday Email'));
        SchedulerManagerController.abortBatch(testJobID);
        List<CronTrigger> result = [SELECT Id FROM CronTrigger];
        System.assertEquals(0, result.size()); 
        Test.stopTest();
    }

    @IsTest
    static void testBatchScheduler(){
        
        Test.startTest();
            BatchScheduler BS = new BatchScheduler();
            BS.execute(null);
        Test.stopTest();
        //System.assertEquals(1, Limits.getEmailInvocations()); 
        //Id contactId = [SELECT Id FROM Contact WHERE LastName = 'TestLastName'].Id;
        // Integer result = [SELECT count() FROM EmailMessage];
        // System.assertEquals(1, result);
    }

    @IsTest
    static void testNegativeRunOnceBatch(){
        
        Test.startTest();
        Boolean flag = false;
        try {
            SchedulerManagerController.runOnceBatch('NonExistentClass');
        } catch(AuraHandledException e) {
            flag = true;
        }
        Test.stopTest();
        System.assert(flag);
    }
}