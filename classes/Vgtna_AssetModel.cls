/**
* @author         salesforce services       
* @date           10/23/2018
* @description    model class for Asset
* @group          Vgta_AssetTriggerHandler,Vgta_AssetTrigger
*
*
*/
public Without Sharing class Vgtna_AssetModel {
    public Vgtna_AssetModel() {
        
    }
    
/**
* @param Method Name: createAndAssignAssetTeam
* @param author: Salesforce Services
* @param Date: 10/10/2018
* @description : Trigger on Asset to write Territory and User Assignment for PSR
* @param  : list<Asset>, map<Id,Asset>, boolean, isInsert
* @return : None  
*/
    public static void WriteTerritoryAndUserAssignmentForPSR(List<Asset> newAssets, Map<Id,Asset> oldAssets, Boolean isInsert)
    {
        System.debug('in WriteTerritoryAndUserAssignmentForPSR, assets '+newAssets);


        Map<String, List<AccountContactRelation>> dealerCode2ACR = new Map<String, List<AccountContactRelation>>();        
        Set<String> dealerCodes = new Set<String>();
        Set<Id> ContactIds = new Set<Id>();
        
		for(Asset oAsset : newAssets)
        {
            if(oAsset.Seller_Dealer_Code__c <> null)
            {
                dealerCodes.add(oAsset.Seller_Dealer_Code__c);
            }
        }
        
		for(AccountContactRelation tAcr: [Select ContactId, Dealer_Brand__c, Roles, Account_Dealer_Code__c 
                                            From AccountContactRelation 
                                            Where Account_Dealer_Code__c In : dealerCodes])
        {
			if(!dealerCode2ACR.containsKey(tAcr.Account_Dealer_Code__c))
            {
                dealerCode2ACR.put(tAcr.Account_Dealer_Code__c,new List<AccountContactRelation>());
            }
            dealerCode2ACR.get(tAcr.Account_Dealer_Code__c).add(tAcr);
            ContactIds.add(tAcr.ContactId);
        }

        System.debug('Contact Ids : '+ContactIds);
        System.debug('dealerCoceACR map:'+dealerCode2ACR);
        
		Map<Id, Id> contact2User = new Map<Id, Id>();		        
        
        for(User usr:[Select Id, ContactId 
                      From User 
                      Where isPortalEnabled = true 
                      And isActive = true
                      And ContactId In: ContactIds])
        {
            contact2User.put(usr.ContactId, usr.Id);
        }
 		
        Map<String, Territory2> dealerCodeToTerritory = vgtna_TerritoryModel.findTerritoryID(dealerCodes);
        Map<String, Set<Id>> existingAccounts = vgtna_TerritoryModel.getAccountsWithDealerCode(dealerCodes);
        Map<String, Set<Id>> existingUsers = vgtna_TerritoryModel.getUsersWithDealerCode(dealerCodes);
        List<ObjectTerritory2Association> ot2a = new List<ObjectTerritory2Association>();
		List<UserTerritory2Association> ut2a = new list<UserTerritory2Association>();
        
        for(Asset oAsset : newAssets)
        {
            if(oAsset.Seller_Dealer_Code__c <> null)
            {
                if(dealerCode2ACR.containsKey(oAsset.Seller_Dealer_Code__c))
                {
                    for(AccountContactRelation acr : dealerCode2ACR.get(oAsset.Seller_Dealer_Code__c))
                    {
                        if(contact2User.containsKey(acr.ContactId))
                        {
                            if(existingUsers.containsKey(oAsset.Seller_Dealer_Code__c))
                            {
                                // Some Users existed in Territory, make sure this one is not already added
                                if(existingUsers.get(oAsset.Seller_Dealer_Code__c).add(contact2User.get(acr.ContactId)))
                                {
                                    ut2a.add(new UserTerritory2Association(
                                        UserId=contact2User.get(acr.ContactId),
                                        Territory2Id=dealerCodeToTerritory.get(oAsset.Seller_Dealer_Code__c).Id));
                                }
                            } else
                            {
                                // No Users existed in Territory
                                ut2a.add(new UserTerritory2Association(
                                    UserId=contact2User.get(acr.ContactId),
                                    Territory2Id=dealerCodeToTerritory.get(oAsset.Seller_Dealer_Code__c).Id));
                            }
                        }
                    }
                    if(existingAccounts.containsKey(oAsset.Seller_Dealer_Code__c))
                    {
                        // Some Accounts existed in Territory, make sure this one is not already added
                        if(existingAccounts.get(oAsset.Seller_Dealer_Code__c).add(oAsset.AccountId))
                        {
                            ot2a.add(new ObjectTerritory2Association(
                                AssociationCause='Territory2Manual',
                                ObjectId=oAsset.AccountId,
                                Territory2Id=dealerCodeToTerritory.get(oAsset.Seller_Dealer_Code__c).Id));
                        }
                    } else
                    {
                        // No Accounts existed in Territory
                        ot2a.add(new ObjectTerritory2Association(
                            AssociationCause='Territory2Manual',
                            ObjectId=oAsset.AccountId,
                            Territory2Id=dealerCodeToTerritory.get(oAsset.Seller_Dealer_Code__c).Id));
                    }
                } 
            }
        }
        if(!ut2a.isEmpty())
        {
            insert ut2a;
        }
        if(!ot2a.isEmpty())
        {
            insert ot2a;
        }
    }		        
}