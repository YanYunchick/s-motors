@IsTest
private class OpportunityInvoiceExtensionTest {
    @TestSetup
    static void setup(){
        Opportunity opp = new Opportunity(Name = 'TestOpp', 
                                            StageName = 'Prospecting', 
                                            CloseDate = date.today().addMonths(2));
        insert opp;
        Contact cont = new Contact(LastName = 'TestContact');
        insert cont;
        OpportunityContactRole oli = new OpportunityContactRole(OpportunityId = opp.Id, ContactId = cont.Id, IsPrimary = true);
        insert oli;
    }
    @IsTest
    static void testGetPrimaryContact() {
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contact cont = [SELECT Id FROM Contact WHERE LastName='TestContact' LIMIT 1];
        Test.startTest();
        PageReference testPage = Page.Invoice;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(opp.Id));
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(opp);     
        OpportunityInvoiceExtension ext = new OpportunityInvoiceExtension(sc);

        System.assertEquals(cont.Id, ext.getPrimaryContact().Id);
        Test.stopTest();
    }

    @IsTest
    static void testAttachPDF() {

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        PageReference testPage = Page.Invoice;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(opp.Id));
        ApexPages.StandardController sc = new  ApexPages.StandardController(opp);     
        OpportunityInvoiceExtension ext = new OpportunityInvoiceExtension(sc);

        ext.attachPDF();
        List<ContentVersion> listversion = [SELECT contentDocumentId, contentDocument.title 
                                            FROM ContentVersion];
        System.assert(listversion.size() == 1);
        ext.attachPDF();
        listversion = [SELECT contentDocumentId, contentDocument.title 
                       FROM ContentVersion];
        System.assert(listversion.size() == 2);
    }
    @IsTest
    static void testCancel(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        PageReference testPage = Page.Invoice;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(opp.Id));
        ApexPages.StandardController sc = new  ApexPages.StandardController(opp);     
        OpportunityInvoiceExtension ext = new OpportunityInvoiceExtension(sc);
        Pagereference pref = ext.cancel();
        Test.stopTest();
        Assert.isNotNull(pref);
    }
}