public class BatchScheduler implements Schedulable {
    // public String batchName;
    // public Integer scopeSize;
    // public ContactBirthdayEmailScheduler(String newBatchName, Integer newScoreSize) {
    //     batchName = newBatchName;
    //     scopeSize = newScoreSize;
    // }
    // public void execute(SchedulableContext SC) {
    //     Database.executeBatch((Database.Batchable<sObject>)SchedulerManagerController.createInstance(batchName), scopeSize);
    // }
    public void execute(SchedulableContext SC) {
        ContactBirthdayEmailBatch bc = new ContactBirthdayEmailBatch();
        Database.executeBatch(bc, 2);
    }
}