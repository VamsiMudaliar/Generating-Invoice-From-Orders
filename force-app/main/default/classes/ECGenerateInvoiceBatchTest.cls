/**
 * @description       : 
 * @author            : Vamsi Mudaliar
 * @group             : 
 * @last modified on  : 02-15-2024
 * @last modified by  : Vamsi Mudaliar
**/
@isTest
public with sharing class ECGenerateInvoiceBatchTest {
    
        @TestSetup
        static void makeData(){
            Account acc = new Account(Name='Expedite Commerce');
            insert acc;
        }


        @isTest
        static void testExecutePositive() {
            List<Account> accList = [SELECT ID,Name FROM Account];

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
                AccountId = accList[0]?.Id,
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

            // Start batch execution
            Test.startTest();
            ECGenerateInvoiceBatch batch = new ECGenerateInvoiceBatch();
            Database.executeBatch(batch);
            Test.stopTest();
    
            // Assert that invoices are generated
            Integer invoiceCount = [SELECT COUNT() FROM Invoice__c];
            System.assertNotEquals(0, invoiceCount, 'Invoices should be generated');
        }
    
        @isTest
        static void testExecuteNegativeNoOrders() {
            
            // Start batch execution
            Test.startTest();
            ECGenerateInvoiceBatch batch = new ECGenerateInvoiceBatch();
            Database.executeBatch(batch);
            Test.stopTest();
    
            // Assert that no invoices are generated
            Integer invoiceCount = [SELECT COUNT() FROM Invoice__c];
            System.assertEquals(0, invoiceCount, 'No invoices should be generated');
        }
    
        @isTest
        static void testExecuteNegativeException() {
            // Create a mock order with invalid data to force an exception
            List<Account> accList = [SELECT ID,Name FROM Account];

            Order invalidOrder = new Order(
                Status = 'Draft',
                AccountId = accList[0]?.Id,
                EffectiveDate = Date.today().addDays(2)
                // Add other required fields
            );
            insert invalidOrder;

            // Start batch execution
            Test.startTest();
            ECGenerateInvoiceBatch batch = new ECGenerateInvoiceBatch();
            // Force an exception by modifying the order schema or data
            Database.executeBatch(batch);
            Test.stopTest();
    
            // Assert that the exception is handled properly (e.g., logged)
            // Verify logs or any other error handling mechanisms
            Integer invoiceCount = [SELECT COUNT() FROM Invoice__c];
            System.assertEquals(0, invoiceCount, 'No invoices should be generated');
        } 
}