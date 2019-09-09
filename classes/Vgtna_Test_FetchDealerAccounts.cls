@isTest
public class Vgtna_Test_FetchDealerAccounts {
    public static testmethod void FetchDealerAccountsMethod1() { 
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        User SystemAccountOwner = new User();

        System.RunAs(runAsUsr){
            // Create a System User to own the customer and partner accounts
            User SystemAcctOwner = new Vgtna_TestBuilder.UserBuilder().setlastName('Account Owner').setEmail('tstUser@Email.com.invalid').setProfileId('System Integrator').buildAndSave();
            SystemAcctOwner.UserRoleId=[Select Id From UserRole Where name='System Partner Role' Limit 1].Id;
            update SystemAcctOwner;
            SystemAccountOwner = SystemAcctOwner;
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
        Account tstDealerAccount1 = new Vgtna_TestBuilder.AccountBuilder().setName('ADVANTAGE TRUCK CENTER MGMT').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).buildAndSave();
        tstDealerAccount1.IsPartner = true;
        update tstDealerAccount1;
        Account tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('ADVANTAGE TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).setDealerCode('55711D').buildAndSave();
        tstDealerAccount.IsPartner = true;
        tstDealerAccount.ParentId = tstDealerAccount1.Id;
        update tstDealerAccount;
        Contact tstContact = new Vgtna_TestBuilder.ContactBuilder().setLastName('Partner User').setFirstName('Test').setEmail('test@aol.com.invalid').setAccount(tstDealerAccount1).buildAndSave();
        Contact tstContact1 = new Vgtna_TestBuilder.ContactBuilder().setLastName('Partner User1').setFirstName('Test').setEmail('test1@aol.com.invalid').setAccount(tstDealerAccount1).buildAndSave();
        Contact tstContact2 = new Vgtna_TestBuilder.ContactBuilder().setLastName('Partner User2').setFirstName('Test').setEmail('test2@aol.com.invalid').setAccount(tstDealerAccount1).buildAndSave();
        System.runAs(runAsUsr) {
            Contact con = [SELECT Id, Name, Email FROM Contact where Email = 'test@aol.com.invalid' LIMIT 1];
            Contact con1 = [SELECT Id, Name, Email FROM Contact where Email = 'test1@aol.com.invalid' LIMIT 1];
            Contact con2 = [SELECT Id, Name, Email FROM Contact where Email = 'test2@aol.com.invalid' LIMIT 1];
            User u = new Vgtna_TestBuilder.UserBuilder().setlastName('Volvo User').setEmail('tstUser@Email.com.invalid').setProfileId('Dealer Admin').setBrand('Volvo').setContact(con).buildAndSave();    
            
            u.Dealer_Code__c = '55711D';
            update u;
            User u1 = new Vgtna_TestBuilder.UserBuilder().setlastName('Volvo User1').setEmail('tstUser1@Email.com.invalid').setProfileId('Dealer Admin').setBrand('Volvo').setContact(con1).buildAndSave();    
            u1.Dealer_Code__c = '55711D';
            u1.User_Id__c = 'A312322';
            update u1;
            User u2 = new Vgtna_TestBuilder.UserBuilder().setlastName('Volvo User1').setEmail('tstUser2@Email.com.invalid').setProfileId('Dealer Admin').setBrand('Volvo').setContact(con2).buildAndSave();    
            u2.Dealer_Code__c = '55711D';
            update u2;
        }
        User u = [SELECT Id, Name, Dealer_Code__c, Email FROM User WHERE Dealer_Code__c = '55711D' and Email = 'tstUser@Email.com.invalid' LIMIT 1];
        User u1 = [SELECT Id, Name, Dealer_Code__c, Email FROM User WHERE Dealer_Code__c = '55711D' and Email = 'tstUser1@Email.com.invalid' LIMIT 1];
        User u2 = [SELECT Id, Name, Dealer_Code__c, Email FROM User WHERE Dealer_Code__c = '55711D' and Email = 'tstUser2@Email.com.invalid' LIMIT 1];
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
        
      /*  Assigned_Sales_Rep__c asr3 = new Assigned_Sales_Rep__c();
        asr1.Account__c = tstCustAccount3.Id;
        asr1.Sales_Rep__c = u.Id;
        asr1.Dealer_Code__c = '55711D';
        asrList.add(asr3);*/
        
        Assigned_Sales_Rep__c asr4 = new Assigned_Sales_Rep__c();
        asr1.Account__c = tstCustAccount.Id;
        asr1.Sales_Rep__c = u.Id;
        asr1.Dealer_Code__c = '55711D';
        asrList.add(asr4);
        
        insert asrList;
        List<ObjectTerritory2Association> testRes = [Select Id 
                                                     From ObjectTerritory2Association
                                                     Where ObjectId  In :acctIds];
        System.debug(testRes.size());
        System.assertEquals(4, testRes.size());
        
        AccountContactRelation acr = new AccountContactRelation(contactId = tstContact.Id, Roles = 'Sales Manager', AccountId=tstDealerAccount.Id);
        insert acr;
        test.startTest();
        System.runAs(u) {
            List<Assigned_Sales_Rep__c> asrs = [SELECT Id FROM Assigned_Sales_Rep__c];
            Vgtna_FetchDealerAccountsNew.allAccounts(null, null, null, null, 'All Assigned Accounts', true, true, 5, null, null, new List<String>(acctIds), null, null, null, null, new List<String>(acctIds), null, null);
            Vgtna_FetchDealerAccountsNew.deleteASR(new List<String>{asr4.Id}, false, null, null, null, null, 'All Assigned Accounts');
            Vgtna_FetchDealerAccountsNew.loadUnAssignedAccounts(true, null, null, null, null, new List<String>{tstCustAccount3.Id}, null, null);
            Vgtna_FetchDealerAccountsNew.getSelectedASR(null, null, null, null, u.Id ,null,true, null);
            Vgtna_FetchDealerAccountsNew.getACHUsers();
            Vgtna_FetchDealerAccountsNew.getFetchDealerSalesReps('55711D');
            Vgtna_FetchDealerACHUsers.getACHUsers();
            Vgtna_FetchDealerACHUsers.ReAssignSalesReps(u1.Id, new List<String>(), null, null, null, null, null, true);
            Vgtna_FetchDealerACHUsers.insertASR(u1.Id, new List<String>{tstCustAccount3.Id});
            Vgtna_FetchDealerACHUsers.insertAllASR(u.Id, 'CLYDE', 'All Assigned Accounts', null, 'TOG', 'FED', null, new List<String>{tstCustAccount3.Id});
            Vgtna_FetchDealerAccountsNew.exportSRAccounts(null, null, null, 'FedEx', u.Id);
            Vgtna_FetchDealerAccountsNew.exportAssignedAccounts(null, null, null, 'FedEx', 'All Assigned Accounts');
        }
        test.stopTest();
    }
}