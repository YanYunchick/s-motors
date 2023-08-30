trigger OpportunityTrigger on Opportunity (before delete) {
    Set<Id> opportunityIds = Trigger.oldMap.keySet();
    List<Contact> deleteCons = [SELECT Id FROM Contact WHERE Id IN 
                                (SELECT ContactId FROM OpportunityContactRole 
                                WHERE OpportunityId IN :opportunityIds) 
                                AND UndeletableByCascade__c = false];
    List<Id> deleteAccIds = new List<Id>();
    List<Account> undeletableAccs = [SELECT Id FROM Account WHERE UndeletableByCascade__c = true];

    for(Opportunity opp : Trigger.old) {
        deleteAccIds.add(opp.AccountId);
    }

    List<Account> deleteAccs = [SELECT Id FROM Account WHERE Id IN :deleteAccIds AND Id NOT IN :undeletableAccs];

    List<Case> deleteCases = [SELECT Id FROM Case WHERE AccountId IN :deleteAccs OR ContactId IN :deleteCons];
    List<Opportunity> unassignedOpps = [SELECT Id FROM Opportunity 
                                        WHERE AccountId IN :deleteAccs];
    for(Opportunity opp : unassignedOpps) {
        opp.AccountId = null;
    }
    List<Contact> undeletableCons = [SELECT Id, AccountId FROM Contact WHERE AccountId IN :deleteAccs AND UndeletableByCascade__c = true];
    for(Contact con : undeletableCons) {
        con.AccountId = null;
    }
    // for(Contact con : deleteCons) {
    //     con.AccountId = null;
    // }
    update undeletableCons;
    update unassignedOpps;
    delete deleteCases;
    delete deleteCons;
    delete deleteAccs;

}