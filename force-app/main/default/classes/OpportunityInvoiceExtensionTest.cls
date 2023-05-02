@IsTest
private class OpportunityInvoiceExtensionTest {
    @TestSetup
    static void setup(){
        Opportunity opp = new Opportunity(Name = 'TestOpp', 
                                            StageName = 'Prospecting', 
                                            CloseDate = date.today().addMonths(2),
                                            OwnerId = '0052w00000GM8k1AAD');
        insert opp;
        Contact cont = new Contact(LastName = 'TestContact', Email = 'test@gmail.com');
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
    @IsTest
    static void testGetEmailBody(){
        EmailTemplate et = new EmailTemplate(developerName = 'test', 
                                                FolderId = '00D2w00000RpwHoEAJ', 
                                                TemplateType= 'Text', Name = 'test', HtmlValue = 'test');
        insert et;
        System.assertEquals('test', OpportunityInvoiceExtension.getEmailBody('test'));   
    }

    @IsTest
    static void testStaticGetPrimaryContact() {
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contact cont = [SELECT Id FROM Contact WHERE LastName='TestContact' LIMIT 1];

        System.assertEquals(cont.Id, OpportunityInvoiceExtension.getPrimaryContact(opp.Id).Id);
    }
    @IsTest
    static void testGetAttachedInvoiceId() {
        Opportunity opp = [SELECT Id, OwnerId FROM Opportunity LIMIT 1];
        System.assertEquals(null, OpportunityInvoiceExtension.getAttachedInvoiceId(opp.Id));
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; 
        cv.PathOnClient = OpportunityInvoiceExtension.getInvoiceNumber(opp.Id) + '.pdf';
        cv.Origin = 'C';
        cv.OwnerId = opp.OwnerId;
        cv.Title = OpportunityInvoiceExtension.getInvoiceNumber(opp.Id) + '.pdf';
        cv.VersionData = blob.valueOf('Unit.Test');
        insert cv;
        Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cdId;
        cdl.LinkedEntityId = opp.Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        System.assertEquals(cdId, OpportunityInvoiceExtension.getAttachedInvoiceId(opp.Id));
    }
    @IsTest
    static void testThatEmailWasSent(){
        Opportunity opp = [SELECT Id, OwnerId FROM Opportunity LIMIT 1];
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; 
        cv.PathOnClient = OpportunityInvoiceExtension.getInvoiceNumber(opp.Id) + '.pdf';
        cv.Origin = 'C';
        cv.OwnerId = opp.OwnerId;
        cv.Title = OpportunityInvoiceExtension.getInvoiceNumber(opp.Id) + '.pdf';
        cv.VersionData = blob.valueOf('Unit.Test');
        insert cv;
        Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cdId;
        cdl.LinkedEntityId = opp.Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        Test.startTest();
        OpportunityInvoiceExtension.sendEmail('test', opp.Id);
 
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(1, invocations);
    }
}