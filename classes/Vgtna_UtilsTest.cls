@isTest
public class Vgtna_UtilsTest {
	static testMethod void TestQueueMembership()
    {
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        User SystemAccountOwner = new User();
        User testPartnerUser = new User();
        User tstDSMUser = new User();
        
        System.RunAs(runAsUsr){
            // Create a System User to own the customer and partner accounts
            User SystemAcctOwner = new Vgtna_TestBuilder.UserBuilder().setlastName('Account Owner').setEmail('tstUser@Email.com').setProfileId(vgtna_Constants.INTEGRATION_USER_PROFILE).buildAndSave();
            SystemAcctOwner.UserRoleId=[Select Id From UserRole Where DeveloperName=:vgtna_Constants.SYSTEM_PARTNER_ROLE Limit 1].Id;
            update SystemAcctOwner;
            SystemAccountOwner = SystemAcctOwner;

            system.debug('**** setup account owner '+SystemAccountOwner);
            
            // Create the Dealer Account
            Account tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('ADVANTAGE TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).setDealerCode('5889D').buildAndSave();
            tstDealerAccount.IsPartner = true;
            // Set owner to System User
            tstDealerAccount.OwnerId=SystemAccountOwner.Id;
            system.debug('*** Account: '+tstDealerAccount);
            update tstDealerAccount;
            
            // Create the Contact that will be converted into the Partner User
            Contact tstContact = new Vgtna_TestBuilder.ContactBuilder().setLastName('Partner User').setFirstName('Test').setEmail('test@aol.com').setAccount(tstDealerAccount).buildAndSave();
            system.debug('*** contact '+tstContact);
    
            User tstUser = new Vgtna_TestBuilder.UserBuilder().setContact(tstContact).setlastName('Partner Manager').setEmail(tstContact.Email).setProfileId(vgtna_Constants.DEALER_USER_PROFILE).buildAndSave();
            
            tstUser.IsPortalEnabled=true;
            tstUser.UserRoleId=[Select Id 
                                From UserRole 
                                Where PortalAccountId=:tstDealerAccount.Id 
                                And PortalRole='Manager' Limit 1].Id;
            update tstUser;
            testPartnerUser = tstUser;
        }

        
        system.debug('*** testPartnerUser '+testPartnerUser+' AND isPartner: '+testPartnerUser.IsPortalEnabled);
        // Create Groups
        Group g1 = new Group(Name ='5889D- Lead Queue', Type= 'Queue');
        insert g1;
            
        Vgtna_Utils.ProcessLeadQueueMembership();
        
    }
}