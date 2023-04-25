public with sharing class OpportunityInvoiceExtension {

    public final Id oppId { get; set; }
    private final Opportunity opp;

    public OpportunityInvoiceExtension(ApexPages.StandardController stdController) {
        this.oppId = ApexPages.currentPage().getParameters().get('Id');
        this.opp = [SELECT InvoiceNumber__c, OwnerId FROM Opportunity WHERE Id = :oppId];
    }

    public ID getPrimaryContactId() {
        OpportunityContactRole ocr = [
            SELECT Id, ContactId
            FROM OpportunityContactRole 
            WHERE (isPrimary=True 
            AND OpportunityId = :oppId)
            WITH SECURITY_ENFORCED
            LIMIT 1
       ];
        return ocr.ContactId;
    }

    public Contact getPrimaryContact() {
        Id conId = getPrimaryContactId();
        return [
            SELECT Name, Phone, Email 
            FROM Contact 
            WHERE Id = :conId 
            WITH SECURITY_ENFORCED
            LIMIT 1
       ];
    }

    public void attachPDF() {

        PageReference pref  = Page.Invoice;
        pref.getParameters().put('id', oppId);
        Blob bdata;
        if(Test.isRunningTest()) { 
            bdata = blob.valueOf('Unit.Test');
          } else {
            bdata = pref.getContentAsPDF();
        }
        String docName = opp.InvoiceNumber__c + '.pdf';
        List<ContentVersion> listversion = [SELECT contentDocumentId, contentDocument.title 
                                            FROM ContentVersion 
                                            WHERE ContentDocument.title = :docName];
        System.debug('listversion : ' + listversion);

        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; 
        cv.PathOnClient = docName;
        cv.Origin = 'C';
        cv.OwnerId = opp.OwnerId;
        cv.Title = docName;
        cv.VersionData = bdata;

        if (!listversion.isEmpty()) {
            cv.ContentDocumentId= listversion[0].ContentDocumentId;
        }
        insert cv;
        if (listversion.isEmpty()) {

            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = conDocId;
            cdl.LinkedEntityId = oppId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
        }
    }

    public PageReference cancel()
    {
        PageReference Pdf = new PageReference('/'+oppId);
        Pdf.setredirect(True);
        return Pdf;
    }
}