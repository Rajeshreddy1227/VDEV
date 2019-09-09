@isTest
public class Vgtna_Test_GenericDataTableCtrl {
    public static testmethod void GenericDataTableTestMethod() {
        User u = new Vgtna_TestBuilder.UserBuilder().setLastName('VolvoLastName').setEmail('volvolastnameinvalid@volvo.com').setProfileId('Volvo Sales Rep').setBrand('Volvo').buildAndSave();
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        Account tstCustAccount = new Vgtna_TestBuilder.AccountBuilder().setName('FedExTest').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().setBillingCountryCode('US').setBillingPostalCode('561832323').buildAndSave();
        system.debug('alist: '+tstCustAccount);
        Account tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('ADVANTAGE TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).setDealerCode('5889D').buildAndSave();
        tstDealerAccount.IsPartner = true;
        update tstDealerAccount;
        Contact tstContact = new Vgtna_TestBuilder.ContactBuilder().setLastName('Partner User').setFirstName('Test').setEmail('test@aol.com.invalid').setAccount(tstDealerAccount).buildAndSave();
        System.runAs(runAsUsr) {
            Contact con = [SELECT Id, Name, Email FROM Contact LIMIT 1];
            User u1 = new Vgtna_TestBuilder.UserBuilder().setlastName('Volvo User').setEmail('tstUser@Email.com.invalid').setProfileId('Dealer Admin').setBrand('Volvo').setContact(con).buildAndSave();    
            
            u1.Dealer_Code__c = '5889D';
            update u1;
        }
        User partnerUsr = [SELECT Id, Email FROM User WHERE Email='tstUser@Email.com.invalid' LIMIT 1];
        Assigned_Sales_Rep__c asr1 = new Assigned_Sales_Rep__c();
        asr1.Account__c = tstCustAccount.Id;
        asr1.Sales_Rep__c = partnerUsr.Id;
        asr1.Dealer_Code__c = '5889D';
        insert asr1;
        System.runAs(u) {
            Vgtna_GenericDataTableCtrl.getsObjectRecords('Assigned_Sales_Rep__c', 'ASRRelatedList', 'Dealer_Code__c', 'Dealer_Brand__c', 'Account__c', true, true, true, true, 5, 'custom:custom15', tstCustAccount.Id);
            Vgtna_GenericDataTableCtrl.getLoggedUser();
            Vgtna_GenericDataTableCtrl.deleteRec(asr1.Id);
        }
    }
}