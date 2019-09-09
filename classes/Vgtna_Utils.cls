/**
* @author         salesforce services       
* @date           10/04/2018
* @description    All Util methods for VGTNA Implementation project are created here and are referrenced from other classes
*
*/
public class Vgtna_Utils {
	public Vgtna_Utils() {
		
	}
    
	/**
    * @author         salesforce services       
    * @date           10/04/2018
    * @description    Processing Class to Automate assigning Dealer Managers to their Lead Queues
	*/
    public Static void ProcessLeadQueueMembership()
    {
        list<GroupMember > oldGroupMemberList = [SELECT Id From GroupMember Where GroupId IN 
                                                 (Select Id From Group Where Type = 'Queue' And Name Like 'Lead Queue%')];
        delete oldGroupMemberList;
        

        //reload it fresh
        list<GroupMember> newGroupMemberList = new list<GroupMember>();
        list<Group> groups = [SELECT Id, Name FROM Group Where Type = 'Queue' And Name Like '%Lead Queue'];
        System.debug('groups: '+groups);
        Map<String, User> salesUsers = New Map<String, User>();
        List<User> memberUsers = [Select Contact.Account.Dealer_Code__c, Id From User Where UserRole.Name Like '%Partner Manager'];
        for(User usr: memberUsers)
        {
            salesUsers.put(usr.Contact.Account.Dealer_Code__c, usr);
        }
            
        System.debug('** SalesUsers: '+salesUsers);
        for(group grp : groups)
        {
            List<String> tempDealerCodes = new List<String>();
            tempDealerCodes = GetDealerCodes(grp.Name);
            
            for(String tmpDealerCode : tempDealerCodes)
            {
                if(SalesUsers.ContainsKey(tmpDealerCode))
                {
                    newGroupMemberList.add(new GroupMember(
                    		GroupId=grp.Id,
                    		UserOrGroupId=salesUsers.get(tmpDealerCode).Id));
                }
            }
        }
        system.debug('** newGroupMemberList '+newGroupMemberList);
        insert newGroupMemberList;
    }
    
    public Static List<String> GetDealerCodes(String dealerCode)
    {
        // Dealer Codes are embedded in the name of the Queue
        // Single Branded Dealer : 5083D- Lead Queue
		List<String> returnDealerCodes = new List<String>();
        List<String> newCode = dealerCode.split('-');
		returnDealerCodes.add(newCode[0]);
        return returnDealerCodes;
        
    }
}