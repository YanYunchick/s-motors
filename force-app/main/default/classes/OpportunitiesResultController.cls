public with sharing class OpportunitiesResultController {
    static Pattern decimalPattern = Pattern.compile('^[-+]?\\d+(\\.\\d*)?$');

    public static Map<String, List<Opportunity>> getAllAccounts() {
        Map<String, List<Opportunity>> result = new Map<String, List<Opportunity>>();
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : [SELECT Name, ClosedWonOpportunitySum__c
                            FROM Account
                            WITH SECURITY_ENFORCED
                            ORDER BY ClosedWonOpportunitySum__c DESC]) {
            accountIds.add(acc.Id);
            result.put(acc.Name + ' $' + acc.ClosedWonOpportunitySum__c.setScale(2), new List<Opportunity>());
        }
        
        List<Opportunity> opportunities = [SELECT Name, CreatedDate, CloseDate, Amount, Account.Name, Account.ClosedWonOpportunitySum__c
                                           FROM Opportunity
                                           WHERE StageName = 'Closed Won'
                                           AND AccountId IN :accountIds
                                           WITH SECURITY_ENFORCED];
        
        for (Opportunity opp : opportunities) {
            result.get(opp.Account.Name + ' $' + opp.Account.ClosedWonOpportunitySum__c).add(opp);
        }
        
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, List<Opportunity>> searchAccounts(String searchTerm) {
        searchTerm = searchTerm.trim();
        if (searchTerm == '') {
            return getAllAccounts();
        }
        
        Map<String, List<Opportunity>> result = new Map<String, List<Opportunity>>();
        List<Account> accs = new List<Account>();
        Set<Id> accountIds = new Set<Id>();
        
        if (!decimalPattern.matcher(searchTerm).find()) {
            searchTerm = '%' + searchTerm + '%';
            accs = [SELECT Name, ClosedWonOpportunitySum__c
                    FROM Account WHERE Name LIKE :searchTerm
                    WITH SECURITY_ENFORCED
                    ORDER BY ClosedWonOpportunitySum__c DESC];
        } else {
            Decimal sum = Decimal.valueOf(searchTerm);
            accs = [SELECT Name, ClosedWonOpportunitySum__c
                    FROM Account WHERE ClosedWonOpportunitySum__c >= :sum
                    WITH SECURITY_ENFORCED
                    ORDER BY ClosedWonOpportunitySum__c DESC];
        }
        
        for (Account acc : accs) {
            accountIds.add(acc.Id);
            result.put(acc.Name + ' $' + acc.ClosedWonOpportunitySum__c.setScale(2), new List<Opportunity>());
        }
        
        List<Opportunity> opportunities = [SELECT Name, CreatedDate, CloseDate, Amount, Account.Name, Account.ClosedWonOpportunitySum__c
                                           FROM Opportunity
                                           WHERE StageName = 'Closed Won'
                                           AND AccountId IN :accountIds
                                           WITH SECURITY_ENFORCED];
        
        for (Opportunity opp : opportunities) {
            result.get(opp.Account.Name + ' $' + opp.Account.ClosedWonOpportunitySum__c).add(opp);
        }
        
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, List<Opportunity>> getAccount(Id accId) {
        Map<String, List<Opportunity>> result = new Map<String, List<Opportunity>>();
        Account acc = [SELECT Name, ClosedWonOpportunitySum__c FROM Account WHERE Id = :accId];
        result.put(acc.Name + ' $' + acc.ClosedWonOpportunitySum__c.setScale(2), 
                        [SELECT Name, CreatedDate, CloseDate, Amount 
                        FROM Opportunity 
                        WHERE StageName = 'Closed Won' 
                        AND AccountId = :acc.Id
                        WITH SECURITY_ENFORCED]);
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItem> getOpportunityProducts(Id oppId){
        return [SELECT Id, Name, Quantity, TotalPrice FROM OpportunityLineItem 
                WHERE OpportunityId = :oppId WITH SECURITY_ENFORCED];
    }
}