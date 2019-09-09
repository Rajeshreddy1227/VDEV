@isTest
public class vgtna_Test_RemoveAccountTeamInternal {
    public static testmethod void RemoveAccountTeamInternal(){
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
        Account tstCustAccount = new Vgtna_TestBuilder.AccountBuilder().setName('FedExTest').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().setBillingCountryCode('US').setBillingPostalCode('561832323').buildAndSave();
        string accId = tstCustAccount.Id;
        AccountTeamMember newTeam = new AccountTeamMember(AccountId = accId,TeamMemberRole = 'District Sales Manager',UserId = u.Id);
        insert newTeam;
      Id idToDelete = newTeam.id;
      list <Id>  accTeamMem = new list<id>();
        accTeamMem.add(idToDelete);
        System.runAs(uP){
            vgtna_RemoveAccountTeamInternal.RemoveAccountTeamInternal(accId);
            vgtna_RemoveAccountTeamInternal.deleteTeam(accTeamMem);
        }
        System.runAs(u){
            vgtna_RemoveAccountTeamInternal.RemoveAccountTeamInternal(accId);
            vgtna_RemoveAccountTeamInternal.deleteTeam(accTeamMem);
        }
    }
}