public without sharing class vgtna_RemoveAccountTeamInternal { 

    @AuraEnabled
    public static list<AccountTeamMember> RemoveAccountTeamInternal(string accountId){
        list<user> UserRoleIds = [Select Id, UserName,Name,Dealer_Brand__c,UserRole.Name,Profile.Name,FederationIdentifier From user  Where Id =:UserInfo.getUserId() limit 1];
        list<user> superUser = [select id, FederationIdentifier,name, email, isactive, profile.name, userrole.name, usertype from user where id in (select userorgroupid from groupmember where group.name = 'RemoveAccountTeamSupUser')  and Id =:UserInfo.getUserId() limit 1];
        list<AccountTeamMember> accountTeam = new List<AccountTeamMember>();
        string dsm = 'District Sales Manager';
        string rfm = 'Regional Fleet Manager';
        string nam = 'National Accounts Manager';
        Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{UserRoleIds[0].UserRole.Id});
        Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where	UserRoleId IN :allSubRoleIds]);
        //if(UserRoleIds[0].FederationIdentifier == System.Label.vgtna_Mack_RemAccTeamSupUser1 || UserRoleIds[0].FederationIdentifier == System.Label.vgtna_Mack_RemAccTeamSupUser2)
        if(superUser.size()>0)
        {
            accountTeam = [select User.Name, TeamMemberRole, Id, AccountId From AccountTeamMember where AccountId = :accountId and User.Dealer_Brand__c ='Mack'];
        }
        //For Volvo Users
        else if(UserRoleIds[0].Dealer_Brand__c == 'Volvo'){
            accountTeam = [select User.Name, TeamMemberRole, Id, AccountId From AccountTeamMember where AccountId = :accountId and (User.Id IN :users.keySet() or User.Id=:UserInfo.getUserId())];         
        }
        //code for all Profiles except DSMs,RFms,NAMs     
        else if(!UserRoleIds[0].UserRole.Name.contains(dsm) && !UserRoleIds[0].UserRole.Name.contains(rfm) && !UserRoleIds[0].UserRole.Name.contains(nam)){
          accountTeam = [select User.Name, TeamMemberRole, Id, AccountId From AccountTeamMember where AccountId = :accountId and (User.Id IN :users.keySet() or User.Id=:UserInfo.getUserId())];         
        }   
   return accountTeam;
    }
      private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
            Set<ID> currentRoleIds = new Set<ID>();        
            for(UserRole userRole :[select Id from UserRole where ParentRoleId
              IN :roleIds AND ParentRoleID != null])
            currentRoleIds.add(userRole.Id);        
            if(currentRoleIds.size() > 0)
              currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));        
            return currentRoleIds;        
          }
    /*  public static List<AccTeamData> RemoveAccountTeamInternal(string accountId){
        List<AccountTeamMember> accountTeam = [select UserId, TeamMemberRole, Id, AccountId From AccountTeamMember where AccountId = :accountId];
          List<AccTeamData> acctmemList = new List<AccTeamData>();
          for(AccountTeamMember Team: accountTeam){
              AccTeamData acctmem = new AccTeamData();
              acctmem.UserId = Team.UserId;
              acctmem.TeamMemberRole = Team.TeamMemberRole;
              acctmem.AccountId = Team.AccountId;
              acctmemList.add(acctmem);
          }
        return acctmemList;
    }*/
 @AuraEnabled
        public static string deleteTeam(list<Id> accTeamMemId){
            list<AccountTeamMember> accTeamMem = [select id from AccountTeamMember where id in :accTeamMemId];
            try {
                if(!accTeamMem.isEmpty())
                {
                    delete accTeamMem;
                    return 'Success';
                 }             
            return 'Record not found';
            }
            catch(Exception e){
                return 'Error: Exception '+e.getMessage()+' occured at line number '+e.getLineNumber();
            }
        }
 /*   public class AccTeamData{
        	@AuraEnabled public string UserId;
            @AuraEnabled public string TeamMemberRole;
            @AuraEnabled public string AccountId;
            @AuraEnabled public string Id;
           // @AuraEnabled public string
        public AccTeamData(){
           	UserId = '';
           	TeamMemberRole = '' ;
            AccountId = '';
           // Id = '' ;
        }
    }*/
}