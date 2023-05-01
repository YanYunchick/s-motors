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

    public PageReference attachPDF() {

        PageReference pref  = Page.Invoice;
        pref.getParameters().put('id', oppId);
        Blob bdata;
        if(Test.isRunningTest()) { 
            bdata = blob.valueOf('Unit.Test');
          } else {
            bdata = pref.getContentAsPDF();
        }
        String docName = opp.InvoiceNumber__c + '.pdf';
        ContentVersion attachedFile = getAttachedInvoice(oppId);
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; 
        cv.PathOnClient = docName;
        cv.Origin = 'C';
        cv.OwnerId = opp.OwnerId;
        cv.Title = docName;
        cv.VersionData = bdata;

        if (attachedFile != null) {
            cv.ContentDocumentId= attachedFile.ContentDocumentId;
        }
        insert cv;
        if (attachedFile == null) {

            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = conDocId;
            cdl.LinkedEntityId = oppId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
        }
        return cancel();
    }

    public PageReference cancel() {
        PageReference Pdf = new PageReference('/'+oppId);
        Pdf.setredirect(True);
        return Pdf;
    }

    public static String getInvoiceNumber(String recordId){
        return [SELECT InvoiceNumber__c FROM Opportunity WHERE Id = :recordId].InvoiceNumber__c;
    }

    @AuraEnabled(cacheable=true)
    public static String getEmailBody(){
        return [SELECT HtmlValue
                FROM EmailTemplate WHERE Name = 'Invoice Email Template'].HtmlValue;
    }

    @AuraEnabled(cacheable=true)
    public static Contact getPrimaryContact(String recordId){
        OpportunityContactRole ocr = [
            SELECT Id, ContactId
            FROM OpportunityContactRole 
            WHERE (isPrimary=True 
            AND OpportunityId = :recordId)
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return [SELECT Email, Name FROM Contact WHERE Id = :ocr.ContactId LIMIT 1];
    }

    @AuraEnabled(cacheable=true)
    public static String getAttachedInvoiceId(String recordId){
        ContentVersion attachedFile = getAttachedInvoice(recordId);
        return attachedFile == null ? null : attachedFile.ContentDocumentId;
    }

    @AuraEnabled
    public static void sendEmail(String emailBody, String recordId){
        Messaging.reserveSingleEmailCapacity(1);
        try {
            messaging.SingleEmailMessage mail = new messaging.SingleEmailMessage();
            Messaging.EmailFileAttachment attachedInvoice = new Messaging.EmailFileAttachment();
            ContentVersion attachedFile = getAttachedInvoice(recordId);
            if(attachedFile != null) {
                attachedInvoice.setBody(attachedFile.VersionData);
                attachedInvoice.setFileName('Invoice.pdf');
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachedInvoice});
            }
            mail.setToAddresses(new String[]{'ganakine911@gmail.com'});
            mail.setReplyTo('yan.yunchick@gmail.com');
            mail.setSenderDisplayName('SuccessMotors');
            mail.setSubject(getInvoiceNumber(recordId));
            mail.setHtmlBody(emailBody);
            Messaging.sendEmail(new List<messaging.SingleEmailMessage>{ mail });
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static ContentVersion getAttachedInvoice(String recordId) {
        String docName = getInvoiceNumber(recordId) + '.pdf';
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        List<ContentVersion> cv = [SELECT VersionData, ContentDocumentId, ContentDocument.Title
                                    FROM ContentVersion 
                                    WHERE ContentDocumentId IN :fileIDs 
                                    AND ContentDocument.Title = :docName LIMIT 1];
        if(cv.IsEmpty()) {
            return null;
        }
        return cv[0];
    }
}