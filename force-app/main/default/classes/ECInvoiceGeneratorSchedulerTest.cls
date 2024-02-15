/**
 * @description       : 
 * @author            : Vamsi Mudaliar
 * @group             : 
 * @last modified on  : 02-15-2024
 * @last modified by  : Vamsi Mudaliar
**/
@isTest
public with sharing class ECInvoiceGeneratorSchedulerTest {

    // Helper method to create test data
    private static void createTestData() {
        Account acc = new Account(Name='Expedite Commerce');
        insert acc;

        Product2 product1 = new Product2(
                Name = 'Product 1'
                // Add other required fields
        );
        insert product1;

        // Add the product to the standard price book
        PricebookEntry pricebookEntry1 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product1.Id,
            UnitPrice = 100, // Example price
            IsActive = true
        );
        insert pricebookEntry1;
    
        // Create another sample product
        Product2 product2 = new Product2(
            Name = 'Product 2'
            // Add other required fields
        );
        insert product2;
        // Add the product to the standard price book
        PricebookEntry pricebookEntry2 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product2.Id,
            UnitPrice = 200, // Example price
            IsActive = true
        );
        insert pricebookEntry2;

        // Create a sample activated order created today
        Order activatedOrder = new Order(
            Status = 'Draft',
            AccountId = acc.Id,
            EffectiveDate = Date.today().addDays(2),
            Pricebook2Id = Test.getStandardPricebookId()
            // Add other required fields
        );
        insert activatedOrder;

        List<OrderItem> orderItems = new List<OrderItem>{
            new OrderItem(
                OrderId = activatedOrder.Id,
                Product2Id = product1.Id,
                Quantity = 1,
                UnitPrice = 100, // Example price
                PricebookEntryId = pricebookEntry1.Id
                // Add other required fields
            ),
            new OrderItem(
                OrderId = activatedOrder.Id,
                Product2Id = product2.Id,
                Quantity = 1,
                UnitPrice = 200, // Example price
                PricebookEntryId = pricebookEntry2.Id
                // Add other required fields
            )
        };
        insert orderItems;
        activatedOrder.Status = 'Activated';
        update activatedOrder;
    }

    @isTest
    static void testExecute() {
        // Create test data
        createTestData();

        // Start test
        Test.startTest();

        // Schedule job
        ECInvoiceGeneratorScheduler.scheduleInvoiceGeneration();

        // Stop test to allow async processing
        Test.stopTest();
    }

    @isTest
    static void testScheduleInvoiceGeneration() {
        Test.startTest();
        ECInvoiceGeneratorScheduler.scheduleInvoiceGeneration();
        Test.stopTest();

        // Verify job is scheduled
        CronTrigger cronTrigger = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'Invoice_Generation_Job' LIMIT 1];
        System.assertNotEquals(null, cronTrigger, 'Job should be scheduled');
    }

    @isTest
    static void testUpdateSchedulerLog() {
        // Create test data
        Scheduler_Log__c log = new Scheduler_Log__c(Job_Name__c='Invoice_Generation_Job');
        insert log;

        // Update scheduler log
        Test.startTest();
        ECInvoiceGeneratorScheduler.updateSchedulerLog();
        Test.stopTest();

        // Verify log is updated
        log = [SELECT Id, Last_Run__c FROM Scheduler_Log__c WHERE Job_Name__c = 'Invoice_Generation_Job' LIMIT 1];
        System.assertNotEquals(null, log, 'Scheduler log should exist');
        System.assertNotEquals(null, log.Last_Run__c, 'Last run should be updated');
    }
}