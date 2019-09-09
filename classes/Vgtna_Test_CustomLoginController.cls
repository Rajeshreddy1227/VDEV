/**********************************************************************
 Name:  Vgtna_Test_CustomLoginController()
 Copyright © 2018  Salesforce
 ======================================================
======================================================
Purpose: Test Class for Vgtna_CustomLoginController                                                           
-------                                                            
======================================================
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL            Description
   1.0    Subho        10/01/2018      INITIAL DEVELOPMENT          US251 
***********************************************************************/
@isTest
private class Vgtna_Test_CustomLoginController {

    static testMethod void testfetchUser()
    {
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        User SystemAccountOwner = new User();
        User testPartnerUser = new User();
        
        System.RunAs(runAsUsr){
        	// Create a System User to own the customer and partner accounts
            User SystemAcctOwner = new Vgtna_TestBuilder.UserBuilder().setlastName('Account Owner').setEmail('tstUser@Email.com.invalid').setProfileId(vgtna_Constants.INTERNAL_USER_PROFILE).buildAndSave();
            SystemAcctOwner.UserRoleId=[Select Id From UserRole Where name='System Partner Role' Limit 1].Id;
            update SystemAcctOwner;
            SystemAccountOwner = SystemAcctOwner;
            
            // Run your test cases as sys admin
            Vgtna_CustomLoginController.fetchUser(); 
            Vgtna_CustomLoginController.fetchACR();
            Vgtna_CustomLoginController.updateUserBrand(runAsUsr.id,'Volvo');
            Vgtna_CustomLoginController.updateUserBrand('','Volvo');
            Vgtna_CustomLoginController.updateUserDealerCode('277K');
        }
        
        system.debug('**** setup account owner '+SystemAccountOwner);

        // Create the Dealer Account
        Account tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('Test Class TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).setDealerCode('277K').buildAndSave();
        tstDealerAccount.IsPartner = true;
        // Set owner to System User
        tstDealerAccount.OwnerId=SystemAccountOwner.Id;
        system.debug('*** Account: '+tstDealerAccount);
        update tstDealerAccount;
        
        // Create the Contact that will be converted into the Partner User
        Contact tstContact = new Vgtna_TestBuilder.ContactBuilder().setLastName('Partner User').setFirstName('Test Class').setEmail('test@vive.com.invalid').setAccount(tstDealerAccount).buildAndSave();
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
        
       
        System.RunAs(testPartnerUser)
        {
            Vgtna_CustomLoginController.fetchACR();
            Vgtna_CustomLoginController.fetchACR();
        }
       
      
    }
}