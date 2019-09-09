/**********************************************************************
 Name:  Vgtna_Test_RecordTypeSelectorController
 Copyright © 2018  Salesforce
 ======================================================
======================================================
Purpose: Test Class for Vgtna_RecordTypeSelectorController                                                           
-------                                                            
======================================================
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL            Description
   1.0    Subho        10/05/2018      INITIAL DEVELOPMENT          US218 
***********************************************************************/
@isTest
private class Vgtna_Test_RecordTypeSelectorController {

        static testMethod void mytestmethod()
        {
            Vgtna_RecordTypeSelectorController.getListOfRecordType();
            Vgtna_RecordTypeSelectorController.getAccountRecordType();            
            Vgtna_RecordTypeSelectorController.getPickListValuesIntoList('Account','BillingStateCode');
            Vgtna_RecordTypeSelectorController.getPickListValuesIntoList('Account','BillingCountryCode');
            //Vgtna_RecordTypeSelectorController.upsertAccount('Test Account',Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),'New Jersey','07302','US','Jersey City','37 Locust Street','');
           
            // Set mock callout class 
                Test.setMock(HttpCalloutMock.class, new Vgtna_Test_HttpCalloutMockCDB());                 
              String response = Vgtna_RecordTypeSelectorController.getCalloutResponseContents('Test Account','37 Locust Street','Jersey City','New Jersey','07302','United States',false,false);
            
            Test.setMock(HttpCalloutMock.class, new Vgtna_Test_HttpCalloutMockCDB());                 
              String response1 = Vgtna_RecordTypeSelectorController.getCalloutResponseContents('Test Account','37 Locust Street','Jersey City','-- None--','07302','United States',false,false);
            
            Test.setMock(HttpCalloutMock.class, new Vgtna_Test_HttpCalloutMockCDB());                 
              String response2 = Vgtna_RecordTypeSelectorController.getCalloutResponseContents('Test Account','37 Locust Street','Jersey City','New Jersey','07302','-- None--',false,false);
               
            // 201 Response
            Test.setMock(HttpCalloutMock.class, new Vgtna_Test_HttpCalloutMockCDBError());                 
              String response3 = Vgtna_RecordTypeSelectorController.getCalloutResponseContents('Test Account','37 Locust Street','Jersey City','New Jersey','07302','United States',false,false);
            
             Test.setMock(HttpCalloutMock.class, new Vgtna_Test_HttpCalloutMockCDB());                 
              Map <String,Object > response4 = Vgtna_RecordTypeSelectorController.getMap('Test Account','37 Locust Street','Jersey City','New Jersey','07302','United States',false,false);
            
            Test.setMock(HttpCalloutMock.class, new Vgtna_Test_HttpCalloutMockCDB());                 
              Map <String,Object > response5 = Vgtna_RecordTypeSelectorController.getMap('Test Account','37 Locust Street','Jersey City','— None—','07302','United States',false,false);
      
            Test.setMock(HttpCalloutMock.class, new Vgtna_Test_HttpCalloutMockCDB());                 
              Map <String,Object > response6 = Vgtna_RecordTypeSelectorController.getMap('Test Account','37 Locust Street','Jersey City','New Jersey','07302','— None—',false,false);
            
            Test.setMock(HttpCalloutMock.class, new Vgtna_Test_HttpCalloutMockCDBList());                 
              List<Object > response7 = Vgtna_RecordTypeSelectorController.getList('Test Account','37 Locust Street','Jersey City','New Jersey','07302','United States',false,false);
            
            Test.setMock(HttpCalloutMock.class, new Vgtna_Test_HttpCalloutMockCDBList());                 
             List<Object > response8 = Vgtna_RecordTypeSelectorController.getList('Test Account','37 Locust Street','Jersey City','— None—','07302','United States',false,false);
      
           Test.setMock(HttpCalloutMock.class, new Vgtna_Test_HttpCalloutMockCDBList());                 
              List<Object > response9 = Vgtna_RecordTypeSelectorController.getList('Test Account','37 Locust Street','Jersey City','New Jersey','07302','— None—',false,false);
        }
    
    static testMethod void upserAccounttestmethod()
    {
        Vgtna_RecordTypeSelectorController.upsertAccount('Test Account',Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),'New Jersey','07302','US','Jersey City','37 Locust Street','');
        Vgtna_RecordTypeSelectorController.upsertAccount('Test Account1',Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),'New York','1007','US','New York','575 Washington Blvd','409876');
        Vgtna_RecordTypeSelectorController.upsertAccount('Test Account NY',Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),'New York','1004','US','New York','4 New York Plaza','409876');
        
        Vgtna_RecordTypeSelectorController.upsertAccount('Test Account',Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),'NJ','07305','United States','Jersey City','345 Clairmont Ave','');
        Vgtna_RecordTypeSelectorController.upsertAccount('Test Account1',Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),'NY','10036','United States','New York','1095 Avenue of the Americas','409877');
        Vgtna_RecordTypeSelectorController.upsertAccount('Test Account NY',Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),'NY','1004','United States','New York','4 New York Plaza','409876');
        
      	
        List<Assigned_Sales_Rep__c> lst_ASR = new List<Assigned_Sales_Rep__c>();
        lst_ASR = [Select id from Assigned_Sales_Rep__c where Account__r.Party_ID__c='409876'];
        if(lst_ASR.size() > 0)
        {
            delete lst_ASR;
        }
        Vgtna_RecordTypeSelectorController.upsertAccount('Test Account NY',Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),'NY','1004','United States','New York','4 New York Plaza','409876');
    }
}