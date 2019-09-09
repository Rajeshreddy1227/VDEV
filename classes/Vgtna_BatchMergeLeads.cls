global class Vgtna_BatchMergeLeads implements Database.Batchable<sObject>{
     global Database.QueryLocator start(Database.BatchableContext BC) 
     {
        String query = 'select id,ConvertedAccountId from Lead where ConvertedAccountId<>null';
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
     }
    global void execute(Database.BatchableContext BC, List<Lead> leadList)
     {
         map<string,string> mapSurVic = new map<string,string>();
        list<Lead> lstUpdLeads = new list<Lead>();
         for(merge__c m:[select id,name,SurvivorPartyId__c,VictimPartyId__c,Status__c,SurvivorAccountId__c,VictimAccountId__c
                                                        from Merge__c 
                                                       where Status__c = 'To Be Processed' and SurvivorAccountId__c <> null and VictimAccountId__c <> null])
         {
             mapSurVic.put(m.VictimAccountId__c, m.SurvivorAccountId__c);             
         }
         for(Lead currLeadRec:leadList)
        {
            if(mapSurVic.containsKey(currLeadRec.ConvertedAccountId)){
                currLeadRec.SurvivingAccount__c = mapSurVic.get(currLeadRec.ConvertedAccountId);
            }
            lstUpdLeads.add(currLeadRec);
        }
         System.debug('lstUpdLeads=='+lstUpdLeads);
         if(lstUpdLeads.size()>0){
       	 database.update(lstUpdLeads,false);
    	}
     }
    global void finish(Database.BatchableContext BC) 
    {
        //Vgtna_MergeAccountDetails.mergeAccDet();
        database.executeBatch(new Vgtna_BatchMergeAccountTeam(), 1000);  
            // execute any post-processing operations
    }
}