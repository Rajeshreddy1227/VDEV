@isTest
public class Vgtna_FetchMgmtGrpUsersTest {
	public static testMethod void FetchMgmtGrpUsersTest()
    {User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        User SystemAccountOwner = new User();
        string rfm = 'Regional Fleet Manager';
        string nam = 'National Accounts Manager';
        UserRole r,rP;
        User uDSM,uP;       
        
    System.RunAs(runAsUsr)
    {
        // Create a System User to own the customer and partner accounts
        User SystemAcctOwner = new Vgtna_TestBuilder.UserBuilder().setlastName('Account Owner').setEmail('tstUser@Email.com.invalid').setProfileId('System Integrator').buildAndSave();
        SystemAcctOwner.UserRoleId=[Select Id From UserRole Where name='System Partner Role' Limit 1].Id;
        update SystemAcctOwner;
        SystemAccountOwner = SystemAcctOwner;
        
      
        rP = new UserRole(DeveloperName = 'RVP', Name = 'Regional Vice President');
        insert rP;
        r = new UserRole(DeveloperName = 'DSM', Name = 'District Sales Manager',ParentRoleId =rP.id );
        insert r;
       	uP = new User(
            ProfileId = [select id from profile where name ='Mack Sales Rep'].id,
            LastName = 'lastname',
            Email = 'lastfirst@lastnamefirstname.com',
            Username = 'lastfirst@lastnamefirstname.com' + System.currentTimeMillis(),
            CompanyName = 'Volvo Trucks',
            Title = 'DSM',
            Alias = 'DSM',
            Dealer_Brand__c = 'Mack',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = rP.Id
		);
        insert uP;  
      	uDSM = new User(
            ProfileId = [select id from profile where name ='Mack Sales Rep'].id,
            LastName = 'lastname',
            Email = 'lastfirst@lastnamefirstname.com',
            Username = 'lastfirst@lastnamefirstname.com' + System.currentTimeMillis(),
            CompanyName = 'Volvo Trucks',
            Title = 'DSM',
            Alias = 'DSM',
            Dealer_Brand__c = 'Mack',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = r.Id
		);
        insert uDSM;
        }
        List<Territory2> t2List = new List<Territory2>();

        Territory2 oNode = [Select Id, Name, Territory2TypeId, Territory2ModelId 
                 From Territory2 
                 Where DeveloperName = : vgtna_Constants.AOR_TERRITORY 
                 And Territory2Model.State='Active' Limit 1 ];
        System.debug('Territory Node: '+oNode.Name);

        t2List.add(new Territory2(
            AccountAccessLevel='Read',
            CaseAccessLevel='None',
            ContactAccessLevel='None',
            Dealer_Code__c = '55711D',
            DeveloperName='X5571D_AOR_test',
            Name='5571D- AOR',
            OpportunityAccessLevel='None',
            ParentTerritory2Id=oNode.Id,
            Territory2ModelId=oNode.Territory2ModelId,
            Territory2TypeId=oNode.Territory2TypeId
        ));         

        t2List.add(new Territory2(
            AccountAccessLevel='Read',
            CaseAccessLevel='None',
            ContactAccessLevel='None',
            Dealer_Code__c = 'F2431',
            DeveloperName='F243_AOR_test',
            Name='F243- AOR',
            OpportunityAccessLevel='None',
            ParentTerritory2Id=oNode.Id,
            Territory2ModelId=oNode.Territory2ModelId,
            Territory2TypeId=oNode.Territory2TypeId
        ));   
        
         t2List.add(new Territory2(
            AccountAccessLevel='Read',
            CaseAccessLevel='None',
            ContactAccessLevel='None',
            Dealer_Code__c = 'N9711',
            DeveloperName='N971_AOR_test',
            Name='N971- AOR',
            OpportunityAccessLevel='None',
            ParentTerritory2Id=oNode.Id,
            Territory2ModelId=oNode.Territory2ModelId,
            Territory2TypeId=oNode.Territory2TypeId
        ));         
        t2List.add(new Territory2(
            AccountAccessLevel='Read',
            CaseAccessLevel='None',
            ContactAccessLevel='None',
            Dealer_Code__c = '2747K1',
            DeveloperName='X2747K_AOR_test',
            Name='2747K- AOR',
            OpportunityAccessLevel='None',
            ParentTerritory2Id=oNode.Id,
            Territory2ModelId=oNode.Territory2ModelId,
            Territory2TypeId=oNode.Territory2TypeId
        ));         
		 
        System.RunAs(runAsUsr){
            insert t2List;
        }
        List<AOR__c> aor = new List<AOR__c>();
        
        aor.add(New AOR__c(
            Brand__c=vgtna_Constants.VOLVO_BRAND,
            Country__c='US',
            Dealer_Code__c = '55711D',
            Postal_Code__c='56183'
        ));
        
        aor.add(New AOR__c(
            Brand__c=vgtna_Constants.MACK_BRAND,
            Country__c='US',
            Dealer_Code__c = 'F2431',
            Postal_Code__c='79230'
        ));
        
        aor.add(New AOR__c(
            Brand__c=vgtna_Constants.MACK_BRAND,
            Country__c='CA',
            Dealer_Code__c = 'N9711',
            Postal_Code__c='S0H',
            City__c='VICEROY',
            State_Province__c = 'AB'
        ));

        aor.add(New AOR__c(
            Brand__c=vgtna_Constants.VOLVO_BRAND,
            Country__c='CA',
            Dealer_Code__c = '2747K1',
            Postal_Code__c='TOG',
            City__c='CLYDE',
            State_Province__c = 'SK'
        ));

        insert aor;
        
        Set<String> acctIds = new Set<String>();
     	
        // Setup the Customer Accounts
        Account tstCustAccount = new Vgtna_TestBuilder.AccountBuilder().setName('FedExTest').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().setBillingCountryCode('US').setBillingPostalCode('561832323').buildAndSave();
        acctIds.add(tstCustAccount.Id);
        Account tstCustAccount1 = new Vgtna_TestBuilder.AccountBuilder().setName('FedExTest1').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().setBillingCountryCode('US').setBillingPostalCode('79230').buildAndSave();
        acctIds.add(tstCustAccount1.Id);
        Account tstCustAccount2 = new Vgtna_TestBuilder.AccountBuilder().setName('FedExTest2').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().setBillingCountryCode('CA').setBillingPostalCode('S0HYTR').setBillingCity('VICEROY').setBillingStateCode('AB').buildAndSave();
        acctIds.add(tstCustAccount2.Id);
        Account tstCustAccount3 = new Vgtna_TestBuilder.AccountBuilder().setName('FedExTest3').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().setBillingCountryCode('CA').setBillingPostalCode('TOG').setBillingCity('CLYDE').setBillingStateCode('SK').buildAndSave();
        acctIds.add(tstCustAccount3.Id);
        
        //Dealer Accounts (Mgmt Grp)
        Account tstDealerAccount1 = new Vgtna_TestBuilder.AccountBuilder().setName('ADVANTAGE TRUCK CENTER MGMT').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).buildAndSave();
        tstDealerAccount1.IsPartner = true;
        update tstDealerAccount1;
        //Dealer Account 
     	Account tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('ADVANTAGE TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).setDealerCode('55711D').setBrand('Volvo').buildAndSave();
        tstDealerAccount.IsPartner = true;
        tstDealerAccount.ParentId = tstDealerAccount1.Id;
        update tstDealerAccount;
        
        //Contacts 
        Contact tstContact = new Vgtna_TestBuilder.ContactBuilder().setLastName('Partner User').setFirstName('Test').setEmail('test@aol.com.invalid').setAccount(tstDealerAccount1).buildAndSave();
        Contact tstContact1 = new Vgtna_TestBuilder.ContactBuilder().setLastName('Partner User1').setFirstName('Test').setEmail('test1@aol.com.invalid').setAccount(tstDealerAccount1).buildAndSave();
        
        System.runAs(runAsUsr) 
        {   
            UserRole upartnerMan,upartnerMan1;

            Test.startTest();            
            Contact con = [SELECT Id, Name, Email FROM Contact where Email = 'test@aol.com.invalid' LIMIT 1];
            Contact con1 = [SELECT Id, Name, Email FROM Contact where Email = 'test1@aol.com.invalid' LIMIT 1];
          
            User u = new Vgtna_TestBuilder.UserBuilder().setlastName('Volvo User').setEmail('test@aol.com.invalid').setProfileId('Dealer Admin').setBrand('Volvo').setContact(con).buildAndSave();    
            u.Dealer_Code__c = '55711D';
            u.UserRoleId = [Select Id From UserRole Where Name like '%Executive%' Limit 1].id;            
            u.IsPortalEnabled = true;
            update u;
  	          
            User u1 = new Vgtna_TestBuilder.UserBuilder().setlastName('Volvo User1').setEmail('test1@aol.com.invalid').setProfileId('Dealer Admin').setBrand('Volvo').setContact(con1).buildAndSave();    
            u1.Dealer_Code__c = '55711D';
            u1.IsPortalEnabled = true;
            update u1;
            
            User u2 = new Vgtna_TestBuilder.UserBuilder().setlastName('Internal Volvo User').setEmail('testInt@aol.com.invalid').setProfileId('Volvo Sales Rep').setBrand('Volvo').setRoleId('US - Southeast Volvo District Sales Manager').buildAndSave();    
        }
    
        User u = [SELECT Id, Name, Dealer_Code__c, Email FROM User WHERE Dealer_Code__c = '55711D' and Email = 'test@aol.com.invalid' LIMIT 1];
        User u1 = [SELECT Id, Name, Dealer_Code__c, Email FROM User WHERE Dealer_Code__c = '55711D' and Email = 'test1@aol.com.invalid' LIMIT 1];
        User u2 = [SELECT Id, Name, Dealer_Code__c, Email FROM User WHERE LastName = 'Internal Volvo User' AND Email = 'testInt@aol.com.invalid' LIMIT 1];
        //Test.stopTest();   
        
        List<Assigned_Sales_Rep__c> asrList = new List<Assigned_Sales_Rep__c>();
        Assigned_Sales_Rep__c asr1 = new Assigned_Sales_Rep__c();
        asr1.Account__c = tstCustAccount1.Id;
        asr1.Sales_Rep__c = u.Id;
        asr1.Dealer_Code__c = '55711D';
        asrList.add(asr1);
        
        Assigned_Sales_Rep__c asr2 = new Assigned_Sales_Rep__c();
        asr1.Account__c = tstCustAccount2.Id;
        asr1.Sales_Rep__c = u.Id;
        asr1.Dealer_Code__c = '55711D';
        asrList.add(asr2);
        
        Assigned_Sales_Rep__c asr4 = new Assigned_Sales_Rep__c();
        asr1.Account__c = tstCustAccount.Id;
        asr1.Sales_Rep__c = u.Id;
        asr1.Dealer_Code__c = '55711D';
        asrList.add(asr4);
        
        // insert asrList;
        List<ObjectTerritory2Association> testRes = [Select Id 
                                                     From ObjectTerritory2Association
                                                     Where ObjectId  In :acctIds];
        System.debug(testRes.size());
        // System.assertEquals(4, testRes.size());
        
        
        AccountContactRelation acr = new AccountContactRelation(contactId = tstContact.Id, Roles = 'Sales Manager', AccountId=tstDealerAccount.Id);
        insert acr;

         // Fetch the ACR already created on adding a contact to the dealer account and work on edit and delete scenarios
        //Test.startTest();
		acr = [select id, accountid, contactid,roles
                                      from AccountContactRelation
                                      where accountid=: tstDealerAccount.Id
                                      and contactid=: tstContact.id limit 1];
		Test.stopTest();
        if(acr != null)
        {
            acr.roles = 'Volvo Sales Manager';
            update acr;
        }
        
        // Setup an Opportunity on the Customer Account
        Opportunity oppty = new Opportunity(
            AccountId=tstCustAccount.Id,
            CloseDate=Date.Today().addDays(7),
            Desired_Delivery_Date__c=Date.Today().addDays(7),
            //Estimated_Quantity__c=2,
            Brand__c = vgtna_Constants.VOLVO_BRAND,
            Name='TestTheOppty',
            OwnerId=u.Id,
            StageName='Identify',
            Invite_Sales_Team__c=false
        );
        insert oppty;
        string optyId = oppty.id;
        
        Opportunity oppty1 = new Opportunity(
            AccountId=tstCustAccount.Id,
            CloseDate=Date.Today().addDays(7),
            Desired_Delivery_Date__c=Date.Today().addDays(7),
            //Estimated_Quantity__c=2,
            Brand__c = vgtna_Constants.VOLVO_BRAND,
            Name='TestTheOppty1',
            OwnerId=u.Id,
            StageName='Identify',
            Partner_Account__c= tstDealerAccount.Id,
            Invite_Sales_Team__c=false
        );
        insert oppty1;
        string optyId1 = oppty1.id;

		Opportunity oppty2 = new Opportunity(
		 AccountId=tstCustAccount.Id,
		 CloseDate=Date.Today().addDays(7),
		 Desired_Delivery_Date__c=Date.Today().addDays(7),
		 Brand__c = vgtna_Constants.VOLVO_BRAND,
		 Name='TestTheOppty2',
		 OwnerId=u2.Id,
		 StageName='Identify',
		 Dealer_Code_Credited_To__c = '55711D',
		 Invite_Sales_Team__c=false
		);
		insert oppty2;
		string optyId2 = oppty2.id;

        System.runAs(u) 
        {
            Vgtna_FetchMgmtGrpUsers.getMgmtUsers(optyId);
            List<string> s = new List<string>();
            s.add(u1.id);
            s.add(u.id);
            Vgtna_FetchMgmtGrpUsers.addOptyTeam(optyId, s);
        }
         System.runAs(u2)
         {
             Vgtna_FetchMgmtGrpUsers.getMgmtUsers(optyId2);
             List<string> s2 = new List<string>();
             s2.add(u1.id);
             //Vgtna_FetchMgmtGrpUsers.addOptyTeam(optyId2, s2);
         }
    }
}