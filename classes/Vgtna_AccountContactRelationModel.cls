/**
* @Class Name: Vgtna_AccountContactRelationModel
* @description : Methods to support Sharing for AccountContactRelationModel and adding users to Dealer 
*                Code specific Territories
*/

public with sharing class Vgtna_AccountContactRelationModel {
    
    public static void setSharingToRoles(Map<Id, AccountContactRelation> newAcr, Map<Id,AccountContactRelation> oldAcr, Boolean isInsert)
    {
        Set<String> uniqueDealerCodes = new Set<String>();
        Map<Id,String> contactid2DealerCodeMap = new Map<Id,String>();        
        Set<String> uniqueDealerCodesAddMngr = new Set<String>();
        Map<Id,String> contactid2DealerCodeAddMngrMap = new Map<Id,String>();
        Set<String> uniqueDealerCodesDelMngr = new Set<String>();
        Map<Id,String> contactid2DealerCodeDelMngrMap = new Map<Id,String>();
        Set<String> dealerCodesForTerritoryAssignment = new Set<String>();
        Map<String, List<AccountContactRelation>> dealerCode2ACR = new Map<String, List<AccountContactRelation>>();
        Set<Id> ContactIds = new Set<Id>();
        List<AccountShare> acctShr = new List<AccountShare>();
        Map<String, Id> DealerCode2AccountId = new Map<String, Id>();
        Set<Id> sExecutivesAccountIds = new Set<Id>();
        
        String grpName;  
        String oldgrpName;             
        Map<Id, String> contactid2rolegrp = new Map<Id, String>();
        Map<Id, String> delcontactid2rolegrp = new Map<Id, String>();

        // 1. Insert Scenario
        
        if(isInsert == true)
        {
            // Only include Manager Roles
             for(Id i: newAcr.keyset())
             {
                 if(newAcr.get(i).Roles != null && newAcr.get(i).Roles.contains('Manager'))
                 {
                     uniqueDealerCodes.add(newAcr.get(i).Account_Dealer_Code__c);
                     contactid2DealerCodeMap.put(newAcr.get(i).contactid,newAcr.get(i).Account_Dealer_Code__c);
                 }
                 System.debug('Role is '+newAcr.get(i).Roles);
                 if(newAcr.get(i).Roles!=null)
                 {
                     System.debug('account dealer code: '+newAcr.get(i).Account_Dealer_Code__c);
                     // Adding Dealer Codes to Set to Bring back matching Territories
                     dealerCodesForTerritoryAssignment.add(newAcr.get(i).Account_Dealer_Code__c);
                     System.debug('dealerCodesForTerritoryAssignment==>'+dealerCodesForTerritoryAssignment);
                     if(!dealerCode2ACR.containsKey(newAcr.get(i).Account_Dealer_Code__c))
                     {
                         dealerCode2ACR.put(newAcr.get(i).Account_Dealer_Code__c,new List<AccountContactRelation>());
                     }
                     dealerCode2ACR.get(newAcr.get(i).Account_Dealer_Code__c).add(newAcr.get(i));
                     ContactIds.add(newAcr.get(i).ContactId);
                     System.debug('Adding contact '+ContactIds);
                     DealerCode2AccountId.put(newAcr.get(i).Account_Dealer_Code__c, newAcr.get(i).AccountId);
                    
                    //Start of Code - SN 08/01/2019
                    if(newAcr.get(i).Roles.contains('Rep'))
                    {
                        grpName = 'Dealer_Sales_Reps';
                    }
                    if(newAcr.get(i).Roles.contains('Manager'))
                    {
                        grpName = 'Dealer_Sales_Managers';
                    }
                    if(newAcr.get(i).Roles.contains('Executive'))
                    {
                        grpName = 'Dealer_Sales_Executives';
                    }

                    contactid2rolegrp.put(newAcr.get(i).contactid, grpName);
                    if(!contactid2rolegrp.isEmpty())
                    {
                        processSharingToReportGrp(contactid2rolegrp, 'Insert');
                    }
                    //End of Code - SN 08/01/2019*/
                 }
             }
            
            if(!uniqueDealerCodes.isEmpty() && !contactid2DealerCodeMap.isEmpty())
            {
                processSharingToRoles(uniqueDealerCodes,contactid2DealerCodeMap,'Insert');
            }
        }
        else
        {
            // 2. Update Scenario
       
            // Check if the role has changed and if old role was manager or new role is manager. 
            // Don't bother if old role was Mack Sales Manager and new role is Volvo Sales Manager.
            System.debug('Update scenario--->');
            
            for(Id o: oldAcr.keyset())
            {
                for(Id n: newAcr.keyset())
                {
                    // the old and new roles don't match
                    if(o == n && oldAcr.get(o).Roles != newAcr.get(n).Roles )
                    {
                        if(newAcr.get(n).Roles != null && newAcr.get(n).Roles.contains('Rep'))
                        {
                            grpName = 'Dealer_Sales_Reps';
                        }
                        if(newAcr.get(n).Roles != null && newAcr.get(n).Roles.contains('Manager'))
                        {
                            grpName = 'Dealer_Sales_Managers';
                        }
                        if(newAcr.get(n).Roles != null && newAcr.get(n).Roles.contains('Executive'))
                        {
                            grpName = 'Dealer_Sales_Executives';
                        }
                        contactid2rolegrp.put(newAcr.get(n).contactid, grpName);
                        if(!contactid2rolegrp.isEmpty())
                        {
                            processSharingToReportGrp(contactid2rolegrp, 'Insert');
                        }
                        if(oldAcr.get(o).Roles != null && oldAcr.get(o).Roles.contains('Rep'))
                        {
                            oldgrpName = 'Dealer_Sales_Reps';
                        }
                        if(oldAcr.get(o).Roles != null && oldAcr.get(o).Roles.contains('Manager'))
                        {
                            oldgrpName = 'Dealer_Sales_Managers';
                        }
                        if(oldAcr.get(o).Roles != null && oldAcr.get(o).Roles.contains('Executive'))
                        {
                            oldgrpName = 'Dealer_Sales_Executives';
                        }
                        delcontactid2rolegrp.put(oldAcr.get(o).contactid, oldgrpName);
                        if(!delcontactid2rolegrp.isEmpty())
                        {
                            processSharingToReportGrp(delcontactid2rolegrp, 'Delete');
                        }

                        // Role has changed but was manager and is manager.
                        if(oldAcr.get(o).Roles != null && newAcr.get(n).Roles != null && newAcr.get(n).Roles.contains('Manager') && oldAcr.get(o).Roles.contains('Manager'))
                        {
                            // No action.
                        }
                        else
                        {
                            // if new role is manager and old role was either null or not manager
                            if(newAcr.get(n).Roles != null && newAcr.get(n).Roles.contains('Manager') &&(oldAcr.get(o).Roles == null || !oldAcr.get(o).Roles.contains('Manager')))
                            {
                                uniqueDealerCodesAddMngr.add(newAcr.get(n).Account_Dealer_Code__c);
                                contactid2DealerCodeAddMngrMap.put(newAcr.get(n).contactid,newAcr.get(n).Account_Dealer_Code__c);
                            }
                            // if new role is not manager or null and old role was manager.
                            if(oldAcr.get(o).Roles != null && oldAcr.get(o).Roles.contains('Manager') &&(newAcr.get(n).Roles == null || !newAcr.get(n).Roles.contains('Manager')))
                            {
                                uniqueDealerCodesDelMngr.add(newAcr.get(n).Account_Dealer_Code__c);
                                contactid2DealerCodeDelMngrMap.put(newAcr.get(n).contactid,newAcr.get(n).Account_Dealer_Code__c);
                            }
                            if(newAcr.get(n).Roles!=null)
                            {
                                // Adding Dealer Codes to Set to Bring back matching Territories
                                dealerCodesForTerritoryAssignment.add(newAcr.get(n).Account_Dealer_Code__c);
                                if(!dealerCode2ACR.containsKey(newAcr.get(n).Account.Dealer_Code__c))
                                {
                                    dealerCode2ACR.put(newAcr.get(n).Account_Dealer_Code__c,new List<AccountContactRelation>());
                                }
                                dealerCode2ACR.get(newAcr.get(n).Account_Dealer_Code__c).add(newAcr.get(n));
                                ContactIds.add(newAcr.get(n).ContactId);
                                DealerCode2AccountId.put(newAcr.get(n).Account_Dealer_Code__c, newAcr.get(n).AccountId);
                            }
                        }
                    }
                }   
                
            }

            System.debug('uniqueDealerCodesAddMngr--->'+ uniqueDealerCodesAddMngr);
            System.debug('contactid2DealerCodeAddMngrMap--->'+ contactid2DealerCodeAddMngrMap);
            System.debug('uniqueDealerCodesDelMngr--->'+ uniqueDealerCodesDelMngr);
            System.debug('contactid2DealerCodeDelMngrMap--->'+ contactid2DealerCodeDelMngrMap);
            
            // Now figure out what you got in terms of old and new manager scenario and process accordingly.
            if(!uniqueDealerCodesAddMngr.isEmpty() && !contactid2DealerCodeAddMngrMap.isEmpty())
            {
                processSharingToRoles(uniqueDealerCodesAddMngr,contactid2DealerCodeAddMngrMap,'Insert');
            }
            
            if(!uniqueDealerCodesDelMngr.isEmpty() && !contactid2DealerCodeDelMngrMap.isEmpty())
            {
                processSharingToRoles(uniqueDealerCodesDelMngr,contactid2DealerCodeDelMngrMap,'Delete');
            }
        }
        System.debug('dealerCode2ACR '+dealerCode2ACR);
        
        // Territory Assignments for Users and Accounts
        Map<String, Territory2> territoriesToProcess = Vgtna_TerritoryModel.findTerritoryID(dealerCodesForTerritoryAssignment);
        System.debug('***** Terr found '+territoriesToProcess);
        Map<String, Set<Id>> existingUsers = vgtna_TerritoryModel.getUsersWithDealerCode(dealerCodesForTerritoryAssignment);
        System.debug('***** users found '+existingUsers);
        List<String> l_terr = new List<String>();        
        Map<Id, Id> contact2User = new Map<Id, Id>();               
        
        for(User usr:[Select Id, ContactId 
                      From User 
                      Where isPortalEnabled = true 
                      And isActive = true
                      And ContactId In: ContactIds])
        {
            contact2User.put(usr.ContactId, usr.Id);
        }
        
        System.debug('Users that will be added '+contact2User.values());
        Map<Id, AccountShare> lstUsersAlready = new Map<Id, AccountShare>([Select UserOrGroupId 
                                                                           From AccountShare 
                                                                           Where AccountId In : DealerCode2AccountId.values()]);
        Set<Id> tstSet = new Set<Id>();
        for(AccountShare ut2 : lstUsersAlready.values())
        {
            tstSet.add(ut2.UserOrGroupId );
        }
        
        // Loop through DealerCodes and Assign Users to matching Territories
        for(String delship :dealerCode2ACR.keySet())
        {
            for(AccountContactRelation acr : dealerCode2ACR.get(delship))
            {
                System.debug('Contact is: '+acr.ContactId);
                if(contact2User.containsKey(acr.ContactId))
                {
                    System.debug('Contact found');
                    if(tstSet.add(contact2User.get(acr.ContactId)))
                    {
                        System.debug('Adding new Share record for insert');
                        acctShr.add(New AccountShare(
                            AccountAccessLevel='Read',
                            AccountId=DealerCode2AccountId.get(delship),
                            CaseAccessLevel='None',
                            OpportunityAccessLevel='None',
                            UserOrGroupId=contact2User.get(acr.ContactId)
                        ));
                    }
                    
                    if(existingUsers.containsKey(delship))
                    {
                        // Some Users existed in Territory, make sure this one is not already added
                        Set<ID> s_user = existingUsers.get(delship);
                        System.debug('Are there existing users for '+delship+' :'+s_user);
                        Id uId = contact2User.get(acr.ContactId);
                        system.debug('UserId that is being checked: '+uId);
                        if(s_user.add(uId))
                        {
                            l_terr.add(JSON.serialize(New vgtna_TerritoryHelper(uId, territoriesToProcess.get(delship).Id)));
                        }
                    }
                    else
                    {
                        System.debug('Dealership is '+delship);
                        // User not already exists, OK to add
                        l_terr.add(JSON.serialize(New vgtna_TerritoryHelper(contact2User.get(acr.ContactId), territoriesToProcess.get(delship).Id)));
                    }
                }
            }
        }
            

        System.debug('Inserting New Share');
        if(!acctShr.isEmpty())
        {
            insert(acctShr);
        }
        if(!l_terr.isEmpty())
        {
            vgtna_TerritoryModel.insertTerritory2UserAssociation(l_terr);
        }
    }

    public static void processSharingToReportGrp(Map<Id, String> conid2rolegrp, String op)
    {
        Map<Id, String> userid2grpName = new Map<Id, String>();
        Map<String, Id> grpName2userid = new Map<String, Id>();
        Set<String> grpList = new Set<String>();
        Map<Id,Id> grpid2UserMap = new Map<Id,Id>();

        List<User> grpUsers = [Select id, contactid from User Where isActive = true 
                                            And contactid IN: conid2rolegrp.keyset()];
                    
        for(User u: grpUsers)
        {
            if(conid2rolegrp.get(u.contactid) != null)
            {
                userid2grpName.put(u.id, conid2rolegrp.get(u.contactid));
                grpName2userid.put(conid2rolegrp.get(u.contactid), u.id);
            }
        }
        
        for(String s : conid2rolegrp.keyset())
        {
            grpList.add(conid2rolegrp.get(s));
        }
        List<Group> usersPublicGroup = Vgtna_GroupModel.findDealerSharingGroup(grpList);
        if(!usersPublicGroup.isEmpty())
        {
            for(Group g : usersPublicGroup)
            {
                grpid2UserMap.put(g.id, grpName2userid.get(g.developername));
            }
        }
        if(!grpid2UserMap.isEmpty())
        {
            Vgtna_GroupModel.setDealershipGroupMembership(grpid2UserMap, op);
        }
    }
    
    public static void processSharingToRoles(Set<String>uniqueDealerCodes,Map<Id,String> contactid2DealerCodeMap, String operation)
    {
        Map<String,User> dealerCode2UserMap = new Map<String,User>();
        Map<Id,Id> groupid2UserMap = new Map<Id,Id>();
        
        // There are some dealer codes with manager role involved. Get the users
                
                List<User> grpManagers = [Select id, contactid from User 
                          Where isActive = true 
                          And contactid IN: contactid2DealerCodeMap.keyset()];
                
                for(User u: grpManagers)
                {
                    if(contactid2DealerCodeMap.get(u.contactid) != null)
                    {
                        dealerCode2UserMap.put(contactid2DealerCodeMap.get(u.contactid),u);
                    }
                }
                
                // Fire the method to get matching public groups
                if(!dealerCode2UserMap.isEmpty())
                {
                    Set<String> dealerCode4PublicGroup = new Set<String>();
                    
                    for(String s: dealerCode2UserMap.keyset())
                    {
                        String sname = s+'_Managers';
                        if(sname.left(1).isNumeric())
                        {
                            sname = 'X'+sname;
                        }
                        System.debug('group.DeveloperName to look for: '+sname);
                        dealerCode4PublicGroup.add(sname);
                    }
                    
                    List<Group> managersPublicGroup = Vgtna_GroupModel.findDealerSharingGroup(dealerCode4PublicGroup);
                    System.debug('managersPublicGroup--->'+ managersPublicGroup);
                    
                    // If public groups found then map group memebers
                    
                    if(!managersPublicGroup.isEmpty())
                    {
                        for(Group g: managersPublicGroup)
                        {
                            List<String> newCode = g.DeveloperName.split('_');
                            String dc = newCode[0]; 
                            if(dc.left(1)=='X')
                            {
                                dc=dc.mid(1, dc.length()-1);
                            }
                            if(dealerCode2UserMap.get(dc) != null)
                            {
                                groupid2UserMap.put(g.id,dealerCode2UserMap.get(dc).id);
                            }
                        }
                    }
                }
                
                // if the group2user map is set up then fire the method to get group memebers created/deleted.
                
                 if(!groupid2UserMap.isEmpty())
                 {
                     Vgtna_GroupModel.setDealershipGroupMembership(groupid2UserMap,operation);
                 }
            
            
    }
    
    public static void removeSharingToRoles(Map<Id,AccountContactRelation> oldAcr)
    {
        Set<String> uniqueDealerCodes = new Set<String>();
        Map<Id,String> contactid2DealerCodeMap = new Map<Id,String>();
        Map<Id, Id> contactId2UserId = new Map<Id, Id>();
        Set<Id> acctsForShare = new Set<Id>();
        Set<Id> usersForShare = new Set<Id>();
        Set<id> contactForShare = new Set<Id>();
        Map<String, List<AccountContactRelation>> dealerCode2ACR = new Map<String, List<AccountContactRelation>>();
        Set<String> dealerCodesForTerritoryAssignment = new Set<String>();
        
        for(Id i: oldAcr.keyset())
        {
            acctsForShare.add(oldAcr.get(i).AccountId);
            contactForShare.add(oldAcr.get(i).ContactId);
            if(oldAcr.get(i).Roles != null && oldAcr.get(i).Roles.contains('Manager'))
                // Only include Manager Roles for Group removal
            {
                uniqueDealerCodes.add(oldAcr.get(i).Account_Dealer_Code__c);
                contactid2DealerCodeMap.put(oldAcr.get(i).contactid,oldAcr.get(i).Account_Dealer_Code__c);
            }
            if(!dealerCode2ACR.containsKey(oldAcr.get(i).Account.Dealer_Code__c))
            {
                dealerCode2ACR.put(oldAcr.get(i).Account_Dealer_Code__c,new List<AccountContactRelation>());
            }
            dealerCode2ACR.get(oldAcr.get(i).Account_Dealer_Code__c).add(oldAcr.get(i));
            dealerCodesForTerritoryAssignment.add(oldAcr.get(i).Account_Dealer_Code__c);
        }
        
        for(User usr: [Select Id, ContactId
                       From User 
                       Where ContactId In:contactForShare
                       And isPortalEnabled=true
                       And isActive=true])
        {
            usersForShare.add(usr.Id);
            contactId2UserId.put(usr.ContactId, usr.Id);
        }
        
        List<AccountShare> acctShr4Removal = [Select Id 
                                              From AccountShare 
                                              Where AccountId In:acctsForShare
                                              And UserOrGroupId In:usersForShare];
        
        if(!uniqueDealerCodes.isEmpty() && !contactid2DealerCodeMap.isEmpty())
        {
            processSharingToRoles(uniqueDealerCodes,contactid2DealerCodeMap,'Delete');
        }
        // Remove Dealership Account Share
        delete(acctShr4Removal);
        
        Map<String, Territory2> territoriesToProcess = Vgtna_TerritoryModel.findTerritoryID(dealerCodesForTerritoryAssignment);
        
        Map<Id, UserTerritory2Association> ut2a = new Map<Id, UserTerritory2Association>([Select Id, Territory2Id, UserId
                                          From UserTerritory2Association
                                          Where Territory2Id In: territoriesToProcess.values()
                                          And UserId In: contactId2UserId.values()]);
        if(!ut2a.isEmpty())
        {
            //delete ut2a;
            deleteUserTerritory(ut2a.keyset());
            
        }
    }
    
    @future
    public static void deleteUserTerritory(Set<Id> userTerritoryIds) {
        List<UserTerritory2Association> ut2a = [Select Id From UserTerritory2Association WHERE Id IN :userTerritoryIds];
        delete ut2a;
    }
    
}