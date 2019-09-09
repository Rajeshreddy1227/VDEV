@isTest
public class Vgtna_OppRecordTypeSelControllerTest {
	static testMethod void TestController()
    {
        User usr = Vgtna_OppRecordTypeSelectorController.fetchUser();
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
        }
        Account tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('ADVANTAGE TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).setDealerCode('5889D').buildAndSave();
        tstDealerAccount.IsPartner = true;
        // Set owner to System User
        tstDealerAccount.OwnerId=SystemAccountOwner.Id;
		
		Account retAcct = Vgtna_OppRecordTypeSelectorController.getAccount(tstDealerAccount.Id);

        Account tstCustAccount = new Vgtna_TestBuilder.AccountBuilder().setName('FedExTest').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().buildAndSave();
        tstCustAccount.OwnerId=SystemAccountOwner.Id;
        update tstCustAccount;

        
        // Create the Contact that will be converted into the Partner User
        Contact tstContact = new Vgtna_TestBuilder.ContactBuilder().setLastName('Partner User').setFirstName('Test').setEmail('test@aol.com').setAccount(tstDealerAccount).buildAndSave();
        system.debug('*** contact '+tstContact);
        
        // Create the Partner User
        System.RunAs(runAsUsr){
            
            User tstUser = new Vgtna_TestBuilder.UserBuilder().setContact(tstContact).setlastName('Partner User').setEmail(tstContact.Email).setProfileId(vgtna_Constants.DEALER_USER_PROFILE).buildAndSave();
            
            tstUser.IsPortalEnabled=true;
            tstUser.UserRoleId=[Select Id 
                                From UserRole 
                                Where PortalAccountId=:tstDealerAccount.Id 
                                And PortalRole='Manager' Limit 1].Id;
            update tstUser;
            testPartnerUser = tstUser;
        }
        
        System.RunAs(runAsUsr){
            
            User DSMUser = new Vgtna_TestBuilder.UserBuilder().setlastName('DSM User').setEmail(tstContact.Email).setProfileId(vgtna_Constants.MACK_INTERNAL_USER_PROFILE).buildAndSave();
            
            DSMUser.UserRoleId=[Select Id 
                                From UserRole 
                                Where DeveloperName =:vgtna_Constants.MACK_DSM_ROLE Limit 1].Id;
            update DSMUser;
            system.debug('*** DSM user '+DSMUser);
            tstDSMUser = DSMUser;
        }  
        
		List<RecordType> lRt = Vgtna_OppRecordTypeSelectorController.getListOfRecordType(testPartnerUser);
        List<RecordType> lRt2 = Vgtna_OppRecordTypeSelectorController.getListOfRecordType(tstDSMUser);
        
        //id retOptyId = Vgtna_OppRecordTypeSelectorController.getOpportunityRecordType();
        Boolean bR = Vgtna_OppRecordTypeSelectorController.isCommunity();
    }
}