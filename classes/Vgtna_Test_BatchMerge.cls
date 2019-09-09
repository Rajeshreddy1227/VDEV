@isTest
public class Vgtna_Test_BatchMerge {
    public static testmethod void batchmerge(){
        User testPartnerUser = new User();
        
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        string dsm = 'District Sales Manager';
        string rfm = 'Regional Fleet Manager';
        string nam = 'National Accounts Manager';
        UserRole r,rP;
        User u,uP;
        
         System.runAs(runAsUsr){
             //Internal users
             rP = new UserRole(DeveloperName = 'RVP', Name = 'Regional Vice President');
        insert rP;
       	r = new UserRole(DeveloperName = 'DSM', Name = 'District Sales Manager',ParentRoleId =rP.id );
		insert r;
       uP = new User(
         //ProfileId = '00ef2000001Y2h3AAC',
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
      u = new User(
         //ProfileId = '00ef2000001Y2h3AAC',
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
        insert u;
              //Accounts
              Account tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('Test ACR PROCESS TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().buildAndSave();
       		 tstDealerAccount.Party_ID_LastModifiedDate__c = System.today();
       		 update tstDealerAccount;
             
             Account tstCustAccount = new Vgtna_TestBuilder.AccountBuilder().setName('SurvivorAccount').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyIdConstant('S1234').setBillingCountryCode('US').setBillingPostalCode('561832323').buildAndSave();
             Account tstCustAccount1 = new Vgtna_TestBuilder.AccountBuilder().setName('VictimAccount').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyIdConstant('V1234').setBillingCountryCode('US').setBillingPostalCode('561832323').buildAndSave();
             tstCustAccount1.Strategic_Account__c = true;
             tstCustAccount1.Mack_National_Account__c = true;
             tstCustAccount1.Volvo_National_Account__c = true;
             tstCustAccount1.Trades__c = true;
             tstCustAccount1.Trade_Cycle_Volvo__c = 'testTrade';
             tstCustAccount1.Industry = 'Manufacturing';
             tstCustAccount1.Mack_Sales_Target_Account__c = true;
             tstCustAccount1.FE_Current_Volvo__c = 23;
             tstCustAccount1.Repair_Shop_Owned__c = true;
             tstCustAccount1.Repair_Shop_Owned_Volvo__c = true;
             tstCustAccount1.Volvo_Sales_Target_Account__c = true;
             tstCustAccount1.Mack_Sales_Target_Account__c = true;
             tstCustAccount1.Daycab__c = 23;
             tstCustAccount1.Daycab_Volvo__c = 32;
             tstCustAccount1.Sleeper__c = 24;
             tstCustAccount1.Sleeper_Volvo__c = 34;
             tstCustAccount1.FE_Goal__c = 12;
             tstCustAccount1.FE_Goal_Volvo__c = 89;
             tstCustAccount1.Trade_Cycle__c = 'TradeCycle';
             tstCustAccount1.Trade_Cycle_Volvo__c = 'Volvo';
             tstCustAccount1.Trades_Volvo__c = true;
             tstCustAccount1.Primary_Make__c = 'Freightliner';
             tstCustAccount1.Primary_Make_Volvo__c = 'Volvo';
             tstCustAccount1.Secondary_Make__c = 'Peterbilt';
             tstCustAccount1.Secondary_Make_Volvo__c = 'Mack';
             
             update tstCustAccount1;
             boolean b = false;
             tstCustAccount.Strategic_Account__c = b;
             tstCustAccount.Mack_National_Account__c = b;
             tstCustAccount.Volvo_National_Account__c = b;
             tstCustAccount.Trades__c = b;
             tstCustAccount.Trades_Volvo__c = b;
             tstCustAccount.Repair_Shop_Owned_Volvo__c = b;
             tstCustAccount.Trade_Cycle_Volvo__c = 'testTrade';
             tstCustAccount.Volvo_Sales_Target_Account__c = b;
             //tstCustAccount.Repair_Shop_Owned__c = b;
             //tstCustAccount.Mack_Sales_Target_Account__c = b;
             //tstCustAccount.Volvo_Sales_Target_Account__c = b;
             update tstCustAccount;
             //Account Team member
             AccountTeamMember newTeam = new AccountTeamMember(AccountId = tstCustAccount1.id,TeamMemberRole = 'District Sales Manager',UserId = u.Id);
        	insert newTeam;
             //Dealer Account
              Account tstDealerAccount1 = new Vgtna_TestBuilder.AccountBuilder().setName('CP Test Dealer Account').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).setDealerCode('5887D').buildAndSave();
             tstDealerAccount.IsPartner = true;                
             update tstDealerAccount;
             //Contacts
             Contact tstContactP = new Vgtna_TestBuilder.ContactBuilder().setLastName(' Partner User').setFirstName('ACR Process').setEmail('testacrp@vive.com.invalid').setAccount(tstDealerAccount).buildAndSave();
             Contact tstContact = new Vgtna_TestBuilder.ContactBuilder().setAccount(tstCustAccount1).setEmail('tst@gm.com').setFirstName('FirstN').setLastName('LastN').buildAndSave();
             //User
             User tstUser = new Vgtna_TestBuilder.UserBuilder().setContact(tstContact).setlastName('Partner User').setEmail(tstContact.Email).setProfileId(vgtna_Constants.DEALER_USER_PROFILE).buildAndSave();   
            tstUser.IsPortalEnabled=true;
            tstUser.Dealer_Brand__c = 'Mack';
            tstUser.Dealer_Code__c = 'A112';
            update tstUser;   
            testPartnerUser = tstUser;	
             
             //Leads
             List<Lead> newPartnerLeads = new List<Lead>();
            
            Lead l1 = new Lead(LastName = 'Test1',IsConverted = true,ConvertedAccountId = tstCustAccount.Id, Company = 'Comp1',Email='test11@test.com.invalid',CountryCode = 'US',PostalCode = '07302', Brand__c = 'Volvo');
            newPartnerLeads.add(l1);
            
            Lead l3 = new Lead(LastName = 'Test3', Company = 'Comp3',
                                   Email='test13@test.com.invalid',Brand__c = 'Volvo',
                               		ConvertedAccountId = tstCustAccount1.Id,
                                   CountryCode = 'CA',PostalCode = 'L4N7GS',
                                   StateCode = 'ON',City='Toronto',IsConverted = true);
            newPartnerLeads.add(l3);
            
            insert newPartnerLeads;
   
  			//Activities
  			Task t = new Task();
            t.WhatId = tstCustAccount1.Id;
            t.Account__c = tstCustAccount1.Id;
            t.OwnerId = testPartnerUser.Id;
            t.Dealer_Code__c = 'A112';
            t.Subject = 'Call';
            t.ActivityDate = System.today();
            insert t;
            Event e = new Event();
            e.WhatId = tstCustAccount1.Id;
            e.Subject = 'New Event';
            e.Account__c = tstCustAccount1.Id;
            e.OwnerId = testPartnerUser.Id;
            e.Dealer_Code__c = 'A112';
            e.Subject = 'Call';
            e.DurationInMinutes= 1440;
            e.IsAllDayEvent = true;
            e.ActivityDate = System.today();
             insert e;
             //Opportunity
             Opportunity oppty = new Opportunity(
            AccountId=tstCustAccount1.Id,
            CloseDate=Date.Today().addDays(7),
            Desired_Delivery_Date__c=Date.Today().addDays(7),
            Brand__c = vgtna_Constants.VOLVO_BRAND,
            Name='TestTheOppty',
            OwnerId=testPartnerUser.Id,
            StageName='Identify',
            Partner_Account__c= tstDealerAccount.Id,
            Invite_Sales_Team__c=false);
              insert oppty;
             //Customer Profile.
            // Account acc = [Select id from Account where name= 'CustomerProfileTest' limit 1];
             Account accDealer = [Select id from Account where Dealer_Code__c = '5887D' limit 1];
             Customer_Profile__c CP = new Customer_Profile__c(Customer_Account__c = tstCustAccount1.id,
                                                             Dealer_Account__c = accDealer.Id);
             insert cp;
  			//Merge
             Merge__c m = new Merge__c();
             m.SurvivorPartyId__c = 'S1234';
             m.VictimPartyId__c = 'V1234';
             m.Status__c = 'To Be Processed';
             insert m;
             
         }
        System.runAs(runAsUsr){            
            Vgtna_PopulateMergeObj.getAccDetails(); 
            Vgtna_PopulateMergeObjONETIMELOAD.getAccDetailsOTL();
         }
    }
}