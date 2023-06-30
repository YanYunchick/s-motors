public class BatchScheduler implements Schedulable {

    public void execute(SchedulableContext SC) {
        ContactBirthdayEmailBatch bc = new ContactBirthdayEmailBatch();
        Database.executeBatch(bc, 2);
    }
}