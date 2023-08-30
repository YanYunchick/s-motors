@IsTest
private class OpportunityWorkspaceControllerTest {
    @TestSetup
    static void setup(){
        Account acc = new Account(Name = 'TestAcc', UndeletableByCascade__c = true);
        insert acc;
        Opportunity opp = new Opportunity(Name = 'TestOpp', 
                                            StageName = 'Prospecting', 
                                            CloseDate = date.today().addMonths(2),
                                            OwnerId = UserInfo.getUserId(),
                                            AccountId = acc.Id);
        insert opp;
        Contact cont = new Contact(LastName = 'TestContact', Email = 'test@gmail.com', AccountId = acc.Id, UndeletableByCascade__c = true);
        insert cont;
        OpportunityContactRole oli = new OpportunityContactRole(OpportunityId = opp.Id, ContactId = cont.Id, IsPrimary = true);
        insert oli;
    }

    @IsTest
    static void searchTest(){
        Test.startTest();
        List<Opportunity> result = OpportunityWorkspaceController.searchOpportunities('Test');
        Test.stopTest();
        System.assert(result.size() > 0);
    }

    @IsTest
    static void retrieveSearchDataTest(){
        Test.startTest();
        List<Contact> result = OpportunityWorkspaceController.retrieveSearchData('Contact', 'Id', 'Test', new List<String>(), null);
        Test.stopTest();
        System.assert(result.size() > 0);
    }

    @IsTest
    static void saveSharingTest(){

        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'TestOpp'];
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='standardusertest123123@testorg.com');
        insert u;
        Test.startTest();
        List<Id> addedUsers = new List<Id>();
        addedUsers.add(u.Id);
        OpportunityWorkspaceController.saveSharing(opp.Id, addedUsers, new List<Id>());
        List<User> usersResult = OpportunityWorkspaceController.getSharedUsers(opp.Id);
        Test.stopTest();
        OpportunityShare os = [SELECT UserOrGroupId, OpportunityId FROM OpportunityShare LIMIT 1];
        System.assertEquals(opp.Id, os.OpportunityId);
        System.assertEquals(usersResult.size(), 1);
    }

    @IsTest
    static void recordsTest(){
        Test.startTest();
        List<Opportunity> oppResult = OpportunityWorkspaceController.getOpportunityList();
        List<Contact> conResult = OpportunityWorkspaceController.getUndeletableContacts();
        List<Account> accResult = OpportunityWorkspaceController.getUndeletableAccounts();
        System.assert(oppResult.size() > 0);
        System.assert(conResult.size() > 0);
        System.assert(accResult.size() > 0);
        OpportunityWorkspaceController.removeFromUndeletableAccount(accResult[0].Id);
        OpportunityWorkspaceController.removeFromUndeletableContact(conResult[0].Id);
        List<Account> afterRemoveAcc = [SELECT Id FROM Account WHERE UndeletableByCascade__c = false];
        List<Contact> afterRemoveCon = [SELECT Id FROM Contact WHERE UndeletableByCascade__c = false];
        System.assert(afterRemoveAcc.size() > 0);
        System.assert(afterRemoveCon.size() > 0);
        List<Id> updatedAcc = new List<Id>();
        updatedAcc.add(afterRemoveAcc[0].Id);
        List<Id> updatedCon = new List<Id>();
        updatedCon.add(afterRemoveCon[0].Id);
        OpportunityWorkspaceController.saveAddedUndeletableAccounts(updatedAcc);
        OpportunityWorkspaceController.saveAddedUndeletableContacts(updatedCon);
        List<Account> afterUpdateAcc = [SELECT Id FROM Account WHERE UndeletableByCascade__c = true];
        List<Contact> afterUpdateCon = [SELECT Id FROM Contact WHERE UndeletableByCascade__c = true];
        System.assert(afterUpdateAcc.size() > 0);
        System.assert(afterUpdateCon.size() > 0);
        Test.stopTest();
    }

    @IsTest
    static void deleteOppsTest(){
        List<Opportunity> deletedOpps = [SELECT Id FROM Opportunity];
        Test.startTest();
        OpportunityWorkspaceController.deleteSelectedOpportunities(deletedOpps);
        Test.stopTest();
        List<Opportunity> result = [SELECT Id FROM Opportunity];
        System.assert(result.size() == 0);
    }    
}