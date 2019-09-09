public without sharing class Vgtna_FetchDealerUsers {
    @AuraEnabled
	public static List<User> getDealerUsers(Id optyId) 
    {
       //User usr = [SELECT Id, Dealer_Code__c, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId()]; 
       User usr = [SELECT Id, IsPortalEnabled,UserRole.Name, Dealer_Code__c, Name, ContactId,managerid FROM User WHERE Id = :UserInfo.getUserId()];
        if(usr.IsPortalEnabled == true){
            //For Portal SalesManager and Sales Executives
            if(usr.userrole.name.contains('Manager') || usr.userrole.name.contains('Executive')){
                system.debug('userrolr==>'+usr.userrole.name);
            
                   Account dealerAcc = [SELECT Id, Name, Dealer_Brand__c,Dealer_Code__c, ParentId from Account WHERE Dealer_Code__c =: usr.Dealer_Code__c LIMIT 1];
                    
                    List<String> acrConList = new List<String>();
                    if(string.isNotBlank(dealerAcc.Id)){
                       for(AccountContactRelation acr : [SELECT Id, ContactId, Roles FROM AccountContactRelation where AccountId =:dealerAcc.Id])// and dealer_brand__c = :dealerAcc.Dealer_Brand__c])
                        {
                            acrConList.add(acr.ContactId);
                        }
                        Map<Id, User> srUsers = new Map<Id, User>([SELECT Id, Name, FirstName, LastName, contactId FROM User WHERE contactId IN :acrConList]);
                        if(srUsers.size() > 0) {
                            system.debug('srUsers.Values()'+srUsers.values());
                            return srUsers.values();
                        }
                    }
                }
        }
        //For District Sales Manager
        else if(usr.userrole.name.contains('District Sales Manager')){
            id mgrId = usr.ManagerId;
            list<Opportunity> opty = [select id,name,OwnerId,Dealer_Code_for_Opportunity__c from Opportunity where id=:optyId limit 1];
            string dealerCode = opty[0].Dealer_Code_for_Opportunity__c;
       //     string recTypeName = opty[0].recordtype.name;//Mack or Volvo for DSM
      //      Account acc = [select id,name,dealer_brand__c from Account where name = :dealerCode];
            list<string> userList = new list<string>();
            for(AccountContactRelation acr : [SELECT Id, ContactId, Roles FROM AccountContactRelation where Account_Dealer_Code__c =:dealerCode  and Account_Dealer_Code__c<>null])//and dealer_brand__c = :acc.Dealer_Brand__c
            {
                userList.add(acr.ContactId);
            }
            return [SELECT Id, Name, FirstName, LastName, contactId FROM User WHERE contactId in :userList]; 
            //Commenting below per Mikals request
            //return [SELECT Id, Name, FirstName, LastName, contactId FROM User WHERE contactId in :userList  or managerId = :mgrId or id = :mgrId];
        }
        return [SELECT Id, Name, FirstName, LastName, contactId FROM User WHERE Id = :UserInfo.getUserId()];
    }
    @AuraEnabled
    public static string changeOwner(Id optyId,Id userId){
     	
        list<Opportunity> opty = [select id,name,OwnerId from Opportunity where id=:optyId and OwnerId=:userId limit 1];
       // list<Opportunity> optyWID = [select id,name,OwnerId from Opportunity where id=:optyId];
        User usr = [SELECT Id, IsPortalEnabled,UserRole.Name, Dealer_Code__c, Name, ContactId,managerid FROM User WHERE Id = :UserInfo.getUserId()];
        if(opty.isEmpty())
        {
             list<opportunity> opp = new list<opportunity>();
  
            for(opportunity op: [select id,name,OwnerId from Opportunity where id=:optyId])
            {
                op.OwnerId = userId;
                opp.add(op);
            }
            update opp;    
            
            //start
            if(usr.userrole.name.contains('District Sales Manager')){
                list<OpportunityShare> oppshareList = new list<OpportunityShare>();
                list<opportunityteammember> team = [select id from opportunityteammember where opportunityid =:optyId and userid =:usr.Id ];
                system.debug('Out');
                // if(team.Id == null || team.Id == ''){
                if(team.isEmpty()){
                    insert (new opportunityteammember(userid =usr.Id, opportunityid=optyId,TeamMemberRole = 'District Sales Manager',OpportunityAccessLevel = 'All'));
                }
                for (OpportunityShare OppShare :[select Id, OpportunityAccessLevel, RowCause from OpportunityShare where OpportunityId =:optyId  and userorgroupid = :usr.Id]){
                    OppShare.OpportunityAccessLevel = 'All';
                    oppshareList.add(OppShare);
                }
                if(oppshareList.size()>0) {database.update(oppshareList,false);}
            }
            
           return 'Success';      
        }
        else{
         	return 'Exists';
        }					
    }
}