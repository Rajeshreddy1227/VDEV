/**********************************************************************
Name:  Vgtna_Test_LeadProcess
Copyright © 2018  Salesforce
======================================================
======================================================
Purpose: Test Class for following:
**Trigger- 
1. Vgtna_LeadTrigger - 100%


**Apex Classes- 
1. Vgtna_LeadTriggerHandler - 91%
2. Vgtna_LeadModel - 92%
3. Vgtna_SharingModel - 100%



-------                                                            
======================================================
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL            Description
1.0    Subho        10/06/2018      INITIAL DEVELOPMENT          US102
***********************************************************************/
@isTest
private class Vgtna_Test_LeadProcess {
    
    static testMethod void leadTestMethod()
    {
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        User SystemAccountOwner = new User();
        User testPartnerUser = new User();
        
        // Create two AOR records - one for CA and one for US
        
        List<AOR__c> lst_AOR = new List<AOR__c>();
        
        AOR__c USAOR = new AOR__c(Brand__c = 'Volvo',Country__c='US',Postal_Code__c = '07302', Dealer_Code__c = '396B');
        AOR__c CANAOR = new AOR__c(Brand__c = 'Volvo',Country__c='CA',State_Province__c='ON',Postal_Code__c = 'L4N', Dealer_Code__c = '397G',City__c = 'Toronto');
        lst_AOR.add(USAOR);
        lst_AOR.add(CANAOR);
        insert lst_AOR;
        
        // Scenario 1 : Lead Insert with a portal user
        
        System.RunAs(runAsUsr)
        {
            // Create a System User to own the customer and partner accounts
            User SystemAcctOwner = new Vgtna_TestBuilder.UserBuilder().setlastName('Test Lead Process Account Owner').setEmail('tstlpUser@Email.com.invalid').setProfileId(vgtna_Constants.INTEGRATION_USER_PROFILE).buildAndSave();
            SystemAcctOwner.UserRoleId=[Select Id From UserRole Where name='System Partner Role' Limit 1].Id;
            update SystemAcctOwner;
            SystemAccountOwner = SystemAcctOwner;
            
            Group pg = new Group(Name ='396B - Managers', Type= 'Regular', DeveloperName='X396B_Managers');
       		 insert pg;
        }
        
        system.debug('**** setup account owner '+SystemAccountOwner);
        
        // Create the Dealer Account
        Account tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('Test LEAD PROCESS TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).setDealerCode('396B').buildAndSave();
        tstDealerAccount.IsPartner = true;
        // Set owner to System User
        tstDealerAccount.OwnerId=SystemAccountOwner.Id;
        system.debug('*** Account: '+tstDealerAccount);
        update tstDealerAccount;
        
        // Create the Contact that will be converted into the Partner User
        Contact tstContact = new Vgtna_TestBuilder.ContactBuilder().setLastName('Partner User').setFirstName('Lead Process').setEmail('testlp@vive.com.invalid').setAccount(tstDealerAccount).buildAndSave();
        system.debug('*** contact '+tstContact);
        
        // Create the Partner User
        System.RunAs(runAsUsr){
            
            User tstUser = new Vgtna_TestBuilder.UserBuilder().setContact(tstContact).setlastName('Partner User').setEmail(tstContact.Email).setProfileId(vgtna_Constants.DEALER_USER_PROFILE).buildAndSave();
            
            tstUser.IsPortalEnabled=true;
            tstUser.UserRoleId=[Select Id from UserRole Where PortalAccountId=:tstDealerAccount.Id And PortalRole='Worker' Limit 1].Id;
            tstUser.Dealer_Brand__c = 'Volvo';
            tstUser.Dealer_Code__c = '396B';
            update tstUser;
            testPartnerUser = tstUser;
        }
        system.debug('*** testPartnerUser '+testPartnerUser+' AND isPartner: '+testPartnerUser.IsPortalEnabled);

        // Create two Lead Queues
        List<Group> newLeadQueues = new List<Group>();
        List<Id> groupIds = new List<Id>();
        List<String> dealerCodes = new List<String>();
        
        for(AOR__c a: lst_AOR)
        {
            String dc = a.Dealer_Code__c;
            if(dc.left(1).isNumeric())
            {
                dc='X'+dc;
            }
            dealerCodes.add(dc.trim());  // Just used for Assertion below to check logic of query found in Vgtna_LeadModel
            Group g = new Group(Type='Queue', Name=a.Dealer_Code__c+' - Lead Queue', DeveloperName=dc);
            newLeadQueues.add(g);
        }
        insert newLeadQueues;
        List<Group> g = [Select Id, Name, DeveloperName 
                           From Group 
                           Where DeveloperName In:dealerCodes
                           AND Type='Queue'];        
        System.assertEquals(2, g.size());
        
        System.debug('Queues (Groups) added for Test are '+newLeadQueues);
        for(Group grp: newLeadQueues)
        {
            groupIds.add(grp.Id);
	        System.debug('Group Developername = '+grp.DeveloperName);
        }
        
        // Call the future method
        List<QueueSObject> newQueueSObject = new List<QueueSObject>();
        
        for(Group o_g: newLeadQueues)
        {
            QueueSObject q = new QueueSObject(SobjectType='Lead', QueueId=o_g.Id);
            newQueueSObject.add(q);
        }
        System.RunAs(runAsUsr)
        {
        	insert newQueueSObject;
        } 
        
        Test.startTest();
        System.RunAs(testPartnerUser)
        {
            List<Lead> newPartnerLeads = new List<Lead>();
            
            Lead l1 = new Lead(LastName = 'Test1', Company = 'Comp1',Email='test11@test.com.invalid',CountryCode = 'US',PostalCode = '07302', Brand__c = 'Volvo');
            newPartnerLeads.add(l1);
            
            Lead l3 = new Lead(LastName = 'Test3', Company = 'Comp3',
                                   Email='test13@test.com.invalid',Brand__c = 'Volvo',
                                   CountryCode = 'CA',PostalCode = 'L4N7GS',
                                   StateCode = 'ON',City='Toronto');
            newPartnerLeads.add(l3);
            
            insert newPartnerLeads;
  
        }
        Lead L1 = [Select id from Lead where Email ='test11@test.com.invalid'
                   And Ownerid =: testPartnerUser.Id];
        
        L1.OwnerId = runAsUsr.id;
            update L1;
  
		Test.stopTest();
        
    }

    static testMethod void leadTestMethod2()
    {//
        Account acc1 = new Vgtna_TestBuilder.AccountBuilder().setName('US-396B').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().setBillingCountryCode('US').setBillingPostalCode('561832323').buildAndSave();
        
        acc1.Dealer_Code__c = '396B';
         update acc1; 
        Account acc2 = new Vgtna_TestBuilder.AccountBuilder().setName('US-397G').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().setBillingCountryCode('CA').setBillingPostalCode('L4N7GS').buildAndSave();
        acc2.Dealer_Code__c = '397G';
         update acc2; 
      //      
        
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        User SysIntegrator = new User();
   
        // Create two AOR records - one for CA and one for US
        
        List<AOR__c> lst_AOR = new List<AOR__c>();
        
        AOR__c USAOR = new AOR__c(Brand__c = 'Volvo',Country__c='US',Postal_Code__c = '07302', Dealer_Code__c = '396B');
        AOR__c CANAOR = new AOR__c(Brand__c = 'Volvo',Country__c='CA',State_Province__c='ON',Postal_Code__c = 'L4N', Dealer_Code__c = '397G',City__c = 'Toronto');
        lst_AOR.add(USAOR);
        lst_AOR.add(CANAOR);
        insert lst_AOR;

        // Create two Lead Queues
        List<Group> newLeadQueues = new List<Group>();
        List<Id> groupIds = new List<Id>();
        List<String> dealerCodes = new List<String>();
        
        for(AOR__c a: lst_AOR)
        {
            String dc = a.Dealer_Code__c;
            if(dc.left(1).isNumeric())
            {
                dc='X'+dc;
            }
            dealerCodes.add(dc.trim());  // Just used for Assertion below to check logic of query found in Vgtna_LeadModel
            Group g = new Group(Type='Queue', Name=a.Dealer_Code__c+' - Lead Queue', DeveloperName=dc);
            newLeadQueues.add(g);
        }
        insert newLeadQueues;
        List<Group> g = [Select Id, Name, DeveloperName 
                           From Group 
                           Where DeveloperName In:dealerCodes
                           AND Type='Queue'];        
        System.assertEquals(2, g.size());

        List<QueueSObject> newQueueSObject = new List<QueueSObject>();
        
        for(Group o_g: newLeadQueues)
        {
            QueueSObject q = new QueueSObject(SobjectType='Lead', QueueId=o_g.Id);
            newQueueSObject.add(q);
        }
        
        System.RunAs(runAsUsr)
        {
	        insert newQueueSObject;
            SysIntegrator = new Vgtna_TestBuilder.UserBuilder().setlastName('Test SysIntegrator').setEmail('tstlpSIUser@Email.com.invalid').setProfileId(vgtna_Constants.INTEGRATION_USER_PROFILE).buildAndSave();
        }  
            
            // Insert Leads as System Integrator
        
        Test.startTest();
        System.RunAs(SysIntegrator)
        {
            List<Lead> newSysILeads = new List<Lead>();
            
            Lead l2 = new Lead(LastName = 'Test2', Company = 'Comp2',
                               Email='test12@test.com.invalid',Brand__c = 'Volvo',
                               CountryCode = 'US',PostalCode = '07302');
            newSysILeads.add(l2);
            
            Lead l3 = new Lead(LastName = 'Test3', Company = 'Comp3',
                               Email='test13@test.com.invalid',Brand__c = 'Volvo',
                               CountryCode = 'CA',PostalCode = 'L4N7GS',
                               StateCode = 'ON',City='Toronto');
            newSysILeads.add(l3);
            
            insert newSysILeads;
        }
        
        Test.stopTest();
        List<Lead> leadsWithQueueOwner = [Select Id, OwnerId
                               From Lead
                               Where OwnerId In: newLeadQueues];
        
        System.assertEquals(2, leadsWithQueueOwner.size());
        
    }

    
    
}