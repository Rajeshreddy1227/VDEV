public class Vgtna_FetchMgmtGrpUsers {
	@AuraEnabled
    public static List<User> getMgmtUsers(String optyId) 
    {
        User usr = [SELECT Id, Dealer_Code__c, Name, Dealer_Brand__c, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        Opportunity opp = [Select Id, Dealer_Code_Credited_To__c from Opportunity WHERE Id =:optyId];
        Account dealerAcc;
		String optyDealerCode 	= opp.Dealer_Code_Credited_To__c; 
        if(usr.ContactId != null)
        {
             dealerAcc = [SELECT Id, Name, Dealer_Code__c, ParentId from Account WHERE Dealer_Code__c =: usr.Dealer_Code__c LIMIT 1];
        }
        else
        {
            if(optyDealerCode != null)
            {
                 dealerAcc = [SELECT Id, Name, Dealer_Code__c, ParentId from Account WHERE Dealer_Code__c =: optyDealerCode LIMIT 1];
            }
            else
            {
               return [SELECT Id, Name, FirstName, LastName, ContactId, Dealer_Code__c FROM User WHERE ContactId = null and Dealer_Brand__c = :usr.Dealer_Brand__c and profile.name NOT IN ('System Administrator','Chatter Free User','System Integrator') AND Profile.Name<>null];
            }
        }
        String mgmtGrpId = dealerAcc.ParentId;
        String usrBrand = usr.Dealer_Brand__c;
        List<Account> mgmtDlrCodeId = [SELECT Id from Account where ParentId =: mgmtGrpId AND Brand__c =: usrBrand];
		List<String> acrConList = new List<String>();
      
        if(!mgmtDlrCodeId.isEmpty())
        {            
            for(AccountContactRelation acr : [SELECT Id, ContactId, Roles FROM AccountContactRelation where AccountId IN :mgmtDlrCodeId])
            {
                acrConList.add(acr.ContactId);
            }
            Map<Id, User> srUsers = new Map<Id, User>([SELECT Id, Name, FirstName, LastName, ContactId, Dealer_Code__c FROM User WHERE ContactId IN :acrConList]);             
            //Rajesh 07162019: Adding
            Map<Id, User> corpUsers = new Map<Id, User>([SELECT Id, Name, FirstName, LastName, ContactId, Dealer_Code__c FROM User WHERE ContactId = null and Dealer_Brand__c = :usr.Dealer_Brand__c and profile.name NOT IN ('System Administrator','Chatter Free User','System Integrator') AND Profile.Name<>null]);  
            srUsers.putAll(corpUsers);
            system.debug('srUsers is:'+srUsers);
            //End
            if(srUsers.size() > 0) 
            {
                return srUsers.values();
            }          
        }
        return [SELECT Id, Name, FirstName, LastName, ContactId, Dealer_Code__c FROM User WHERE Id = :UserInfo.getUserId()];      
	}
    
    @AuraEnabled
    public static string addOptyTeam(String optyId, list<String> optyTeamMemId)
    {
        list<string> bigList = new list<string>();
        list<string> smallList = new list<string>();
        List<String> userList = new List<String>();
        List<OpportunityTeamMember> newOpportunityTeamMember = New List<OpportunityTeamMember>();
        System.debug('Called addOptyTeam with OptyId = '+optyId + ' and OptyTeamId = '+ optyTeamMemId);
        for(user usr : [SELECT Id from User WHERE Id IN :optyTeamMemId])
        {
            bigList.add(usr.Id);
        }
		System.debug('bigList ' + bigList);
        for(OpportunityTeamMember ot : [SELECT UserId from OpportunityTeamMember where OpportunityId =: optyId and UserId IN :optyTeamMemId])
        {
            smallList.add(ot.UserId);
        }
        System.debug('smallList ' + smallList);
        for(string o : bigList)
        {
            if(!smallList.contains(o))
            {
                userList.add(o);
            }
        }
        System.debug('userList ' + userList);
        for(Id id : userList)
        {
            OpportunityTeamMember OT1= new OpportunityTeamMember(UserId =id, OpportunityId =optyId, TeamMemberRole = 'Dealer Sales Team');
            newOpportunityTeamMember.add(OT1);
        }
        System.debug('newOpportunityTeamMember ' + newOpportunityTeamMember);
        if(!newOpportunityTeamMember.isEmpty())
        {
            insert newOpportunityTeamMember;
            system.debug('-*-*-Members Added-*-*-');
            return 'Assigned';            
        }    
        return 'Exists';
    }
}