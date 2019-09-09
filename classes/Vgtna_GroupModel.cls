public without sharing class Vgtna_GroupModel {

	public static List<Group> findDealerSharingGroup(Set<String> sDealerCode)
    {
        System.debug('sDealerCode--->'+ sDealerCode);
        List<Group> grp = new List<Group>();
        grp = [Select Id, Name, DeveloperName 
                    From Group
                    Where DeveloperName IN: sDealerCode
              		And Type='Regular'];
        return grp;
    }
    
    @future
    public static void setDealershipGroupMembership(Map<Id,Id> groupid2UserMap, String operation)
    {
        // Insert trigger
       
        if(operation == 'Insert')
        {
            List<GroupMember> gmsToBeInserted = new List<GroupMember>();

                for(Id grpId: groupid2UserMap.keyset())
                {
                    GroupMember member = new GroupMember(UserOrGroupId = groupid2UserMap.get(grpId),
                    GroupId = grpId);
                    gmsToBeInserted.add(member);
                }
        	insert gmsToBeInserted;
        }
        
        // Delete trigger
        
        if(operation == 'Delete')
        {
            List<GroupMember> allGroupMembers = new List<GroupMember>();
            List<GroupMember> gmsToBeDeleted = new List<GroupMember>();
            
            allGroupMembers =[Select id,UserOrGroupId,GroupId
                              From GroupMember
                              Where GroupId =: groupid2UserMap.keyset()];
            
            if(!allGroupMembers.isEmpty())
            {
                for(GroupMember gm: allGroupMembers)
                {
                    if(gm.UserOrGroupId == groupid2UserMap.get(gm.GroupId))
                    {
                        gmsToBeDeleted.add(gm);
                    }
                }
            }
            
            if(!gmsToBeDeleted.isEmpty())
            {
                delete gmsToBeDeleted;
            }
            
            
        }
        
    }
    
    /**
    public static Group setDealerSharingGroup(String sDealerCode, String sRole)
    {
        List<Group> lNewGroup = new List<Group>();
        //String sDevName = sDealerCode+'_'+sRole;
        String sDevName = sDealerCode+'_Managers';
        List<Group> grp = [Select Id, Name 
                    From Group
                    Where DeveloperName=:sDevName];
        if(grp.isEmpty())
        {
            lNewGroup.add(new Group(
                Name=sDevName,
                DeveloperName=sDevName,
                DoesIncludeBosses=false,
                Type='Regular'
            ));
        }
        else
        {
            System.debug('**** Using group '+grp[0].Name);
            return grp[0];
        }
        System.debug('**** Creating new group '+grp[0].Name);
        insert lNewGroup;
        return lNewGroup[0];
        
    }
    
    public static void setDealershipGroupMembership(Group oGrp, List<User> lUsr)
    {

        List<GroupMember> lGroupMember = [Select UserOrGroupId
                                          From GroupMember
                                          Where GroupId=:oGrp.Id];
        
        Set<Id> tstSet = new Set<Id>();         
        for(GroupMember oGroupMember : lGroupMember)
        {
            tstSet.add(oGroupMember.UserOrGroupId);
        }
        
        System.debug('******  Number of Users: '+tstSet.size());
        List<GroupMember> newManagers = new List<GroupMember>();
        for(User oUsr : lUsr)
        {
            if(tstSet.add(oUsr.Id)) // Returns true if Id was not already in the Set, add to List for Adding to GroupMember because not already found
            {
                // Check for OEM and Manager Role
                newManagers.add(new GroupMember(
                    GroupId=oGrp.Id,
                    UserOrGroupId=oUsr.Id
                ));
            }
        }
        insert newManagers;
        
    }
**/
}