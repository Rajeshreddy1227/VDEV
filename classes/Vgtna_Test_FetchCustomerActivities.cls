@isTest
private class Vgtna_Test_FetchCustomerActivities
{

    static testMethod void fetchTaskTestMethod1()
    {   
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        User testPartnerUser = new User();
        Account tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('Test ACR PROCESS TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().buildAndSave();
        tstDealerAccount.Party_ID_LastModifiedDate__c = System.today();
        update tstDealerAccount;
        system.debug('customer acc: '+[select id, recordtype.name from account where id =:tstDealerAccount.Id]);
        Account dealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('ADVANTAGE TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).setDealerCode('A112').buildAndSave();
        dealerAccount.IsPartner = true;
        //dealerAccount.ParentId = tstDealerAccount1.Id;
        update dealerAccount;
        Contact tstContact = new Vgtna_TestBuilder.ContactBuilder().setLastName(' Partner User').setFirstName('ACR Process').setEmail('testacrp@vive.com.invalid').setAccount(dealerAccount).buildAndSave();
       // AccountContactRelation acr = new AccountContactRelation(contactId = tstContact.Id, Roles = 'Sales Manager', AccountId=dealerAccount.Id);
        //insert acr;
        System.runAs(runAsUsr) {
            User tstUser = new Vgtna_TestBuilder.UserBuilder().setContact(tstContact).setlastName('Partner User').setEmail(tstContact.Email).setProfileId(vgtna_Constants.DEALER_USER_PROFILE).buildAndSave();
                
            tstUser.IsPortalEnabled=true;
            tstUser.UserRoleId=[Select Id from UserRole Where PortalAccountId=:dealerAccount.Id And PortalRole='Worker' Limit 1].Id;
            tstUser.Dealer_Brand__c = 'Mack';
            tstUser.Dealer_Code__c = 'A112';
            update tstUser;   
            testPartnerUser = tstUser;  
            AccountContactRelation acr = [SELECT Id, Roles FROM AccountContactRelation WHERE AccountId = :dealerAccount.Id AND ContactId = :tstContact.Id LIMIT 1];
            acr.Roles = 'Sales Manager';
            update acr;
        }        
        System.RunAs(testPartnerUser){
            Id custRec = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            system.debug('custRec: '+custRec);
            account a = new account();
            a.recordtypeId = custRec;
            a.Name = 'customer1';
            a.Party_id__c = '7439849393';
            insert a;
            //Account acc = [SELECT Id, recordtype.name FROM Account where recordtypeId = :custRec LIMIT 1];
            //system.debug('acc record: '+acc.recordtype.name);
            Task t = new Task();
            t.WhatId = a.Id;
            t.Account__c = a.Id;
            t.OwnerId = testPartnerUser.Id;
            t.Dealer_Code__c = 'A112';
            t.Subject = 'Call';
            t.ActivityDate = System.today();
            insert t;
            Event e = new Event();
            e.WhatId = a.Id;
            e.Subject = 'New Event';
            e.Account__c = a.Id;
            e.OwnerId = testPartnerUser.Id;
            e.Dealer_Code__c = 'A112';
            e.Subject = 'Call';
            e.DurationInMinutes= 1440;
            e.IsAllDayEvent = true;
            e.ActivityDate = System.today();
            insert e;
            Vgtna_FetchCustomerActivities.getCustActivities(a.Id,true,'activitiestab');
            Vgtna_FetchCustomerActivities.getLoggedUser();            
        }      
        
        //Naren: Add the View All condition to be False
        System.RunAs(testPartnerUser){
            //Account acc = [SELECT Id FROM Account LIMIT 1];
            Task t = new Task();
            //t.WhatId = tstDealerAccount.Id;
           // t.Account__c = tstDealerAccount.Id;
            t.OwnerId = testPartnerUser.Id;
            t.Dealer_Code__c = 'A112';
            t.Subject = 'Call';
            t.ActivityDate = System.today();
            insert t;
            Event e = new Event();
           // e.WhatId = tstDealerAccount.Id;
            e.Subject = 'New Event';
            //e.Account__c = tstDealerAccount.Id;
            e.OwnerId = testPartnerUser.Id;
            e.Dealer_Code__c = 'A112';
            e.Subject = 'Call';
            e.DurationInMinutes= 1440;
            e.IsAllDayEvent = true;
            e.ActivityDate = System.today();
            insert e;
            Vgtna_FetchCustomerActivities.getCustActivities('',False,'activitiestab');
            Vgtna_FetchCustomerActivities.getLoggedUser();
        }       
         
    }
    
    static testMethod void fetchTaskTestMethod2()
    {   
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        User testPartnerUser = new User();
        Account tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('Test ACR PROCESS TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().buildAndSave();
        tstDealerAccount.Party_ID_LastModifiedDate__c = System.today();
        update tstDealerAccount;
        Account dealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('ADVANTAGE TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).setDealerCode('A112').buildAndSave();
        dealerAccount.IsPartner = true;
        //dealerAccount.ParentId = tstDealerAccount1.Id;
        update dealerAccount;
        Contact tstContact = new Vgtna_TestBuilder.ContactBuilder().setLastName(' Partner User').setFirstName('ACR Process').setEmail('testacrp@vive.com.invalid').setAccount(dealerAccount).buildAndSave();
        System.runAs(runAsUsr) {
            User tstUser = new Vgtna_TestBuilder.UserBuilder().setContact(tstContact).setlastName('Partner User').setEmail(tstContact.Email).setProfileId(vgtna_Constants.DEALER_USER_PROFILE).buildAndSave();
                
            tstUser.IsPortalEnabled=true;
            tstUser.UserRoleId=[Select Id from UserRole Where PortalAccountId=:dealerAccount.Id And PortalRole='Worker' Limit 1].Id;
            tstUser.Dealer_Brand__c = 'Mack';
            tstUser.Dealer_Code__c = 'A112';
            update tstUser;   
            testPartnerUser = tstUser;  
        }        
        System.RunAs(testPartnerUser){
            //Account acc = [SELECT Id FROM Account LIMIT 1];
            Task t = new Task();
            //t.WhatId = tstDealerAccount.Id;
            //t.Account__c = tstDealerAccount.Id;
            t.OwnerId = testPartnerUser.Id;
            t.Dealer_Code__c = 'A112';
            t.Subject = 'Call';
            t.ActivityDate = System.today();
            insert t;
            Event e = new Event();
            //e.WhatId = tstDealerAccount.Id;
            e.Subject = 'New Event';
            //e.Account__c = tstDealerAccount.Id;
            e.OwnerId = testPartnerUser.Id;
            e.Dealer_Code__c = 'A112';
            e.Subject = 'Call';
            e.DurationInMinutes= 1440;
            e.IsAllDayEvent = true;
            e.ActivityDate = System.today();
            insert e;
            String recId;
            Vgtna_FetchCustomerActivities.getCustActivities('',false,'activitiestab');
        }    
            System.RunAs(testPartnerUser){
            //Account acc = [SELECT Id FROM Account LIMIT 1];
            Task t = new Task();
           // t.WhatId = tstDealerAccount.Id;
           // t.Account__c = tstDealerAccount.Id;
            t.OwnerId = testPartnerUser.Id;
            t.Dealer_Code__c = 'A112';
            t.Subject = 'Call';
            t.ActivityDate = System.today();
            insert t;
            Event e = new Event();
            //e.WhatId = tstDealerAccount.Id;
            e.Subject = 'New Event';
            //e.Account__c = tstDealerAccount.Id;
            e.OwnerId = testPartnerUser.Id;
            e.Dealer_Code__c = 'A112';
            e.Subject = 'Call';
            e.DurationInMinutes= 1440;
            e.IsAllDayEvent = true;
            e.ActivityDate = System.today();
            insert e;
            String recId;
            Vgtna_FetchCustomerActivities.getCustActivities(recId,true,'Activities Tab');
            Vgtna_FetchCustomerActivities.getLoggedUser();
        }       
    }
}