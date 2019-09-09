public class Vgtna_InviteSalesTeamController {
    @AuraEnabled 
    public static void updateInviteSalesTeam(Id OppId)
    {
        Opportunity opp = [select id,Invite_Sales_Team__c 
                           from Opportunity
                          where id =: OppId limit 1];
        
        if(opp.Invite_Sales_Team__c == false)
        {
            opp.Invite_Sales_Team__c = true;
            update opp;
        }
    }

}