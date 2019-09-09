@isTest
public class Vgtna_ContactModelTest {
	static testMethod void ProcessContactTest()
    {

        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        User SystemAccountOwner = new User();
        User testPartnerUser = new User();
        Contact FleetSeekContact = new Contact();

        
        System.RunAs(runAsUsr){
        	// Create a System User to own the customer and partner accounts
            User SystemAcctOwner = new Vgtna_TestBuilder.UserBuilder().setlastName('Account Owner').setEmail('tstUser@Email.com.invalid').setProfileId('System Integrator').buildAndSave();
            SystemAcctOwner.UserRoleId=[Select Id From UserRole Where name='System Partner Role' Limit 1].Id;
            update SystemAcctOwner;
            SystemAccountOwner = SystemAcctOwner;
        }
        
        system.debug('**** setup account owner '+SystemAccountOwner);
    
        // Setup the Customer Account 
        Account tstCustAccount = new Vgtna_TestBuilder.AccountBuilder().setName('FedExTest').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().buildAndSave();
		tstCustAccount.OwnerId=SystemAccountOwner.Id;
        update tstCustAccount;
    
        // Create the Dealer Account
        Account tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('ADVANTAGE TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).setDealerCode('5889D').buildAndSave();
        tstDealerAccount.IsPartner = true;
        // Set owner to System User
        tstDealerAccount.OwnerId=SystemAccountOwner.Id;
        system.debug('*** Account: '+tstDealerAccount);
        update tstDealerAccount;
        
        // Create the Contact that will be converted into the Partner User
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
        system.debug('*** testPartnerUser '+testPartnerUser+' AND isPartner: '+testPartnerUser.IsPortalEnabled);
		
        // Create a contact under the customer account and set owner System user and Source to Fleetseek
        
        System.RunAs(SystemAccountOwner)
        {
	        Contact FleetSeekCon = new Vgtna_TestBuilder.ContactBuilder().setLastName('Corporate').setFirstName('Contact').setEmail('test@aol2.com.invalid').setAccount(tstCustAccount).buildAndSave();
            FleetSeekCon.Source__c = vgtna_Constants.FLEETSEEK_CONTACT_SOURCE;
            update FleetSeekCon;
            FleetSeekContact = FleetSeekCon;
        }
        
		Contact testRes = [Select Id, Source__c, Corporate_Lookup__c, Non_Corporate_Contact__c From Contact Where Id = :FleetSeekContact.Id];
        System.assertEquals(vgtna_Constants.FLEETSEEK_CONTACT_SOURCE.Trim(), testRes.Source__c.Trim());
        System.AssertEquals(testRes.Corporate_Lookup__c, tstCustAccount.Id);
        System.AssertEquals(testRes.Non_Corporate_Contact__c, null);

        Contact testRes2 = new Contact();
        
        testRes2 = FleetSeekContact.clone(false, false, false, false);
		insert testRes2;
        
        testRes2.OwnerId = testPartnerUser.Id;
        update testRes2;
        List<Contact> testList = new List<Contact>();
        testList.add(testRes2);
        Vgtna_ContactModel.assignSource(testList, null, true);
        
        System.assertEquals(vgtna_Constants.DEALER_CONTACT_SOURCE.Trim(), testRes2.Source__c.Trim());
        System.AssertEquals(testRes2.Corporate_Lookup__c, null);
        System.AssertEquals(testRes2.Non_Corporate_Contact__c, tstCustAccount.Id);
    
    }
}