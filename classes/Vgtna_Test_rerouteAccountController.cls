@isTest
public class Vgtna_Test_rerouteAccountController {
public static testmethod void reroute(){
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        string dsm = 'District Sales Manager';
        string rfm = 'Regional Fleet Manager';
        string nam = 'National Accounts Manager';
        UserRole r,rP;
        User u,uP;
        
        System.runAs(runAsUsr){
        rP = new UserRole(DeveloperName = 'RVP', Name = 'Regional Vice President');
        insert rP;
       	r = new UserRole(DeveloperName = 'DSM', Name = 'District Sales Manager',ParentRoleId =rP.id );
		insert r;
       uP = new User(
         //ProfileId = '00ef2000001Y2h3AAC',
          ProfileId = [select id from profile where name ='Mack Sales Rep'].id,
         LastName = 'lastname',
         Email = 'lastfirst@lastnamefirstname.com',
         Username = 'lastfirst@lastnamefirstname.com' + System.currentTimeMillis(),
         CompanyName = 'Volvo Trucks',
         Title = 'DSM',
         Alias = 'DSM',
          Dealer_Brand__c = 'Mack',
         TimeZoneSidKey = 'America/Los_Angeles',
         EmailEncodingKey = 'UTF-8',
         LanguageLocaleKey = 'en_US',
         LocaleSidKey = 'en_US',
         UserRoleId = rP.Id
		);
        insert uP;  
      u = new User(
         //ProfileId = '00ef2000001Y2h3AAC',
         ProfileId = [select id from profile where name ='Mack Sales Rep'].id,
         LastName = 'lastname',
         Email = 'lastfirst@lastnamefirstname.com',
         Username = 'lastfirst@lastnamefirstname.com' + System.currentTimeMillis(),
         CompanyName = 'Volvo Trucks',
         Title = 'DSM',
         Alias = 'DSM',
          Dealer_Brand__c = 'Mack',
         TimeZoneSidKey = 'America/Los_Angeles',
         EmailEncodingKey = 'UTF-8',
         LanguageLocaleKey = 'en_US',
         LocaleSidKey = 'en_US',
         UserRoleId = r.Id
		);
        insert u;
           
       }
        system.debug('rid: '+r.Id+'---userroleid:'+u.UserRoleId);
        Account tstCustAccount = new Vgtna_TestBuilder.AccountBuilder().setSurvivingPartyId('123456789').setName('FedExTest').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().setBillingCountryCode('US').setBillingPostalCode('561832323').buildAndSave();
    	Account tstCustAccount1 = new Vgtna_TestBuilder.AccountBuilder().setName('FedExTest').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyIdConstant('123456789').setBillingCountryCode('US').setBillingPostalCode('561832323').buildAndSave();
    Account tstCustAccount2 = new Vgtna_TestBuilder.AccountBuilder().setSurvivingPartyId().setName('FedExTest2').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().setBillingCountryCode('US').setBillingPostalCode('561832323').buildAndSave();
        string accId = tstCustAccount.Id;
    	string accId2 = tstCustAccount2.Id;
    system.debug('accId==>'+accId);
 
        System.runAs(runAsUsr){
              
              	Account acc = VGTNA_rerouteAccountController.findAccount(accId);
            	Account acc1 = VGTNA_rerouteAccountController.findAccount(accId2);
            }
    }
}