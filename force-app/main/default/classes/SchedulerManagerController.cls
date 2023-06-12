public with sharing class SchedulerManagerController {
    public static ID jobID;
    public static Object createInstance(String className) {
        Type classType = Type.forName(className);
        Object instance = null;
        if (classType != null) {
            instance = classType.newInstance();
        }
        return instance;
    }
    @AuraEnabled
    public static void runOnceBatch(string batchName){
        try {
            Database.executeBatch((Database.Batchable<sObject>)createInstance(batchName), 2);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Id scheduleBatch(String schedulerName, String cronString, String jobName){
        try {
            jobID = System.schedule(jobName, cronString, (Schedulable)createInstance(schedulerName));
            return jobID;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void abortBatch(String abortedJob){
        try {
            System.abortJob(abortedJob);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Id getJobState(String jobName){
        try {
            jobID = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName LIMIT 1]?.Id;
            return jobID;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}