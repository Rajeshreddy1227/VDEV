/**********************************************************************
 Name:  Vgtna_RecordTypeSelectorController
 Copyright © 2018  Salesforce
 ======================================================
======================================================
Purpose: Apex controller for Lightning component Vgtna_Ltng_CreateAccount.cmp to pool in recordtype info. and field picklist                                                          
-------                                                            
======================================================
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL            Description
   1.0    Subho        10/04/2018      INITIAL DEVELOPMENT          US218 
***********************************************************************/

public with sharing class Vgtna_RecordTypeSelectorController {

    @AuraEnabled
    public static List<RecordType> getListOfRecordType(){
                   
        List<SelectOption> recordTypes = new List<SelectOption>();
        List<RecordType> rtNames = new List<RecordType>(); 
            for(RecordTypeInfo info: Account.SObjectType.getDescribe().getRecordTypeInfos()) {
                if(info.isAvailable() && info.getName()!= System.Label.Vgtna_Master_RT) {
                    recordTypes.add(new SelectOption(info.getRecordTypeId(), info.getName()));
                    rtNames.add(new RecordType(Id = info.getRecordTypeId(),Name = info.getName()));
            }
        }

        // Include these next 3 lines to output the results during development and debugging
        for( SelectOption selopt: recordTypes ) {
            System.debug( selopt.getLabel() + ',' + selopt.getValue() );
        }
        return rtNames;   
       
    }
    
    @AuraEnabled
    public static Id getAccountRecordType() {
       Id ClientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
       return ClientRecordTypeId;
    } 
    

    @AuraEnabled        
    public static List<String> getPickListValuesIntoList(String objectType, String selectedField){
        List<String> pickListValuesList = new List<String>();
        //pickListValuesList.add('-- None--');
        pickListValuesList.add('');
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get('Account');
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult ;
        if(selectedField =='BillingStateCode')
        {
             fieldResult = res.fields.getMap().get('US_CAN_States__c').getDescribe();
        }
        else
        {
            fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        }
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            if(selectedField =='BillingCountryCode')
            {
                if(pickListVal.getLabel() =='United States' || pickListVal.getLabel() =='Canada')
                {
                    pickListValuesList.add(pickListVal.getLabel());
                }
            }
            
            else
            {
                pickListValuesList.add(pickListVal.getLabel());
            }
            
        }     
        return pickListValuesList;
    }
    
    @AuraEnabled  
      public static String getCalloutResponseContents(String accName,String accStreet,String accCity,String accState,String accZip,String accCountry, Boolean ignoreCleanse, Boolean ignoreMatch) { 
        
        List<Object> resultsMap = new List<Object>();
        
        system.debug('Name-->' + accName);
        system.debug('Street-->' + accStreet);
        system.debug('City-->' + accCity);
        system.debug('State-->' + accState);
        system.debug('Zip-->' + accZip);
        system.debug('Country-->' + accCountry);
        
        // Factor in --None-- values
        
        if (accState == '-- None--')
        {
            accState = '';
        }
        
        if (accCountry == '-- None--')
        {
            accCountry = '';
        }
        
        // Map Statecode
        Schema.DescribeFieldResult fieldResult = Account.BillingStateCode.getDescribe();
        Map<String, String> mapCodeToValue = new Map<String, String>();
        
        for(Schema.PicklistEntry f : fieldResult.getPicklistValues())
        {
           
           mapCodeToValue.put(f.getLabel(), f.getValue());
        }   
        String accStateCode = mapCodeToValue.get(accState);
          // Get OrgId so you can point prod vs. QA
        
            Id OrgId = UserInfo.getOrganizationId();
          System.debug('OrgId-->'+OrgId);
          string organizationId = String.valueOf(OrgId);
          
        // Instantiate a new http object
            Http http = new Http();
        
        // Instantiate a new HTTP request, specify the method (POST) as well as the endpoint
            HttpRequest request = new HttpRequest();
            
          // request.setEndpoint(System.Label.Vgtna_QA_CDB_Endpoint);
          // Compare prod org id           
            
                  if(organizationId.substring(0,15) == System.Label.Vgtna_Prod_Org_ID)
                  {
                    // Need to add prod Named Credential
                    request.setEndpoint('callout:Vgtna_CDB_Endpoint_PROD'+'?ignoreMatch='+ignoreMatch+'&ignoreCleanse='+ignoreCleanse);
                  }
                  else
                  {
                      request.setEndpoint('callout:Vgtna_CDB_Endpoint_QA'+'?ignoreMatch='+ignoreMatch+'&ignoreCleanse='+ignoreCleanse);
                  }
            
        
            request.setMethod('POST');            
              
            // request.setHeader('Ocp-Apim-Subscription-Key', System.Label.Vgtna_QA_CDB_Subscription_Key);
            
            request.setHeader('Ocp-Apim-Subscription-Key', '{!$Credential.Password}');
           
             request.setHeader('Content-Type','application/json');
           
        // Set the body as a JSON object
   
        request.setBody('{"FMVName": "","stateProv": "'+accStateCode+'","zipCode":"'+accZip+'","country": "'+accCountry+'","address": "'+accStreet+'","FMVID": "","city": "'+accCity+'","name": "'+accName+'","alias": "","partyID": "","usDotId": "","AssistNames": []}');
        
        System.debug('request--->'+request);
        System.debug('request Body--->'+request.getBody());
        
        // Send the request, and return a response
            HttpResponse response = http.send(request);
            
            // Send the response code
                if (response.getStatusCode() == 201) 
                {
                    Map < String,Object > resMap = new Map < String,Object >();
                   resMap = (Map < String, Object > ) JSON.deserializeUntyped(response.getBody());
                    system.debug('resMap PartyID-->'+resMap.get('partyID'));
                    return String.valueOf(resMap.get('partyID'));
                }
              else
              {
                  return String.valueOf(response.getStatusCode());
              }
          
          
           
    }
    
 @AuraEnabled
public static String upsertAccount(String name,String rtid,String state,String zip,String code,String city,String street,String partyid) 
{
        // Query Salesforce database based on Party ID. Party ID is always expected to be present.  
    
        Account acc = new Account();
        try
        {
            acc = [select id, Name, RecordTypeId,BillingStreet,BillingState,BillingCountryCode, BillingCountry,BillingPostalCode, Party_ID__c
                           from Account
                          where Party_ID__c =:partyid limit 1];
            
            // If a match is found check if the logged in user has access rights to update the record.
            UserRecordAccess ura = [Select RecordId,HasEditAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId = :acc.id];
                
            if(ura.HasEditAccess == false)
                {
                    // User cannot edit account. So check if an ASR record already exists for the logged in user.
                    
                    
                }
                else
                {
                    // User can edit account so update the account. Do not update Account Name
                    
                       // acc.Name = name;
                        acc.RecordTypeId = rtid;
                        acc.BillingStreet = street;
                        if(state.length()> 2)
                        {
                            acc.BillingState = state;
                        }
                        else
                        {
                            acc.BillingStateCode = state;
                        }
                        
                        acc.BillingPostalCode = zip;
                        if(code.length()> 2)
                        {
                            acc.BillingCountry = code;
                        }
                        else
                        {
                            acc.BillingCountryCode = code;
                        }
                        acc.BillingCity = city;
                        acc.Party_ID__c = partyid;
                        try
                        {
                            update acc; 
                        }
                        catch(Exception e)
                        {
                            return e.getMessage();
                        }
                                           
                }
            
                // Whether the logged in user can or cannot edit accounts check if an ASR already exists. If not create one.
                
                    try
                    {
                        Assigned_Sales_Rep__c existingASR = [Select id,Account__c,Sales_Rep__c
                                                             From Assigned_Sales_Rep__c
                                                             Where Account__c =:acc.Id
                                                             AND Sales_Rep__c =: userInfo.getUserId() limit 1];
                        // If an ASR is found do nothing.
                        return acc.id;
                    }
                    catch(Exception ex)
                    {
                        // if no match is found that means create one
                        
                        Assigned_Sales_Rep__c ASR = new Assigned_Sales_Rep__c(Account__c = acc.id, 
                                                                                       Sales_Rep__c = userInfo.getUserId());
                                 
                                 try
                                 {
                                     insert ASR;
                                     return acc.id;
                                 }
                                 catch(Exception enewASR)
                                 {
                                     return enewASR.getMessage();
                                 }
                    }
        }
        catch(Exception e)
        {
            // No record found in Salesforce with the Party ID. So create one and add the logged in user to the Assigned Sales Rep.
            
            acc = new Account();
                        acc.Name = name;
                        acc.RecordTypeId = rtid;
                        acc.BillingStreet = street;
                        if(state.length()> 2)
                                            {
                                                acc.BillingState = state;
                                            }
                                            else
                                            {
                                                acc.BillingStateCode = state;
                                            }
                        acc.BillingPostalCode = zip;
                        if(code.length()> 2)
                                            {
                                                acc.BillingCountry = code;
                                            }
                                            else
                                            {
                                                acc.BillingCountryCode = code;
                                            }
                        acc.BillingCity = city;
                        acc.Party_ID__c = partyid;
                         try
                             {
                                 insert acc; 
                                 return acc.id;
                                 // Create ASR record
                                 /** There is a process builder on Account that is already creating an ASR for the account owner
                                 Assigned_Sales_Rep__c ASR = new Assigned_Sales_Rep__c(Account__c = acc.id, 
                                                                                       Sales_Rep__c = userInfo.getUserId());
                                 
                                 try
                                 {
                                     insert ASR;
                                     return acc.id;
                                 }
                                 catch(Exception exnewASR)
                                 {
                                     return exnewASR.getMessage();
                                 }**/
                             }
                            catch(Exception exc)
                            {
                                return exc.getMessage();
                            }
        }
    
   
    
                /*** Old Logic starts
     
                // Perform isUpdateable() check here 
                Account acc = new Account();
                system.debug('upsertAccount:');
                system.debug('state:'+state.length());
                
                String [] accountAccessFields = new String [] {'Name',
                                                                   'BillingState',
                                                                   'BillingPostalCode',
                                                                   'BillingCountryCode',
                                                                   'BillingCity',
                                                                   'BillingStreet'
                                                                    //'Party_Id__c'
                                                                   };
                
                if(partyid != '' && partyid != null)
                {
                    // Could be upsert
            
                // Obtain the field name/token map for the Expense object
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Account.fields.getMap();
            
                for (String fieldToCheck : accountAccessFields) {
            
                    // Check if the user has access to create  field as well as update it
                    
                    if (!m.get(fieldToCheck).getDescribe().isCreateable()|| !m.get(fieldToCheck).getDescribe().isUpdateable()) 
                    {
            
                        // Pass error to client
                        //throw new System.NoAccessException();
                      //  return null;
                        return 'No Access rights to create or update Accounts';
                        
                    }
                }
                    
                    // Query salesforce for matching party id
                    
                    system.debug('Query for party id not null:');
                    
                    try
                    {
                        acc = [select id, Name, RecordTypeId,BillingStreet,BillingState,BillingCountryCode, BillingCountry,BillingPostalCode, Party_ID__c
                           from Account
                          where Party_ID__c =:partyid limit 1];
                        
                        
                        
                                if(acc!= null)
                                {
                                    UserRecordAccess ura = [Select RecordId,HasEditAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId = :acc.id];
                                    if(ura.HasEditAccess == false)
                                    {
                                        return 'No Access rights to create or update Accounts';
                                    }
                                    else
                                    {
                                        // Update String state,String zip,String code,String city,String street,String partyid) 
                                            acc.Name = name;
                                            acc.RecordTypeId = rtid;
                                            acc.BillingStreet = street;
                                            if(state.length()> 2)
                                            {
                                                acc.BillingState = state;
                                            }
                                            else
                                            {
                                                acc.BillingStateCode = state;
                                            }
                                            
                                            acc.BillingPostalCode = zip;
                                            if(code.length()> 2)
                                            {
                                                acc.BillingCountry = code;
                                            }
                                            else
                                            {
                                                acc.BillingCountryCode = code;
                                            }
                                            acc.BillingCity = city;
                                            acc.Party_ID__c = partyid;
                                           try
                                           {
                                               update acc; 
                                           }
                                            catch(Exception e)
                                            {
                                                return e.getMessage();
                                             }
                                           
                                    }
                                    
                                    
                                }
                                
                    }
                    catch(Exception e)
                    {
                                // Insert
                                    system.debug('Insert state:'+state);
                                    system.debug('Insert country code:'+code);
                                    acc = new Account();
                                    acc.Name = name;
                                    acc.RecordTypeId = rtid;
                                    acc.BillingStreet = street;
                                    if(state.length()> 2)
                                            {
                                                acc.BillingState = state;
                                            }
                                            else
                                            {
                                                acc.BillingStateCode = state;
                                            }
                                    acc.BillingPostalCode = zip;
                                    if(code.length()> 2)
                                            {
                                                acc.BillingCountry = code;
                                            }
                                            else
                                            {
                                                acc.BillingCountryCode = code;
                                            }
                                    
                                    acc.BillingCity = city;
                                    acc.Party_ID__c = partyid;
                                    try
                                           {
                                               insert acc; 
                                           }
                                            catch(Exception ex)
                                            {
                                               return ex.getMessage();
                                            }
                                    
                    }
                    
                     
                    
                    
            }
                else
                {
                    // New record just insert.
                    // Perform isCreatable() check here 
                    system.debug('INSERT ONLY:');
                    
                    Map<String,Schema.SObjectField> m = Schema.SObjectType.Account.fields.getMap();
            
                for (String fieldToCheck : accountAccessFields) {
            
                    // Check if the user has access to create  field as well as update it
                    
                    if (!m.get(fieldToCheck).getDescribe().isCreateable()|| !m.get(fieldToCheck).getDescribe().isUpdateable()) 
                    {
            
                        // Pass error to client
                        //throw new System.NoAccessException();
                        //  return null;
                        return 'No Access rights to create or update Accounts';
                        
                    }
                }
                    // Insert
                       
                    system.debug('INSERT ACCOUNT:');
                    
                        acc = new Account();
                        acc.Name = name;
                        acc.RecordTypeId = rtid;
                        acc.BillingStreet = street;
                        if(state.length()> 2)
                                            {
                                                acc.BillingState = state;
                                            }
                                            else
                                            {
                                                acc.BillingStateCode = state;
                                            }
                        acc.BillingPostalCode = zip;
                        if(code.length()> 2)
                                            {
                                                acc.BillingCountry = code;
                                            }
                                            else
                                            {
                                                acc.BillingCountryCode = code;
                                            }
                        acc.BillingCity = city;
                        acc.Party_ID__c = partyid;
                         try
                             {
                                 insert acc; 
                             }
                            catch(Exception exc)
                            {
                                return exc.getMessage();
                            }
                        
                }
                system.debug('CREATED ACCOUNT:'+acc);
                return acc.id;
                
               Old Logic ends **/ 
}

    @AuraEnabled
    public static Map <String,Object > getMap(String accName,String accStreet,String accCity,String accState,String accZip,String accCountry, Boolean ignoreCleanse, Boolean ignoreMatch) {
  
         Map < String,Object > resultsMap = new Map < String,Object >();
    
        
        // Factor in —None— values
        
        if (accState == '— None—')
        {
            accState = '';
        }
        
        if (accCountry == '— None—')
        {
            accCountry = '';
        }
        
       // Map Statecode
        Schema.DescribeFieldResult fieldResult = Account.BillingStateCode.getDescribe();
        Map<String, String> mapCodeToValue = new Map<String, String>();
        
        for(Schema.PicklistEntry f : fieldResult.getPicklistValues())
        {
           
           mapCodeToValue.put(f.getLabel(), f.getValue());
        }   
        String accStateCode = mapCodeToValue.get(accState);
          // Get OrgId so you can point prod vs. QA
        
            Id OrgId = UserInfo.getOrganizationId();
          System.debug('OrgId-->'+OrgId);
          string organizationId = String.valueOf(OrgId);
          
        // Instantiate a new http object
            Http http = new Http();
        
        // Instantiate a new HTTP request, specify the method (POST) as well as the endpoint
            HttpRequest request = new HttpRequest();
            
          // request.setEndpoint(System.Label.Vgtna_QA_CDB_Endpoint);
          // Compare prod org id           
            
                  if(organizationId.substring(0,15) == System.Label.Vgtna_Prod_Org_ID)
                  {
                    // Need to add prod Named Credential
                    request.setEndpoint('callout:Vgtna_CDB_Endpoint_PROD'+'?ignoreMatch='+ignoreMatch+'&ignoreCleanse='+ignoreCleanse);
                  }
                  else
                  {
                      request.setEndpoint('callout:Vgtna_CDB_Endpoint_QA'+'?ignoreMatch='+ignoreMatch+'&ignoreCleanse='+ignoreCleanse);
                  }
            
        
            request.setMethod('POST');            
              
            // request.setHeader('Ocp-Apim-Subscription-Key', System.Label.Vgtna_QA_CDB_Subscription_Key);
            
            request.setHeader('Ocp-Apim-Subscription-Key', '{!$Credential.Password}');
           
             request.setHeader('Content-Type','application/json');
           
        // Set the body as a JSON object          
        
        request.setBody('{"FMVName": "","stateProv": "'+accStateCode+'","zipCode":"'+accZip+'","country": "'+accCountry+'","address": "'+accStreet+'","FMVID": "","city": "'+accCity+'","name": "'+accName+'","alias": "","partyID": "","usDotId": "","AssistNames": []}');
        
        System.debug('request--->'+request);
        System.debug('request Body--->'+request.getBody());
        
        // Send the request, and return a response
            HttpResponse response = http.send(request);
            
            // Parse the JSON response

     Map < String,Object > resMap = new Map < String,Object >();
                   resMap = (Map < String, Object > ) JSON.deserializeUntyped(response.getBody());
                    system.debug('resMap→' + resMap);
    return resMap;
  
    }

    
    @AuraEnabled
     public static List<Object > getList(String accName,String accStreet,String accCity,String accState,String accZip,String accCountry, Boolean ignoreCleanse, Boolean ignoreMatch) {
  
        List<Object > resultsMap = new List<Object >();
    
        
        // Factor in —None— values
        
        if (accState == '— None—')
        {
            accState = '';
        }
        
        if (accCountry == '— None—')
        {
            accCountry = '';
        }
        
       // Map Statecode
        Schema.DescribeFieldResult fieldResult = Account.BillingStateCode.getDescribe();
        Map<String, String> mapCodeToValue = new Map<String, String>();
        
        for(Schema.PicklistEntry f : fieldResult.getPicklistValues())
        {
           
           mapCodeToValue.put(f.getLabel(), f.getValue());
        }   
        String accStateCode = mapCodeToValue.get(accState);
          // Get OrgId so you can point prod vs. QA
        
            Id OrgId = UserInfo.getOrganizationId();
          System.debug('OrgId-->'+OrgId);
          string organizationId = String.valueOf(OrgId);
          
        // Instantiate a new http object
            Http http = new Http();
        
        // Instantiate a new HTTP request, specify the method (POST) as well as the endpoint
            HttpRequest request = new HttpRequest();
            
          // request.setEndpoint(System.Label.Vgtna_QA_CDB_Endpoint);
          // Compare prod org id           
            
                  if(organizationId.substring(0,15) == System.Label.Vgtna_Prod_Org_ID)
                  {
                    // Need to add prod Named Credential
                    request.setEndpoint('callout:Vgtna_CDB_Endpoint_PROD'+'?ignoreMatch='+ignoreMatch+'&ignoreCleanse='+ignoreCleanse);
                  }
                  else
                  {
                      request.setEndpoint('callout:Vgtna_CDB_Endpoint_QA'+'?ignoreMatch='+ignoreMatch+'&ignoreCleanse='+ignoreCleanse);
                  }
            
        
            request.setMethod('POST');            
              
            // request.setHeader('Ocp-Apim-Subscription-Key', System.Label.Vgtna_QA_CDB_Subscription_Key);
            
            request.setHeader('Ocp-Apim-Subscription-Key', '{!$Credential.Password}');
           
             request.setHeader('Content-Type','application/json');
           
        // Set the body as a JSON object
          
      //request.setBody('{"FMVName": "","stateProv": "'+accStateCode+'","zipCode":"'+accZip+'","country": "'+accCountry+'","address": "'+accStreet+'","FMVID": "","city": "'+accCity+'","name": "'+accName+'","alias": "","partyID": "","usDotId": "","AssistNames": []}');
        request.setBody('{"FMVName": "","stateProv": "'+accStateCode+'","zipCode":"'+accZip+'","country": "'+accCountry+'","address": "'+accStreet+'","FMVID": "","city": "'+accCity+'","name": "'+accName+'","alias": "","partyID": "","usDotId": "","DataSource":"CRM","AssistNames": []}');       
        System.debug('request--->'+request);
        System.debug('request Body--->'+request.getBody());
        
        // Send the request, and return a response
            HttpResponse response = http.send(request);
            
            // Parse the JSON response

     system.debug('response.getBody() →' + response.getBody());
                   resultsMap = (List<Object>)JSON.deserializeUntyped(response.getBody());
       system.debug('resultsMap →' + resultsMap);
    return resultsMap;
  
    }
            
}