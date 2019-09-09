/**
* @author         salesforce services       
* @date           06/23/2016
* @description    model class for Opportunity
* @group          Vgta_OpportunityTriggerHandler,Vgta_OpportunityTrigger
*
*
*/
public Without Sharing class Vgtna_OpportunityModel {
    public Vgtna_OpportunityModel() {
        
    }
    
/**
* @param Method Name: createAndAssignOpportunityTeam
* @param author: Salesforce Services
* @param Date: 10/10/2018
* @description : Create Opportunity Team based on presence of an Account Team for Accounts related to Opportunity where User has selected to Invite the Sales team via Checkbox on Oppty.  Once team is invited, the sharing persists.
* @param  : list<Opportunity>, map<Id,Opportunity>, boolean, isInsert
* @return : None 
*/
    public static void createAndAssignOpportunityTeam(List<Opportunity> newOpportunities, Map<Id,Opportunity> oldOpportunities, Boolean isInsert)
    {
		
        
        List<Opportunity> oppsNeedPublicGroupsAdded = new List<Opportunity>();
        Map<String,Id> dealerCode2OppIdMap = new Map<String,Id>();
		List<OpportunityTeamMember> opptyTeam = new List<OpportunityTeamMember>();
		Set<Id> opptyId = new Set<Id>();
        Set<Id> opptyIdToBeProcessed = new Set<Id>();
        
        Set<Id> opptyTerrId = new Set<Id>();
        
        /**for(Opportunity oppty: newOpportunities)
        {
        	opptyId.add(oppty.Id);
        }**/
        
        
        /** New Logic to assign opportunity team starts:
         * If Opportunity.Account.Recordtype.name = "Customer" then get the RFM from that account team and get the DSM
         * from the Dealer Acount and add to Opportunity team
         **/
        
        List<Opportunity> OppsToBeProcessed = new List<Opportunity>();
        Map<Id,Id> custAccountId2OppId = new Map<Id,Id>();
        Map<Id,Id> dealerAccountId2OppId = new Map<Id,Id>();
        
        Map<Id,Id> custAccountId2UserId = new Map<Id,Id>();
        Map<Id,Id> dealerAccountId2UserId = new Map<Id,Id>();
        Map<Id, String> Oppty2Brand = new Map<Id, String>();
        
        List<OpportunityTeamMember> newOpportunityTeamMember = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> oldOpportunityTeamMember = new List<OpportunityTeamMember>();
        
        for(Opportunity oppty: newOpportunities)
        {
            if((isInsert == true && oppty.Invite_Sales_Team__c == true) || (isInsert == false && oppty.Invite_Sales_Team__c != oldOpportunities.get(oppty.Id).Invite_Sales_Team__c && oppty.Invite_Sales_Team__c == true))
            {
                opptyId.add(oppty.Id);
            }
        }
        system.debug('opptyId-->'+opptyId);
        
        if(!opptyId.isEmpty())
        {
            OppsToBeProcessed = [Select id, AccountId,Partner_Account__c,Account.RecordType.Name, Brand__c
                                 From Opportunity
                                 Where id IN: opptyId
                                 And Account.RecordType.Name = 'Customer'];
        }
        
        if(!OppsToBeProcessed.isEmpty())
        {
            for(Opportunity opp : OppsToBeProcessed)
            {
                custAccountId2OppId.put(opp.AccountId,opp.Id);
                opptyIdToBeProcessed.add(opp.Id);
                Oppty2Brand.put(opp.Id, opp.Brand__c);
                
                if(opp.Partner_Account__c != null)
                {
                    dealerAccountId2OppId.put(opp.Partner_Account__c,opp.Id);
                }
            }
        }
        
        // With all maps set let's process RFM from Customer Account team first

        if(!custAccountId2OppId.isEmpty())
        {
            List<AccountTeamMember> accountTeamCustomer = [Select Id, AccountId,UserId, Account.Name, User.Dealer_Brand__c
                                                           From AccountTeamMember 
                                                           Where AccountId In: custAccountId2OppId.keySet() 
                                                           And (TeamMemberRole  ='Regional Fleet Manager' OR TeamMemberRole = 'Regional_Fleet_Manager')
                                                           Order By AccountId];
        	System.debug('****  accountTeamCustomer: '+accountTeamCustomer);
            
            if(!accountTeamCustomer.isEmpty())
            {
                for(AccountTeamMember at1 : accountTeamCustomer)
                {	
                    //For RFM's, we only want the ones that have User.Brand__c EQ to the Opportunity Brand
                    String t_opptyId = custAccountId2OppId.get(at1.AccountId);
                    System.debug('+++++++++++ User Brand='+at1.User.Dealer_Brand__c+' And Oppty Brand='+Oppty2Brand.get(t_opptyId));
                    if(at1.User.Dealer_Brand__c == Oppty2Brand.get(t_opptyId))
                        //custAccountId2UserId.put(at1.AccountId,at1.UserId);
                        custAccountId2UserId.put(at1.UserId,at1.AccountId);
                }
            }
            
            if(!custAccountId2UserId.isEmpty())
            {
                //OpportunityTeamMember
                for(Id key : custAccountId2UserId.keyset())
                {
                    OpportunityTeamMember OT1= new OpportunityTeamMember(UserId = key,
                                                                         OpportunityId = custAccountId2OppId.get(custAccountId2UserId.get(key)),
                                                                         TeamMemberRole = 'Regional Fleet Manager');
                    
                    newOpportunityTeamMember.add(OT1);
                }
            }
        }
        
        // Similar logic for DSMs from Dealer Account
        
        if(!dealerAccountId2OppId.isEmpty())
        {
            List<AccountTeamMember> accountTeamDealer = [Select Id, AccountId,UserId, Account.Name 
                                                           From AccountTeamMember 
                                                           Where AccountId In: dealerAccountId2OppId.keySet() 
                                                           And TeamMemberRole  ='District Sales Manager'
                                                           Order By AccountId];
        	System.debug('****  accountTeamDealer: '+accountTeamDealer);
            
            if(!accountTeamDealer.isEmpty())
            {
                for(AccountTeamMember at2 : accountTeamDealer)
                {
                    //dealerAccountId2UserId.put(at2.AccountId,at2.UserId);
                    dealerAccountId2UserId.put(at2.UserId,at2.AccountId);
                }
            }
            
            if(!dealerAccountId2UserId.isEmpty())
            {
                //OpportunityTeamMember
                for(Id key1 : dealerAccountId2UserId.keyset())
                {
                    OpportunityTeamMember OT2= new OpportunityTeamMember(UserId = key1,
                                                                         OpportunityId = dealerAccountId2OppId.get(dealerAccountId2UserId.get(key1)),
                                                                         TeamMemberRole = 'District Sales Manager');
                    
                    newOpportunityTeamMember.add(OT2);
                }
            }
        }
        
        
        // finally remove all opportunity team members and insert new ones
        
        system.debug('newOpportunityTeamMember-->'+newOpportunityTeamMember);
        
        if(!newOpportunityTeamMember.isEmpty())
        {
            oldOpportunityTeamMember = [select id from OpportunityTeamMember where OpportunityId IN: opptyIdToBeProcessed];
            
            if(!oldOpportunityTeamMember.isEmpty())
            {
                delete oldOpportunityTeamMember;
            }
            insert newOpportunityTeamMember;
            system.debug('newOpportunityTeamMember-->'+newOpportunityTeamMember);
        }
        
        /** New Logic to assign opportunity team ends **/
        
        
        /** old logic of invite sales team commented out starts
       
		Map<Id, Opportunity> accountToOpportunity = new Map<Id, Opportunity>();
        system.debug('oppties '+newOpportunities);
        
        // this is everything, have to fix
        Map<ID,Opportunity> allOpp1 = new Map<ID,Opportunity>([Select ID, Opportunity.Owner.isPortalEnabled, Opportunity.Partner_Account__c, Owner.ID 
                                                               From Opportunity
                                                               Where Id In : opptyId
                                                              ]);    

 
        for(Opportunity oppty: newOpportunities)
        {
            if(oppty.Invite_Sales_Team__c)
            {
                // Check if user is a Partner Community User
                system.debug('++++++  partner user: '+oppty.Owner);
                if(allOpp1.get(oppty.Id).Owner.isPortalEnabled)
                {
                    system.debug('*** In processing area, Partner user established and invite has changed');
                    if(isInsert)
                    {
                        // New Oppty, add to the list
                        accountToOpportunity.put(allOpp1.get(oppty.Id).Partner_Account__c, oppty);
                    }
                    else if(oldOpportunities.containsKey(oppty.Id))
                    {
                        // Was the Invite Team off (false) before the save
                        if(!oldOpportunities.get(oppty.Id).Invite_Sales_Team__c)
                        {
                            accountToOpportunity.put(allOpp1.get(oppty.Id).Partner_Account__c, oppty);
                        }
                    }
                }
            }
        }
        System.debug('***** Account2Oppty Map: '+accountToOpportunity);
		List<AccountTeamMember> accountTeam = [Select Id, UserId, Account.Name From AccountTeamMember Where AccountId In: accountToOpportunity.keySet() Order By AccountId];
        System.debug('****  AccountTeamMembers: '+accountTeam);
        for(AccountTeamMember atm: accountTeam)
        {
            // Oppty has either a Mack or Volvo RecordType, use to only invite OEM specific Team Members
            // Opportunity oppty = accountToOpportunity.get(atm.AccountId);
            // TODO when RecordTypes are added to Opportunities, need to look at the RT for Mack or Volvo and add appropriate team members
			opptyTeam.add(new OpportunityTeamMember(OpportunityId=accountToOpportunity.get(atm.AccountId).Id,
                         UserId=atm.UserId,
                         OpportunityAccessLevel='Read'));
        }
    
        List<OpportunityTeamMember> oldTeamMembers = [Select Id From OpportunityTeamMember Where OpportunityId In :accountToOpportunity.Values()];
        delete oldTeamMembers;
        insert opptyTeam; 

   old logic of invite sales team commented out ends   **/  
        
        // Additional logic to add Manager public group to opportunity share  
        
        if(isInsert)
        {
            // Insert scenario
            for(Opportunity op: newOpportunities)
            {
                if(op.Dealer_Code_for_Opportunity__c != null)
                {
                    oppsNeedPublicGroupsAdded.add(op);
                }
                
            }
            
        }
        else
        {
            // Update scenario
            
            /**for(Id o: oldOpportunities.keyset())
            {
                for(Opportunity n: newOpportunities)
                {
                    // In update dealer code has not changed but only the owner has then just add the new group to share as old group will be automatically deleted due to manual share rowcause on owner change.
                    
                    if(o==n.id && oldOpportunities.get(o).Partner_Account__c == n.Partner_Account__c && oldOpportunities.get(o).OwnerId != n.OwnerId)
                    {
                        oppsNeedPublicGroupsAdded.add(n);
                    }
                    // In update dealer code has changed but not the owner then  add the new group to share and old group will have to be deleted.
                    
                    if(o==n.id && oldOpportunities.get(o).Partner_Account__c != n.Partner_Account__c  && oldOpportunities.get(o).OwnerId == n.OwnerId)
                    {
                        if(n.Dealer_Code_for_Opportunity__c != null)
                        {
                            oppsNeedPublicGroupsAdded.add(n);
                        }
                        if(oldOpportunities.get(o).Dealer_Code_for_Opportunity__c != null)
                        {
                           dealerCode2OppIdMap.put(oldOpportunities.get(o).Dealer_Code_for_Opportunity__c ,o);
                        }
                        
                    }
                }
            }**/
            
            for(Opportunity n: newOpportunities)
            {
                // In update dealer code has not changed but only the owner has then just add the new group to share as old group will be automatically deleted due to manual share rowcause on owner change.
                if(oldOpportunities.get(n.Id).Partner_Account__c == n.Partner_Account__c && oldOpportunities.get(n.Id).OwnerId != n.OwnerId)
                {
                    oppsNeedPublicGroupsAdded.add(n);
                }
                
                // In update dealer code has changed but not the owner then  add the new group to share and old group will have to be deleted.
                    
               if(oldOpportunities.get(n.Id).Partner_Account__c != n.Partner_Account__c  && oldOpportunities.get(n.Id).OwnerId == n.OwnerId)
               {
                   if(n.Dealer_Code_for_Opportunity__c != null)
                        {
                            oppsNeedPublicGroupsAdded.add(n);
                        }
                   if(oldOpportunities.get(n.Id).Dealer_Code_for_Opportunity__c != null)
                   {
                       dealerCode2OppIdMap.put(oldOpportunities.get(n.Id).Dealer_Code_for_Opportunity__c ,n.Id);
                   }
               }
                
            }
            
        }
        
        if(!oppsNeedPublicGroupsAdded.isEmpty())
        {
            // Send over for dealer code public group search and add to share
            assignOpptyShare4PublicGroup(oppsNeedPublicGroupsAdded);
        }
        
        if(!dealerCode2OppIdMap.isEmpty())
        {
            // Send over for dealer code public group search and remove from share
            removeOpptyShare4PublicGroup(dealerCode2OppIdMap);
        }
        
        //Territory assignment after insert and update to call future method.
     /**   
         if(isInsert)
        {
             System.debug('Hey u r here insert');
            // Insert scenario
            for(Opportunity op: newOpportunities)
            {
                System.debug('op.Partner_Account__c-->'+op.Partner_Account__c);
                System.debug('op.Territory2Id-->'+op.Territory2Id);
                if(op.Partner_Account__c != null)
                {
                    opptyTerrId.add(op.Id);
                }
            }
        }
        else
        {
            System.debug('Hey u r here update');
            // Update scenario
            for(Opportunity op: newOpportunities)
            {
                System.debug('op.Partner_Account__c-->'+op.Partner_Account__c);
                System.debug('oldOpportunities.get(op.id).Partner_Account__c-->'+oldOpportunities.get(op.id).Partner_Account__c);
                System.debug('op.Territory2Id-->'+op.Territory2Id);
                
                if(op.Partner_Account__c != oldOpportunities.get(op.id).Partner_Account__c)
                {
                    //op.Territory2Id = null;
                    if(op.Partner_Account__c != null)
                    {
                        opptyTerrId.add(op.Id);
                    }
                    
                }
            }
        }
         System.debug('opptyTerrId-->'+opptyTerrId);
        
        if(!opptyTerrId.isEmpty())
        {
            // Call future method for territory id assignment
            vgtna_TerritoryModel.updateTerritoryID(opptyTerrId);
        }
      **/  
    }
	/*
	public static void shareOpportunityToManagersFromCreditedToDealerCode(List<Opportunity> newOpportunities, Map<Id,Opportunity> oldOpportunities, Boolean isInsert)
    {    

        Map<String, List<AccountContactRelation>> dealerCode2ACR = new Map<String, List<AccountContactRelation>>();

        
        Set<String> dealerCodes = new Set<String>();
        Set<Id> ContactIds = new Set<Id>();
        for(Opportunity oppty: newOpportunities)
        {
            dealerCodes.add(oppty.Dealer_Code_Credited_To__c);
        }
        
		for(AccountContactRelation tAcr: [Select ContactId, Dealer_Brand__c, Roles, Account.Dealer_Code__c 
                                            From AccountContactRelation 
                                            Where Account.Dealer_Code__c In : dealerCodes])
        {
			if(!dealerCode2ACR.containsKey(tAcr.Account.Dealer_Code__c))
            {
                dealerCode2ACR.put(tAcr.Account.Dealer_Code__c,new List<AccountContactRelation>());
            }
            dealerCode2ACR.get(tAcr.Account.Dealer_Code__c).add(tAcr);
            ContactIds.add(tAcr.ContactId);
        }

		Map<Id, Id> contact2User = new Map<Id, Id>();		        
        
        for(User usr:[Select Id, ContactId 
                      From User 
                      Where isPortalEnabled = true 
                      And isActive = true
                      And ContactId In: ContactIds])
        {
            contact2User.put(usr.ContactId, usr.Id);
        }
        
        
		Set<Id> tstSet = new Set<Id>(New Map<Id, OpportunityShare>([Select Id 
                                                                    From OpportunityShare 
                                                                    Where UserOrGroupId In : contact2User.keySet()]).keySet());	
        
        List<OpportunityShare> opptyShare = new List<OpportunityShare>();
		for(Opportunity oppty: newOpportunities)
        {
            if(dealerCode2ACR.containsKey(oppty.Dealer_Code_Credited_To__c))
            {
                for(AccountContactRelation acr : dealerCode2ACR.get(oppty.Dealer_Code_Credited_To__c))
                {
                    if(acr.Roles.Contains(acr.Dealer_Brand__c) && acr.Roles.Contains('Manager') && tstSet.add(contact2User.get(acr.ContactId)))
                    {
                        opptyShare.add(new OpportunityShare(
                        	OpportunityId=oppty.Id,
                            OpportunityAccessLevel='Read',
                            UserOrGroupId=contact2User.get(acr.ContactId)
                        ));
                    }
                }
            } 
        }

        insert opptyShare;

    }
	*/
	public static void SetCreditedToDealerCode(List<Opportunity> newOpportunities, Map<Id,Opportunity> oldOpportunities, Boolean isInsert)
    {    
        
		Set<Id> ownrId = new Set<Id>();
        Set<String> dealerCodes = new Set<String>();
        List<Opportunity> OpptyNeedsTerritory = new List<Opportunity>();
        
        for(Opportunity oppty: newOpportunities)
        {
            ownrId.add(oppty.OwnerId);
        }
        

        Map<Id, User> ownr = new map<Id, User>([Select Id, Dealer_Code__c 
                                                From User 
                                                Where isPortalEnabled = true
                                                And isActive = true
                                                And Id In: ownrId]);
       // if(ownr.isEmpty()){return;}
        
        for(User us : ownr.Values())
        {
            dealerCodes.add(us.Dealer_Code__c);
        }
        
        Map<String, Id> dealerCode2AcccountId = new Map<String, Id>();
        
        
        List<Account> lAcct = [Select Id, Dealer_Code__c From Account Where Dealer_Code__c In : dealerCodes];
        for(Account acct : lAcct)
        {
            dealerCode2AcccountId.put(acct.Dealer_Code__c, acct.Id);
            
        }
        
        for(Opportunity oppty: newOpportunities)
        {
            if(ownr.get(oppty.OwnerId)!= null && oppty.Partner_Account__c==null)
            {
                // Set the Dealer_Code_Credited_To__c based on User.Dealer_Code__c
                if(ownr.get(oppty.OwnerId).Dealer_Code__c!= null)
                {
                    oppty.Partner_Account__c = dealerCode2AcccountId.get(ownr.get(oppty.OwnerId).Dealer_Code__c);
                    System.Debug('***** '+oppty.Partner_Account__c); 
                }
            }
        }
     /** 
        // Before Insert and Update modify territory lookup with appropriate territory nodes
        System.debug('Hey u r here');
        if(isInsert)
        {
             System.debug('Hey u r here insert');
            // Insert scenario
            for(Opportunity op: newOpportunities)
            {
                System.debug('op.Partner_Account__c-->'+op.Partner_Account__c);
                System.debug('op.Territory2Id-->'+op.Territory2Id);
                if(op.Partner_Account__c != null)
                {
                    OpptyNeedsTerritory.add(op);
                }
            }
        }
        else
        {
            System.debug('Hey u r here update');
            // Update scenario
            for(Opportunity op: newOpportunities)
            {
                System.debug('op.Partner_Account__c-->'+op.Partner_Account__c);
                System.debug('oldOpportunities.get(op.id).Partner_Account__c-->'+oldOpportunities.get(op.id).Partner_Account__c);
                System.debug('op.Territory2Id-->'+op.Territory2Id);
                
                if(op.Partner_Account__c != oldOpportunities.get(op.id).Partner_Account__c)
                {
                    op.Territory2Id = null;
                    if(op.Partner_Account__c != null)
                    {
                        OpptyNeedsTerritory.add(op);
                    }
                    
                }
            }
        }
         System.debug('OpptyNeedsTerritory-->'+OpptyNeedsTerritory);
        if(!OpptyNeedsTerritory.isEmpty())
        {
            // Send over for dealer code public group search and add to share
            //assignTerritoryID(OpptyNeedsTerritory);
        }
	**/
    }    
    
    public static void assignOpptyShare4PublicGroup(List<Opportunity> newOpportunities)
    {
        Set<String> dealerCode4PublicGroup = new Set<String>();
         Map<String,Id> dealerCode2OppIdMap = new Map<String,Id>();
         Map<Id,Id> groupId2OppIdMap = new Map<Id,Id>(); 
            
             for(Opportunity o: newOpportunities)
            {
                
                String sname = o.Dealer_Code_for_Opportunity__c+'_Managers';
                if(sname.left(1).isNumeric())
                {
                    sname = 'X'+sname;
                }
                dealerCode4PublicGroup.add(sname);
                dealerCode2OppIdMap.put(o.Dealer_Code_for_Opportunity__c,o.Id);
            }
        
            if(!dealerCode4PublicGroup.isEmpty())
            {
                List<Group> managersPublicGroup = Vgtna_GroupModel.findDealerSharingGroup(dealerCode4PublicGroup);
                System.debug('managersPublicGroup--->'+ managersPublicGroup);
                
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
                            if(dealerCode2OppIdMap.get(dc) != null)
                            {
                                groupId2OppIdMap.put(g.id,dealerCode2OppIdMap.get(dc));
                            }
                        }
                    }
            }
        	// Send it for assignment to share object
        	if(!dealerCode2OppIdMap.isEmpty())
                 {
                     Vgtna_SharingModel.setObjectShare(groupId2OppIdMap,'Opportunity');
                 }
        		
    }
    
    public static void removeOpptyShare4PublicGroup(Map<String,Id> dealerCode2OppIdMap)
    {
        Set<String> dealerCode4PublicGroup = new Set<String>();         
         Map<Id,Id> oppId2GroupIdMap = new Map<Id,Id>();
        
        for(String s: dealerCode2OppIdMap.keyset())
        {
            String sname = s+'_Managers';
            if(sname.left(1).isNumeric())
            {
                sname = 'X'+sname;
            }
            dealerCode4PublicGroup.add(sname);
            
        }
        
        if(!dealerCode4PublicGroup.isEmpty())
            {
                List<Group> managersPublicGroup = Vgtna_GroupModel.findDealerSharingGroup(dealerCode4PublicGroup);
                System.debug('managersPublicGroup--->'+ managersPublicGroup);
                
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
                            if(dealerCode2OppIdMap.get(dc) != null)
                            {
                                oppId2GroupIdMap.put(dealerCode2OppIdMap.get(dc),g.id);
                            }
                        }
                    }
            }
        
        // Send it for assignment to share object
        	if(!oppId2GroupIdMap.isEmpty())
                 {
                     Vgtna_SharingModel.reomoveObjectShare(oppId2GroupIdMap,'Opportunity');
                 }
    }
    
  /**  public static void assignTerritoryID(List<Opportunity> newOpportunities)
    {
        System.debug('newOpportunities-->'+newOpportunities);
        
        Set<String> dealerCodes = new Set<String>();
        Map<String, Opportunity> dealerCode2OpptyMap = new Map<String, Opportunity>();
        
         for(Opportunity oppty: newOpportunities)
         {
             String s = oppty.Dealer_Code_for_Opportunity__c;
             if (s != null)
             {
                dealerCode2OpptyMap.put(oppty.Dealer_Code_for_Opportunity__c+' ',oppty); // Territories are <dealer code><space>-<Space><Name>
                 s = s+'%';
                 dealerCodes.add(s);
             }
         }
        
        if(!dealerCodes.isEmpty())
            {
                List<Territory2> matchingTerrIds = vgtna_TerritoryModel.findTerritoryID(dealerCodes);
                System.debug('matchingTerrIds--->'+ matchingTerrIds);
                
                if(!matchingTerrIds.isEmpty())
                    {
                        for(Territory2 t2: matchingTerrIds)
                        {
                            List<String> newCode = t2.Name.split('-');
                			String dc = newCode[0]; 
                            if(dealerCode2OpptyMap.get(dc) != null)
                            {
                                dealerCode2OpptyMap.get(dc).Territory2Id = t2.id;
                                system.debug(dealerCode2OpptyMap.get(dc).id);
                                system.debug('dealerCode2OpptyMap.get(dc).Territory2Id-->'+dealerCode2OpptyMap.get(dc).Territory2Id);
                            }
                        }
                    }
            }
        
        
    }**/
}