public with sharing class OpportunityWorkspaceController {
    @AuraEnabled
    public static List<Opportunity> searchOpportunities(String searchTerm){
        try {
            searchTerm = '%' + searchTerm + '%';
            List<Opportunity> opps = [SELECT Name, CreatedDate, CloseDate, Amount, StageName 
                                        FROM Opportunity WHERE Name LIKE :searchTerm 
                                        WITH SECURITY_ENFORCED ORDER BY Name];
            return opps;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<sObject> retrieveSearchData(String ObjectName, String fieldName, String value, List<String> selectedRecId, String params) {
        List<sObject> sObjectResultList = new List<sObject>();
        if(selectedRecId == null)
            selectedRecId = new List<String>();

        if(params == null || params.trim() == '') {
            params = '';
        } else {
            params = ' AND ' + params;
        }
        if(String.isNotEmpty(value)) {
            String query = 'Select '+fieldName+' FROM '+ObjectName+' WHERE Name LIKE \'%' + value.trim() + '%\' ' + params + ' AND ID NOT IN :selectedRecId ORDER BY createdDate DESC LIMIT 5';
            for(sObject so : Database.Query(query)) {
                sObjectResultList.add(so);
            }
        }
        return sObjectResultList;
    }
    
    @AuraEnabled
    public static void saveSharing(Id oppId, List<Id> addedUsers, List<Id> removedUsers) {
        try {
            List<OpportunityShare> oppShares = new List<OpportunityShare>();
            for(Id userId : addedUsers) {
                oppShares.add(new OpportunityShare(OpportunityId = oppId, 
                                                    UserOrGroupId = userId, 
                                                    OpportunityAccessLevel = 'Edit', 
                                                    RowCause = Schema.OpportunityShare.RowCause.Manual));
            }
            List<OpportunityShare> removedShares = [SELECT Id FROM OpportunityShare WHERE UserOrGroupId IN :removedUsers];
            if(removedShares.size() != 0) {
                delete removedShares;
            }
            insert oppShares;


        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<User> getSharedUsers(Id oppId){
        try {
            List<User> sharedUsers = [SELECT Name FROM User WHERE Id IN 
                                        (SELECT UserOrGroupId FROM OpportunityShare 
                                        WHERE OpportunityId = :oppId AND OpportunityAccessLevel = 'Edit')
                                        AND IsActive = true];
            return sharedUsers;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Opportunity> getOpportunityList(){
        try {
            return [SELECT Name, Amount FROM Opportunity];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Contact> getUndeletableContacts() {
        try {
            return [SELECT Name, CreatedDate FROM Contact WHERE UndeletableByCascade__c = true];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Account> getUndeletableAccounts() {
        try {
            return [SELECT Name, CreatedDate FROM Account WHERE UndeletableByCascade__c = true];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void saveAddedUndeletableContacts(List<Id> updatedContactIds){
        try {
            List<Contact> cons = [SELECT Id, UndeletableByCascade__c FROM Contact WHERE Id IN :updatedContactIds];
            for (Contact con: cons) {
                con.UndeletableByCascade__c = true;
            }
            update cons;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void saveAddedUndeletableAccounts(List<Id> updatedAccountIds){
        try {
            List<Account> accs = [SELECT Id, UndeletableByCascade__c FROM Account WHERE Id IN :updatedAccountIds];
            for (Account acc: accs) {
                acc.UndeletableByCascade__c = true;
            }
            update accs;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void removeFromUndeletableContact(Id contactId){
        try {
            Contact con = [SELECT UndeletableByCascade__c FROM Contact WHERE Id = :contactId];
            con.UndeletableByCascade__c = false;
            update con;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void removeFromUndeletableAccount(Id accountId){
        try {
            Account acc = [SELECT UndeletableByCascade__c FROM Account WHERE Id = :accountId];
            acc.UndeletableByCascade__c = false;
            update acc;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteSelectedOpportunities(List<Opportunity> deletedOpps){
        try {
            delete deletedOpps;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}