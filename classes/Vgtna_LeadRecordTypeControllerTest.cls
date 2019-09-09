@isTest
public class Vgtna_LeadRecordTypeControllerTest {

    static testMethod void mytest()
    {
        Vgtna_LeadRecordTypeSelectorController.fetchUser();
        Vgtna_LeadRecordTypeSelectorController.getListOfRecordType();
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
         User testPartnerUser = new User();
        System.RunAs(runAsUsr)
         {
        // Create the Dealer Account
                Account tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('CP Test Dealer Account').setRecordType('Dealer').setDealerCode('5887D').buildAndSave();
                tstDealerAccount.IsPartner = true;                
                update tstDealerAccount;
             
             // Create the Contact that will be converted into the Partner User
                Contact tstContact = new Vgtna_TestBuilder.ContactBuilder().setLastName('Partner User').setFirstName('CP Test').setEmail('testCP@aol.com').setAccount(tstDealerAccount).buildAndSave();
                system.debug('*** contact '+tstContact);
             
             // Create the Partner User
             	
             	User tstUser = new Vgtna_TestBuilder.UserBuilder().setContact(tstContact).setlastName('CP Partner User').setEmail(tstContact.Email).setProfileId('Dealer Admin').buildAndSave();
            
                 tstUser.IsPortalEnabled=true;
                 tstUser.UserRoleId=[Select Id 
                                     From UserRole 
                                     Where PortalAccountId=:tstDealerAccount.Id 
                                     And PortalRole='Manager' Limit 1].Id;
        		 tstUser.Dealer_Brand__c = 'Volvo';
                 update tstUser;
                 testPartnerUser = tstUser;
         }
        System.RunAs(testPartnerUser)
        {
             Vgtna_LeadRecordTypeSelectorController.getListOfRecordType();
        }
        
        testPartnerUser.Dealer_Brand__c = 'Mack';
        update testPartnerUser;
        System.RunAs(testPartnerUser)
        {
             Vgtna_LeadRecordTypeSelectorController.getListOfRecordType();
        }
        
    }
}