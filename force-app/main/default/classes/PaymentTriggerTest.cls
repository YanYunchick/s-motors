@IsTest
private class PaymentTriggerTest {
    @IsTest
    static void testTrigger(){
        
        Opportunity opp = new Opportunity(Name = 'TestOpp', 
                                            StageName = 'Prospecting', 
                                            CloseDate = date.today().addMonths(2),
                                            OwnerId = UserInfo.getUserId(),
                                            PaymentStatus__c = 'Not Paid',
                                            Amount = 100);
        insert opp;
        Contact cont = new Contact(LastName = 'TestContact', Email = 'test@gmail.com');
        insert cont;
        OpportunityContactRole oli = new OpportunityContactRole(OpportunityId = opp.Id, ContactId = cont.Id, IsPrimary = true);
        insert oli;
        Payment__c testpm1 = new Payment__c(OpportunityName__c = 'TestOpp', Amount__c = 50, LastName__c = 'TestLastName');
        Payment__c testpm2 = new Payment__c(OpportunityName__c = 'TestOpp', Amount__c = 50, LastName__c = 'TestLastName');
        Test.startTest();
        insert testpm1;
        Opportunity resultOpp = [SELECT PaymentStatus__c FROM Opportunity WHERE Name = :testpm1.OpportunityName__c LIMIT 1];
        System.assertEquals('Partially Paid', resultOpp.PaymentStatus__c);
        insert testpm2;
        resultOpp = [SELECT PaymentStatus__c FROM Opportunity WHERE Name = :testpm2.OpportunityName__c LIMIT 1];
        System.assertEquals('Fully Paid', resultOpp.PaymentStatus__c);
        List<Task> resultTasks = [SELECT Subject FROM Task];
        System.assert(resultTasks.size() > 0);
        Test.stopTest();
        
    }
}