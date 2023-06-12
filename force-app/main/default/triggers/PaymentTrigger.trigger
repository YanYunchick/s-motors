trigger PaymentTrigger on Payment__c (after insert) {
    Set<String> opportunityNames = new Set<String>();
    List<Task> tasks = new List<Task>();

    for(Payment__c paymentItem : Trigger.new) {
        opportunityNames.add(paymentItem.OpportunityName__c);
    }

    Map<String, Decimal> mapPayments = new Map<String, Decimal>();
    for(String opportunityName : OpportunityNames) {
        mapPayments.put(opportunityName, 0);
    }

    for(Payment__c paymentItem : [SELECT Amount__c, OpportunityName__c 
                                  FROM Payment__c WHERE OpportunityName__c IN :opportunityNames]) {
        mapPayments.put(paymentItem.OpportunityName__c, mapPayments.get(paymentItem.OpportunityName__c) + paymentItem.Amount__c);
    }

    List<Opportunity> opportunities = [SELECT Name, PaymentStatus__c, Amount, 
                                        (SELECT Contact.OwnerId FROM OpportunityContactRoles WHERE IsPrimary = true LIMIT 1) 
                                        FROM Opportunity 
                                        WHERE Name IN :opportunityNames AND PaymentStatus__c != 'Fully Paid'];

    for(Opportunity opp : opportunities) {
        if(opp.Amount > mapPayments.get(opp.Name)) {
            opp.PaymentStatus__c = 'Partially Paid';
        } else if(opp.Amount <= mapPayments.get(opp.Name)){
            opp.PaymentStatus__c = 'Fully Paid';
            if(opp.OpportunityContactRoles.size() > 0) {
                tasks.add(new Task(OwnerId = opp.OpportunityContactRoles[0].Contact.OwnerId,
                Priority = 'High',
                Status = 'Not Started',
                Subject = 'Delivery of goods',
                IsReminderSet = true,
                ReminderDateTime = DateTime.newInstance(System.today().addDays(2).year(),
                                                         System.today().addDays(2).month(),
                                                         System.today().addDays(2).day(),
                                                         10, 0, 0)));
            }
        }
    }

    update opportunities;
    insert tasks;
}