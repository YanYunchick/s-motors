global class InvoiceResponseHandler implements Messaging.InboundEmailHandler {
    global List<String> OpportunityStages = new List<String> {'Prospecting', 'Qualification', 'Needs Analysis',
                                                        'Value Proposition', 'Id. Decision Makers',
                                                        'Perception Analysis', 'Proposal/Price Quote',
                                                        'Negotiation/Review', 'Closed Won'};
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
                if(responseText.contains('approved') && opp.StageName != 'Closed Won') {
                    opp.StageName = OpportunityStages[OpportunityStages.indexOf(opp.StageName) + 1];
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