/**
 * @description       : This method will be used to schedule the Apex Job, and will run at midnight everyday.
 * @author            : Vamsi Mudaliar
 * @group             : 
 * @last modified on  : 02-14-2024
 * @last modified by  : Vamsi Mudaliar
**/
public with sharing class ECInvoiceGeneratorScheduler implements Schedulable {
    

    private static final String JOB_NAME = 'Invoice_Generation_Job';
    private static final String CRON_EXP = '0 0 0 * * ?'; // Run at midnight every day

    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new ECGenerateInvoiceBatch());
        // Update Scheduler_Log__c record to update the LAST RUN.
        updateSchedulerLog();
    }

    // This method will be used to run the Scheduler.
    public static void scheduleInvoiceGeneration() {
        // Schedule the job
        System.schedule(JOB_NAME, CRON_EXP, new ECInvoiceGeneratorScheduler());
    }

    public static void updateSchedulerLog() {
        List<Scheduler_Log__c> logsToUpdate = [SELECT Id, Last_Run__c FROM Scheduler_Log__c WHERE Job_Name__c = :JOB_NAME LIMIT 1];

        if (!logsToUpdate.isEmpty()) {
            logsToUpdate[0].Last_Run__c = DateTime.now();
            update logsToUpdate;
        } else {
            Scheduler_Log__c newLog = new Scheduler_Log__c();
            newLog.Job_Name__c = JOB_NAME;
            newLog.Last_Run__c = DateTime.now();
            insert newLog;
        }
    }
}