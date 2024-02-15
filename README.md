# Salesforce Order Invoicing Automation

## Overview

This project provides a solution for automating the generation of invoices for orders in Salesforce. It includes Apex classes and a scheduler to generate invoices for activated orders with associated products.

## Features

- **Automated Invoicing**: Invoices are generated automatically for activated orders.
- **Batch Processing**: Invoices are generated in batch to handle large volumes of orders efficiently.
- **Scheduler**: Includes a scheduler to run the batch process daily at midnight.
- **Error Logging**: Errors during the batch process are logged for debugging and monitoring.

## Components

### Apex Classes

1. **ECGenerateInvoiceBatch**: Batch class responsible for generating invoices.
2. **ECInvoiceGeneratorScheduler**: Schedulable class to schedule the batch process and update scheduler logs.
3. **EC_ScheduleController**: Apex controller for handling scheduling and stopping the scheduler via Lightning Web Components.

### Custom Objects

1. **Invoice__c**: Custom object to store generated invoices.
2. **Invoice_Item__c**: Custom object to store invoice line items.
3. **Scheduler_Log__c**: Custom object to log scheduler run details.

### Lightning Web Components (LWC)

1. **SchedulerControl**: LWC to start and stop the scheduler and display last run details.

## Deployment Instructions

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/salesforce-order-invoicing.git
