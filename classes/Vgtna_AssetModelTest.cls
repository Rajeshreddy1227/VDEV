@isTest
public class Vgtna_AssetModelTest {
	static testMethod void ProcessAssetTest()
    {
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        User SystemAccountOwner = new User();
        User testPartnerUser = new User();
        
        System.RunAs(runAsUsr){
        	// Create a System User to own the customer and partner accounts
            User SystemAcctOwner = new Vgtna_TestBuilder.UserBuilder().setlastName('Account Owner').setEmail('tstUser@Email.com.invalid').setProfileId('System Integrator').buildAndSave();
            SystemAcctOwner.UserRoleId=[Select Id From UserRole Where name='System Partner Role' Limit 1].Id;
            update SystemAcctOwner;
            SystemAccountOwner = SystemAcctOwner;
        }

        // Create the Dealer Account
        Account tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('ADVANTAGE TRUCK CENTER').setRecordType('Dealer').setDealerCode('5571D').buildAndSave();
        tstDealerAccount.IsPartner = true;
        // Set owner to System User
        tstDealerAccount.OwnerId=SystemAccountOwner.Id;
        system.debug('*** Account: '+tstDealerAccount);
        update tstDealerAccount;
        
        // Create the Contact 
        Contact tstContact = new Vgtna_TestBuilder.ContactBuilder().setLastName('Partner User').setFirstName('Test').setEmail('test@aol.com.invalid').setAccount(tstDealerAccount).buildAndSave();
        system.debug('*** contact '+tstContact);
        
        // Create the Partner User
        System.RunAs(runAsUsr){
            
            User tstUser = new Vgtna_TestBuilder.UserBuilder().setContact(tstContact).setlastName('Partner User').setEmail(tstContact.Email).setProfileId(vgtna_Constants.DEALER_USER_PROFILE).buildAndSave();
    
            tstUser.IsPortalEnabled=true;
            tstUser.UserRoleId=[Select Id from UserRole Where PortalAccountId=:tstDealerAccount.Id And PortalRole='Worker' Limit 1].Id;
            update tstUser;
            testPartnerUser = tstUser;
        }
        
        system.debug('**** setup account owner '+SystemAccountOwner);

        AccountContactRelation acr = [select id, accountid, contactid,roles
                                      from AccountContactRelation
                                      where accountid=: tstDealerAccount.Id
                                      and contactid=: tstContact.id limit 1];
        if(acr != null)
        {
            acr.roles = 'Volvo Sales Manager';
            update acr;
        }
        
		// Setup AOR data
		
        List<AOR__c> aor = new List<AOR__c>();
        
		aor.add(New AOR__c(
        	Brand__c=vgtna_Constants.VOLVO_BRAND,
            Country__c='US',
            Dealer_Code__c = '5571D',
            Postal_Code__c='56183'
        ));
        
		aor.add(New AOR__c(
        	Brand__c=vgtna_Constants.MACK_BRAND,
            Country__c='US',
            Dealer_Code__c = 'F243',
            Postal_Code__c='79230'
        ));
        
		aor.add(New AOR__c(
        	Brand__c=vgtna_Constants.MACK_BRAND,
            Country__c='CA',
            Dealer_Code__c = 'N971',
            Postal_Code__c='S0H',
            City__c='VICEROY',
            State_Province__c = 'AB'
        ));

		aor.add(New AOR__c(
        	Brand__c=vgtna_Constants.VOLVO_BRAND,
            Country__c='CA',
            Dealer_Code__c = '2747K',
            Postal_Code__c='TOG',
            City__c='CLYDE',
            State_Province__c = 'SK'
        ));

        insert aor;
        System.debug('**** aor for test :'+aor);
        Set<Id> acctIds = new Set<Id>();
        
        // Setup the Customer Accounts
        Account tstCustAccount = new Vgtna_TestBuilder.AccountBuilder().setName('FedExTest').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().setBillingCountryCode('US').setBillingPostalCode('561832323').buildAndSave();
		acctIds.add(tstCustAccount.Id);
        Account tstCustAccount1 = new Vgtna_TestBuilder.AccountBuilder().setName('FedExTest1').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().setBillingCountryCode('US').setBillingPostalCode('79230').buildAndSave();
		acctIds.add(tstCustAccount1.Id);

        Account tstCustAccount2 = new Vgtna_TestBuilder.AccountBuilder().setName('FedExTest2').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().setBillingCountryCode('CA').setBillingPostalCode('S0HYTR').setBillingCity('VICEROY').setBillingStateCode('AB').buildAndSave();
		acctIds.add(tstCustAccount2.Id);

        Account tstDealerAccount2 = new Vgtna_TestBuilder.AccountBuilder().setName('ADVANTAGE TRUCK CENTER').setRecordType('Dealer').setDealerCode('2747K').buildAndSave();
        tstDealerAccount2.IsPartner = true;
        // Set owner to System User
        tstDealerAccount2.OwnerId=SystemAccountOwner.Id;
        system.debug('*** Account: '+tstDealerAccount);
        update tstDealerAccount2;

        Contact tstContactManager = new Vgtna_TestBuilder.ContactBuilder().setLastName('Partner Manager').setFirstName('Test').setEmail('testmanager@aol.com.invalid').setAccount(tstDealerAccount2).buildAndSave();

        // Create the Partner User
        System.RunAs(runAsUsr){
            
            User tstUser = new Vgtna_TestBuilder.UserBuilder().setContact(tstContactManager).setlastName('Partner User').setEmail(tstContact.Email).setProfileId(vgtna_Constants.DEALER_USER_PROFILE).buildAndSave();
    
            tstUser.IsPortalEnabled=true;
            tstUser.UserRoleId=[Select Id from UserRole Where PortalAccountId=:tstDealerAccount2.Id And PortalRole='Worker' Limit 1].Id;
            update tstUser;
            testPartnerUser = tstUser;
        }
        AccountContactRelation acr2 = [select id, accountid, contactid,roles
                                      from AccountContactRelation
                                      where accountid=: tstDealerAccount2.Id
                                      and contactid=: tstContactManager.id limit 1];
        if(acr2 != null)
        {
            acr2.roles = 'Volvo Sales Rep';
            update acr;
        }

        Test.startTest();

        Account tstCustAccount3 = new Vgtna_TestBuilder.AccountBuilder().setName('FedExTest3').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().buildAndSave();

		Asset oAsset2 = new Asset(
        	AccountId=tstCustAccount3.Id,
            brand__c='Volvo',
            Buying_Customer__c=tstCustAccount3.Id,
            Name='testAsset',
            PurchaseDate=Date.today(),
            Ship_To_Dealer__c=tstDealerAccount2.Id,
            Seller_Dealer_Code__c=tstDealerAccount2.Dealer_Code__c
        );
        System.RunAs(SystemAccountOwner){
	        insert oAsset2;
        }

        Test.stopTest();
    }
}