/**
* @author         salesforce services       
* @date           11/28/2018
* @description    Batch class to assign terrirory2id to opportunity running in a sys admin mode.
*           
*
*
*/
global class Vgtna_batchAssignTerrToOppty implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
            // collect the batches of records or objects to be passed to execute
             
           // String query = 'SELECT Id,Name,AccountId,Territory2Id,Territory_Dealer_Code__c,Partner_Account__c,Partner_Account__r.Dealer_Code__c,LastModifiedDate FROM Opportunity Where Partner_Account__r.Dealer_Code__c!= null or Territory_Dealer_Code__c != null';
           String query = 'SELECT Id,Name,AccountId,Territory2Id,Territory_Dealer_Code__c,Partner_Account__c,Partner_Account__r.Dealer_Code__c,LastModifiedDate FROM Opportunity Where SystemModStamp >= LAST_N_DAYS:1 AND (Partner_Account__r.Dealer_Code__c!= null OR Territory_Dealer_Code__c != null)';
        system.debug('query-->'+query);
        	return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList)
    {
        
        // process each batch of records
 		Map<String, Opportunity> dealerCode2OpptyMap = new Map<String, Opportunity>();
        Set<String> dealerCodes = new Set<String>();
        List<Opportunity> oppsToBeUpdated = new List<Opportunity>();
        
        for(Opportunity oppty: oppList)
        {
            if(oppty.Partner_Account__r.Dealer_Code__c == null && oppty.Territory_Dealer_Code__c != null)
            {
                oppty.Territory2Id = null;
                oppsToBeUpdated.add(oppty);
            }
            else
            {
                dealerCodes.add(oppty.Partner_Account__r.Dealer_Code__c);
            	dealerCode2OpptyMap.put(oppty.Partner_Account__r.Dealer_Code__c,oppty); 
            }
            
        }
        if(!dealerCodes.isEmpty())
        {
            Map<String,Territory2> matchingTerrIds = vgtna_TerritoryModel.findTerritoryID(dealerCodes);
            System.debug('matchingTerrIds--->'+ matchingTerrIds);
            
                     if(!matchingTerrIds.isEmpty())
                     {
                         for(Opportunity o: oppList)
                         {
                             if(matchingTerrIds.get(o.Partner_Account__r.Dealer_Code__c) != null)
                             {
                                 o.Territory2Id = matchingTerrIds.get(o.Partner_Account__r.Dealer_Code__c).id;
                                 oppsToBeUpdated.add(o);
                             }
                         }
                         
                         
                     }
             }
        
        	if(!oppsToBeUpdated.isEmpty())
            {
                update oppsToBeUpdated;
            }
        }
         
           
     
    global void finish(Database.BatchableContext BC) 
    {
            // execute any post-processing operations
    }
}