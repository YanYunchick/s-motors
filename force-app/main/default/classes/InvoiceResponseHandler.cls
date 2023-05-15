global class InvoiceResponseHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env ) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String subject = '';
        subject = email.subject;
        System.debug('subject:' + subject);
        String responseText = '';
        responseText = email.plainTextBody;
        System.debug('text:' + responseText);
        try {
            if(subject.startsWith('INV-') || subject.startsWith('Re: INV-')) {
                if(subject.startsWith('Re: INV-')) {
                    subject = subject.substring(4);
                }
                Opportunity opp = [SELECT StageName FROM Opportunity WHERE InvoiceNumber__c = :subject];
                responseText = responseText.toLowerCase();
                if(responseText.contains('approved') && opp.StageName == 'Prospecting') {
                    opp.StageName = 'Qualification';
                    update opp;
                }else if(responseText.contains('rejected')){
                    opp.StageName = 'Closed Lost';
                    update opp;
                }               
            }                                             
        } catch (System.QueryException e) {
            System.debug('Opportunity Query Issue: ' + e);
        }  
        result.success = true;   
        return result;
    } 
}