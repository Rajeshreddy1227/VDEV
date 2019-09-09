@isTest
private class Vgtna_Test_TaskEventTriggerHelper 
{

    static testMethod void taskTestMethod()
    {
        
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        User SystemAccountOwner = new User();
        User testPartnerUser = new User();
         
        Account tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('Test ACR PROCESS TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().buildAndSave();
        tstDealerAccount.Party_ID_LastModifiedDate__c = System.today();
        update tstDealerAccount;
        Contact tstContact = new Vgtna_TestBuilder.ContactBuilder().setLastName(' Partner User').setFirstName('ACR Process').setEmail('testacrp@vive.com.invalid').setAccount(tstDealerAccount).buildAndSave();
        System.RunAs(runAsUsr)
        {
            // Create a System User to own the customer and partner accounts
            User SystemAcctOwner = new Vgtna_TestBuilder.UserBuilder().setlastName('Test ACR Process Account Owner').setEmail('tstacrpUser@Email.com.invalid').setProfileId(vgtna_Constants.INTERNAL_USER_PROFILE).setBrand('Volvo').buildAndSave();
            SystemAcctOwner.UserRoleId=[Select Id From UserRole Where name='CEO' Limit 1].Id;
           // SystemAcctOwner.Dealer_Brand__c = 'Volvo';
            update SystemAcctOwner;
            SystemAccountOwner = SystemAcctOwner;
        }
        System.RunAs(runAsUsr){
            
            User tstUser = new Vgtna_TestBuilder.UserBuilder().setContact(tstContact).setlastName('Partner User').setEmail(tstContact.Email).setProfileId(vgtna_Constants.DEALER_USER_PROFILE).buildAndSave();
            
            tstUser.IsPortalEnabled=true;
            tstUser.UserRoleId=[Select Id from UserRole Where PortalAccountId=:tstDealerAccount.Id And PortalRole='Worker' Limit 1].Id;
            tstUser.Dealer_Brand__c = 'Mack';
            update tstUser;            
            testPartnerUser = tstUser;
        }
        
        System.RunAs(SystemAccountOwner){
            //Account acc = [SELECT Id FROM Account LIMIT 1];
            Task t = new Task();
            t.WhatId = tstDealerAccount.Id;
            t.Subject = 'Call';
            t.ActivityDate = system.today();
            insert t;
            Event e = new Event();
            e.WhatId = tstDealerAccount.Id;
            e.Subject = 'New Event';
            e.DurationInMinutes= 1440;
            e.IsAllDayEvent = true;
            e.ActivityDate = System.today();
            insert e;
        }
        Customer_Activity__c ca = new Customer_Activity__c();
        ca.Name = testPartnerUser.Firstname+' '+testPartnerUser.LastName;
        ca.OwnerId = testPartnerUser.Id;
        ca.Dealer_Brand__c = testPartnerUser.Dealer_Brand__c;
        ca.IsPartner__c  = true;
        insert ca;
        System.RunAs(testPartnerUser){
            Task t = new Task();
            t.WhatId = tstDealerAccount.Id;
            t.Subject = 'Send Letter';
            t.ActivityDate = system.today();
            insert t;
            Event e = new Event();
            e.WhatId = tstDealerAccount.Id;
            e.Subject = 'New Event';
            e.DurationInMinutes = 1440;
            e.IsAllDayEvent = true;
            e.ActivityDate = System.today();
            insert e;
        }
    }
}