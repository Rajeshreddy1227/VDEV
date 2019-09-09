@isTest
public class Vgtna_CustomerProfileControllerTest 
{

    static testMethod void testCustomerProfile() 
    {
        Vgtna_CustomerProfileController.fetchUser();
        Vgtna_CustomerProfileController.getCustomerProfile('001000000ABYUIO','D5009');
        
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
         System.RunAs(runAsUsr)
         {
             // Create customer account
             Account tstCustAccount = new Vgtna_TestBuilder.AccountBuilder().setName('CustomerProfileTest').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().buildAndSave();
             
             // Create the Dealer Account
                Account tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('CP Test Dealer Account').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).setDealerCode('5887D').buildAndSave();
                tstDealerAccount.IsPartner = true;                
                update tstDealerAccount;
             
             // Create the Contact that will be converted into the Partner User
                Contact tstContact = new Vgtna_TestBuilder.ContactBuilder().setLastName('Partner User').setFirstName('CP Test').setEmail('testCP@aol.com').setAccount(tstDealerAccount).buildAndSave();
                system.debug('*** contact '+tstContact);
             
             // Create the Partner User
             	User testPartnerUser = new User();
             	User tstUser = new Vgtna_TestBuilder.UserBuilder().setContact(tstContact).setlastName('CP Partner User').setEmail(tstContact.Email).setProfileId(vgtna_Constants.DEALER_USER_PROFILE).buildAndSave();
            
                 tstUser.IsPortalEnabled=true;
                 tstUser.UserRoleId=[Select Id 
                                     From UserRole 
                                     Where PortalAccountId=:tstDealerAccount.Id 
                                     And PortalRole='Manager' Limit 1].Id;
                 update tstUser;
                 testPartnerUser = tstUser;

         }
        
        System.RunAs(runAsUsr)
        {
            Account acc = [Select id from Account where name= 'CustomerProfileTest' limit 1];
            Account accDealer = [Select id from Account where Dealer_Code__c = '5887D' limit 1];
            
            Vgtna_CustomerProfileController.getCustomerProfile(acc.id,'5887D');
            
            Customer_Profile__c CP = new Customer_Profile__c(Customer_Account__c = acc.id,
                                                             Dealer_Account__c = accDealer.Id);
            
            insert CP;
            Vgtna_CustomerProfileController.getCustomerProfile(acc.id,'5887D');
            
            Account_Profile__c AP = new Account_Profile__c(Account__c = acc.Id);
			insert AP;
            
        }
    }
    
}