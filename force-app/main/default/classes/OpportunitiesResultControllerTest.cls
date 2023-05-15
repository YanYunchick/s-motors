@IsTest
private class OpportunitiesResultControllerTest {
    @TestSetup
    static void setup(){
        Account acc1 = new Account(Name = 'TestAcc1');
        insert acc1;
        Account acc2 = new Account(Name = 'TestAcc2');
        insert acc2;
        Opportunity opp = new Opportunity(Name = 'TestOpp', 
                                            StageName = 'Closed Won', 
                                            CloseDate = date.today().addMonths(2),
                                            Amount = 123,
                                            AccountId = acc1.Id);
        insert opp;
        
    }
    @IsTest
    static void testSearchAccounts(){
        System.assert(OpportunitiesResultController.searchAccounts('').size() == 2);
        System.assert(OpportunitiesResultController.searchAccounts('TestAcc2').size() == 1);
        System.assert(OpportunitiesResultController.searchAccounts('100').size() == 1);
        System.assert(OpportunitiesResultController.searchAccounts('1000').size() == 0);   
    }
    @IsTest
    static void testGetAccount(){
        Account acc = [SELECT Name FROM Account WHERE Name = 'TestAcc1'];
        Map<String, List<Opportunity>> resultMap = OpportunitiesResultController.getAccount(acc.Id);
        System.assert(resultMap.containsKey('TestAcc1 $123.00'));
    }
    @IsTest
    static void testGetOpprtunityProducts(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'TestOpp'];
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X',
            isActive = true
        );
        insert prod;

        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = 5 * pbEntry.UnitPrice
        );
        insert oli;
        System.assert(OpportunitiesResultController.getOpportunityProducts(opp.Id).size() == 1);
    }
}