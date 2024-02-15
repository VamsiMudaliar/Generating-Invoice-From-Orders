/**
 * @description       : 
 * @author            : Vamsi Mudaliar
 * @group             : 
 * @last modified on  : 02-15-2024
 * @last modified by  : Vamsi Mudaliar
**/
@isTest
public with sharing class EC_SchedulerControllerTest {
        private static final String JOB_NAME = 'Invoice_Generation_Job';

        @isTest
        static void testGetScheduledProcessInfo() {
            Test.startTest();

                insert new Scheduler_Log__c(
                    Last_Run__c = System.now()
                );

                // Test when no cron trigger exists
                EC_ScheduleController.ScheduledProcessWrapper result = EC_ScheduleController.getScheduledProcessInfo();
                System.assertNotEquals(null, result, 'Result should be null when no cron trigger exists');
                
                // Test when a cron trigger exists
                result = EC_ScheduleController.getScheduledProcessInfo();
                System.assertNotEquals(null, result, 'ScheduledProcessWrapper should not be null');
                System.assertNotEquals(null, result.jobId, 'jobId should not be null');        
            Test.stopTest();
        }
    
        @isTest
        static void testToggleScheduler() {

            Test.startTest();
            // Test when no cron trigger exists
            EC_ScheduleController.toggleScheduler();
            List<CronTrigger> cronTriggerList = [SELECT Id FROM CronTrigger];
            System.assertEquals(1, cronTriggerList.size(), 'One cron trigger should be created');
            // Test when a cron trigger exists
            System.assertEquals(true, EC_ScheduleController.toggleScheduler(), 'Something Went wrong');

            Test.stopTest();
        }
}