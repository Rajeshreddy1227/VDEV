@isTest
public class Vgtna_Test_FetchAssignedSalesRep {
    public static testmethod void FetchAssignedSalesRepTestMethod() {
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        Account tstCustAccount = new Vgtna_TestBuilder.AccountBuilder().setName('FedExTest').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().setBillingCountryCode('US').setBillingPostalCode('561832323').buildAndSave();
        system.debug('alist: '+tstCustAccount);
        Account tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('ADVANTAGE TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).setDealerCode('5889D').buildAndSave();
        tstDealerAccount.IsPartner = true;
        update tstDealerAccount;
        Contact tstContact = new Vgtna_TestBuilder.ContactBuilder().setLastName('Partner User').setFirstName('Test').setEmail('test@aol.com.invalid').setAccount(tstDealerAccount).buildAndSave();
        System.runAs(runAsUsr) {
            Contact con = [SELECT Id, Name, Email FROM Contact LIMIT 1];
            User u = new Vgtna_TestBuilder.UserBuilder().setlastName('Volvo User').setEmail('tstUser@Email.com.invalid').setProfileId('Dealer Admin').setBrand('Volvo').setContact(con).buildAndSave();    
            
            u.Dealer_Code__c = '5889D';
            update u;
            Account custacc = [SELECT Id, OwnerId FROM Account WHERE Name = 'FedExTest'];
            custacc.ownerId = u.Id;
            update custacc;
            
        }
        User usr = [SELECT Id, Name, Email, Dealer_Brand__c, Dealer_Code__c FROM User WHERE Email = 'tstUser@Email.com.invalid' LIMIT 1];
        System.runAs(usr) {
            User usr1 = [SELECT Id, Name, Email, Dealer_Brand__c, Dealer_Code__c FROM User WHERE Email = 'tstUser@Email.com.invalid' LIMIT 1];
            Account a = [SELECT Id, Name FROM Account WHERE Name = 'FedExTest' LIMIT 1];
            system.debug('alist: '+a);
            Assigned_Sales_Rep__c asr1 = new Assigned_Sales_Rep__c();
            asr1.Account__c = a.Id;
            asr1.Sales_Rep__c = usr1.Id;
            asr1.Dealer_Code__c = '5889D';
            insert asr1;
            Vgtna_FetchAssignedSalesRep.getAssignedSalesRep(a.Id);
            Vgtna_FetchAssignedSalesRep.deleteASR(asr1.Id);
        }
    }
}