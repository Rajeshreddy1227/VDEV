@isTest
public class Vgtna_Test_UserModel {
    public static testmethod void userVolvoPermissionSet() {
         User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        Account tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('ADVANTAGE TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).setDealerCode('5889D').buildAndSave();
        tstDealerAccount.IsPartner = true;
        update tstDealerAccount;
        Contact tstContact = new Vgtna_TestBuilder.ContactBuilder().setLastName('Partner User').setFirstName('Test').setEmail('test@aol.com.invalid').setAccount(tstDealerAccount).buildAndSave();
        System.runAs(runAsUsr) {
            Contact con = [SELECT Id, Name, Email FROM Contact LIMIT 1];
            User u = new Vgtna_TestBuilder.UserBuilder().setlastName('Volvo User').setEmail('tstUser@Email.com.invalid').setProfileId('Dealer Admin').setBrand('Volvo').setContact(con).buildAndSave();    
            u.Dealer_Brand__c = 'Mack';
            update u;
        }
    }
    
    public static testmethod void userMackPermissionSet() {
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        Account tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('ADVANTAGE TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).setDealerCode('5889D').buildAndSave();
        tstDealerAccount.IsPartner = true;
        update tstDealerAccount;
        Contact tstContact = new Vgtna_TestBuilder.ContactBuilder().setLastName('Partner User').setFirstName('Test').setEmail('test@aol.com.invalid').setAccount(tstDealerAccount).buildAndSave();
        System.runAs(runAsUsr) {
            Contact con = [SELECT Id, Name, Email FROM Contact LIMIT 1];
        	User u = new Vgtna_TestBuilder.UserBuilder().setlastName('Mack User').setEmail('tstUser@Email.com.invalid').setProfileId('Volvo Sales Rep').setBrand('Mack').buildAndSave();    
        	u.Dealer_Brand__c = 'Volvo';
            update u;
        }
    }
}