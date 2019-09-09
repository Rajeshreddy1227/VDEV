public Without Sharing class vgtna_TerritoryModel {
    
	    
	public  vgtna_TerritoryModel()
    {

    }

/**
* @param Method Name: setUser
* @param author: Salesforce Services
* @param Date: 10/10/2018
* @description : Sets Users to provided Territory Node, safe to use inside of a loop
* @param  : String dealerCd, String nodeType (either PSR, AOR, or Assignment)
* @return : Territory2 node (id and name) 
*/    

    // Method to return territory node per dealer code
    
    public static Map<String,Territory2> findTerritoryID(Set<String> sDealerCode)
    {
        Map<String,Territory2>dealerCode2TerritoryMap = new Map<String,Territory2>();
        System.debug('sDealerCodeterr--->'+ sDealerCode);
        List<Territory2> terr2List = new List<Territory2>();
        terr2List = [Select Id, Dealer_Code__c,Name 
                    From Territory2
                    Where Dealer_Code__c IN :sDealerCode
                    And Territory2Model.State='Active'];
        System.debug('terr2Listterr--->'+ terr2List);
        if(!terr2List.isEmpty())
        {
            for(Territory2 t2: terr2List)
            {
                dealerCode2TerritoryMap.put(t2.Dealer_Code__c,t2);
            }
        }
       return dealerCode2TerritoryMap;
    }

    public static Map<String, Set<Id>> getUsersWithDealerCode(Set<String> sDealerCode)
    {
        Map<String, Set<Id>> terr2DealCode2Users = new Map<String, Set<Id>>();

        for(UserTerritory2Association ut2 :[Select Id, UserId, Territory2.Dealer_Code__c
                                             From UserTerritory2Association
                                             Where Territory2.Dealer_Code__c In: sDealerCode])	
        {
            if(!terr2DealCode2Users.containsKey(ut2.Territory2.Dealer_Code__c))
            {
                terr2DealCode2Users.put(ut2.Territory2.Dealer_Code__c,new Set<Id>());
            }
            terr2DealCode2Users.get(ut2.Territory2.Dealer_Code__c).add(ut2.UserId);
        }
        return terr2DealCode2Users;
        
    }

    public static Map<String, Set<Id>> getAccountsWithDealerCode(Set<String> sDealerCode)
    {
        Map<String, Set<Id>> terr2DealCode2Accounts = new Map<String, Set<Id>>();

        for(ObjectTerritory2Association ut2 :[Select Id, ObjectId, SobjectType, Territory2.Dealer_Code__c
                                             From ObjectTerritory2Association
                                             Where Territory2.Dealer_Code__c In: sDealerCode])
        {
            if(!terr2DealCode2Accounts.containsKey(ut2.Territory2.Dealer_Code__c))
            {
                terr2DealCode2Accounts.put(ut2.Territory2.Dealer_Code__c,new Set<Id>());
            }
            terr2DealCode2Accounts.get(ut2.Territory2.Dealer_Code__c).add(ut2.ObjectId);
        }
        return terr2DealCode2Accounts;
        
    }
    
    // Has to be @Future Call
    @Future
    public static void insertTerritory2UserAssociation(List<String> s_ut2a)
    {
        // In order to pass the values for UserTerritory2Association into a @future method
        // which only allows primative data types, serializing / deserializing the values with
        // a helper class  vgtna_TerritoryHelper
		List<UserTerritory2Association> ut2a = new List<UserTerritory2Association>();
        vgtna_TerritoryHelper curr_ut2a = null;
        
        for(String ser : s_ut2a)
       {
           curr_ut2a = (vgtna_TerritoryHelper) JSON.deserialize(ser, vgtna_TerritoryHelper.class);
           ut2a.add(new UserTerritory2Association(
               UserId=curr_ut2a.contactId,
               Territory2Id=curr_ut2a.territory2Id));
       }
		if(!ut2a.isEmpty())
        {
            System.debug('***** Inserting UserTerritory2Association: '+ut2a);
	        insert ut2a;
        }
    }

    public class TerritoryException extends Exception {}
}