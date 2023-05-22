@IsTest
private class InvoiceResponseHandlerTest {
    @IsTest
    static void testHandleInboundEmail(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Opportunity opp = new Opportunity(Name = 'TestOpp', 
                                            StageName = 'Prospecting', 
                                            CloseDate = date.today().addMonths(2),
                                            OwnerId = '0052w00000GM8k1AAD');
        insert opp;
        Opportunity newopp = [SELECT InvoiceNumber__c FROM Opportunity WHERE Id = :opp.Id];
        email.subject = 'Re: ' + newopp.InvoiceNumber__c;
        email.plainTextBody = 'approved';
        InvoiceResponseHandler handler = new InvoiceResponseHandler();
        handler.handleInboundEmail(email, env);
        Opportunity result = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Qualification', result.StageName);
        handler.handleInboundEmail(email, env);
        result = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Needs Analysis', result.StageName);
        email.plainTextBody = 'rejected';
        handler.handleInboundEmail(email, env);
        result = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Closed Lost', result.StageName);
    }
}