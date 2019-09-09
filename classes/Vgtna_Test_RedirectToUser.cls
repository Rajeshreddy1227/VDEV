@isTest
public class Vgtna_Test_RedirectToUser {
    public static testmethod void redirectToUsrMethod() {
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        User testPartnerUser = new User();
        Customer_Activity__c ca = new Customer_Activity__c();
        ca.Dealer_Brand__c = 'Volvo';
        ca.Name = 'Test ca';
        insert ca;
        Account tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('Test ACR PROCESS TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().buildAndSave();
        tstDealerAccount.Party_ID_LastModifiedDate__c = System.today();
        update tstDealerAccount;
        Contact tstContact = new Vgtna_TestBuilder.ContactBuilder().setLastName(' Partner User').setFirstName('ACR Process').setEmail('testacrp@vive.com.invalid').setAccount(tstDealerAccount).buildAndSave();
        System.RunAs(runAsUsr){            
            User tstUser = new Vgtna_TestBuilder.UserBuilder().setContact(tstContact).setlastName('Partner User').setEmail(tstContact.Email).setProfileId(vgtna_Constants.DEALER_USER_PROFILE).buildAndSave();
            
            tstUser.IsPortalEnabled=true;
            tstUser.UserRoleId=[Select Id from UserRole Where PortalAccountId=:tstDealerAccount.Id And PortalRole='Worker' Limit 1].Id;
            tstUser.Dealer_Brand__c = 'Mack';
            update tstUser;            
            testPartnerUser = tstUser;
        }
        System.RunAs(testPartnerUser){
        	Vgtna_RedirectToUser.redirectToUsr(ca.Id);
        }
    }
}