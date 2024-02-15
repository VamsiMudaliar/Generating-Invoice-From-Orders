/**
 * @description       : 
 * @author            : Vamsi Mudaliar
 * @group             : 
 * @last modified on  : 02-15-2024
 * @last modified by  : Vamsi Mudaliar
**/
public with sharing class ECExceptionManager {
    
    public static void logException(String className, String methodName, Exception expRec){
        
        Error_Log__c exceptionRecord = new Error_Log__c();
        exceptionRecord.Method_Name__c = methodName;
        exceptionRecord.Class_Name__c = className;
        exceptionRecord.Exception_Type__c = expRec.getTypeName();
        exceptionRecord.Error_Message__c = expRec.getMessage();
        exceptionRecord.Stack_Trace__c = expRec.getStackTraceString();
        //Mapping Current User Details
        exceptionRecord.Current_User__c = UserInfo.getUserId();
        
        insert exceptionRecord;
    }
}