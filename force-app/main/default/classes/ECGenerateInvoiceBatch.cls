/**
 * @description       : This Apex Class Generate Invoices for the Activated Orders Created Today.
 * @author            : Vamsi Mudaliar
 * @group             : 
 * @last modified on  : 02-15-2024
 * @last modified by  : Vamsi Mudaliar
**/
global with sharing class ECGenerateInvoiceBatch implements Database.Batchable<sObject> {
    
    private static String ACTIVATED = 'Activated';
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, OrderNumber, (SELECT Id,OrderId, Product2Id, Quantity, TotalPrice FROM OrderItems) FROM Order WHERE Status =\''+ ACTIVATED +'\' AND ActivatedDate = TODAY ');
    }
    
    global void execute(Database.BatchableContext bc, List<Order> ordersList) {
        try {
            // LOGIC FOR GENERATING INVOICES.
            List<Invoice__c> invoiceList = new List<Invoice__c>();
            List<Invoice_Item__c> invoiceItemList = new List<Invoice_Item__c>();
            List<OrderItem> orderItemList = new List<OrderItem>();
            Map<Id,Id> orderIdToInvoiceIdMap = new Map<Id,Id>();

            // Creating Invoices.
            for (Order activatedOrder : ordersList) {
                Invoice__c invoice = new Invoice__c(
                    Order__c = activatedOrder.Id
                    // Name = INVOICE_PREFIX + '-' + activatedOrder.OrderNumber
                );
                invoiceList.add(invoice);

                if(!activatedOrder.OrderItems.isEmpty()) {
                    orderItemList.addAll(activatedOrder.OrderItems);
                }
            }    
            if(!invoiceList.isEmpty()) {
                insert invoiceList;
            }
            // Creating InvoiceItems.
            for(Invoice__c invRec : [SELECT ID,Order__c FROM Invoice__c WHERE ID IN :invoiceList WITH SECURITY_ENFORCED]) {
                if(String.isNotBlank(invRec.Order__c)) {
                    orderIdToInvoiceIdMap.put(invRec.Order__c,invRec.Id);
                }
            } 

            for(OrderItem orderItemRec : orderItemList) {
                Invoice_Item__c invItemRec = new Invoice_Item__c(
                    Product__c = orderItemRec.Product2Id,
                    Quantity__c = orderItemRec.Quantity,
                    Price__c = orderItemRec.TotalPrice,
                    Invoice__c = orderIdToInvoiceIdMap.get(orderItemRec.OrderId)
                ); 
                invoiceItemList.add(invItemRec);
            }
            
            if(!invoiceItemList.isEmpty()) {
                insert invoiceItemList;
            }
        }
        catch(Exception ex) {
            ECExceptionManager.logException('ECGenerateInvoiceBatch', 'execute', ex);
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Optionally, you can add any cleanup or logging logic here
    }
}