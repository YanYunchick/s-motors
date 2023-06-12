public class ContactBirthdayEmailBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Name, Birthdate, Email FROM Contact WHERE Birthdate = TODAY';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Contact> scope) {
        EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate 
                                      WHERE Name = 'Birthday Template'];

        Messaging.MassEmailMessage emails = new Messaging.MassEmailMessage(); 
        List<ID> contactIds = new List<ID>((new Map<Id, Contact>(scope)).keySet());
        emails.setTargetObjectIds(contactIds);
        emails.setTemplateId(emailTemplate.Id);
        List<Messaging.SendEmailResult> mresult = Messaging.SendEmail(New Messaging.MassEmailMessage[]{emails});
        //test
        // Boolean flag = mresult[0].isSuccess();
        // System.debug('test');
    }

    public void finish(Database.BatchableContext BC) {
        Integer emailsCount = [SELECT count() FROM EmailMessage]; 
        System.debug(emailsCount);
    }
}