/**
 * @description       : 
 * @author            : Vamsi Mudaliar
 * @group             : 
 * @last modified on  : 02-15-2024
 * @last modified by  : Vamsi Mudaliar
**/
public with sharing class EC_ScheduleController {
    
    private static final String JOB_NAME = 'Invoice_Generation_Job';

    public class ScheduledProcessWrapper {
        @AuraEnabled
        public Boolean isScheduled;
        @AuraEnabled 
        public String jobId;
        @AuraEnabled 
        public String lastRunInfo;
    }



    @AuraEnabled(cacheable=true)
    public static ScheduledProcessWrapper getScheduledProcessInfo() {
        try {
            ScheduledProcessWrapper res = new ScheduledProcessWrapper();

            List<CronTrigger> cronTriggerList = [SELECT Id,CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name =:JOB_NAME LIMIT 1];
            res.isScheduled = !cronTriggerList.isEmpty();
            if(!cronTriggerList.isEmpty()) {
               res.jobId =  cronTriggerList[0].Id;
            }
            // Query for Scheduler.
            List<Scheduler_Log__c> schedulerLogList = [SELECT ID,Last_Run__c FROM Scheduler_Log__c ORDER BY CreatedDate DESC LIMIT 1];
            if(!schedulerLogList.isEmpty()) {
                res.lastRunInfo = schedulerLogList[0].Last_Run__c?.format();
            }
            return res;
        }
        catch(Exception ex) {
            ECExceptionManager.logException('EC_ScheduleController', 'getScheduledProcessInfo', ex);
        }
        return null;
    }

    @AuraEnabled
    public static Boolean toggleScheduler() {
        try {
            List<CronTrigger> cronTriggerList = [SELECT Id,CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name =:JOB_NAME LIMIT 1];

            if(cronTriggerList.isEmpty()) {
                ECInvoiceGeneratorScheduler.scheduleInvoiceGeneration();
            } else {
                System.abortJob(cronTriggerList[0]?.Id);
            }
            return true;
        }
        catch(Exception ex) {
            ECExceptionManager.logException('EC_ScheduleController', 'getScheduledProcessInfo', ex);
        }
        return false;
    }

}