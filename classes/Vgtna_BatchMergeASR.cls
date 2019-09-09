global class Vgtna_BatchMergeASR implements Database.Batchable<sObject>{
   global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query = 'select id,Account__c,Sales_Rep__c,Sales_Rep__r.user_id__c,Party_Id__c,Dealer_Code__c,External_id__c from Assigned_Sales_Rep__c';
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    } 
    global void execute(Database.BatchableContext BC, List<Assigned_Sales_Rep__c> asrList)
     {
         //Stores Surviver and Victim AccountIds from Merge table
         map<string,string> mapSurVic = new map<string,string>();
         //Stores Surviver and Victim PartyIds from Merge table
         map<string,string> mapSurVicPID = new map<string,string>();
         //List to update all ASR records with Surviving Account Ids
         list<Assigned_Sales_Rep__c> listUpdASR = new list<Assigned_Sales_Rep__c>();
         //List to delete all to-be duplicate victims as existing ASR with surviving details Exist
         list<Assigned_Sales_Rep__c> delList = new list<Assigned_Sales_Rep__c>();
         //list of Strings that can store all the Surviving PartyIds where we query using LIKE
         list<string> surPartyId = new list<string>();
          //Set that stores all the External Ids from ASR for surviving Records
         set<string> asrSurDet = new set<string>();
         string[] strSurPID = new String[]{};
             list<string> surPartyIdOnly = new list<string>();
             //Query on Merge table to collect details 
         for(merge__c m:[select id,name,SurvivorPartyId__c,VictimPartyId__c,Status__c,SurvivorAccountId__c,VictimAccountId__c
                                                        from Merge__c 
                                                       where Status__c = 'To Be Processed' and SurvivorAccountId__c <> null and VictimAccountId__c <> null])
         {
             mapSurVic.put(m.VictimAccountId__c, m.SurvivorAccountId__c);   
             mapSurVicPID.put(m.VictimPartyId__c, m.SurvivorPartyId__c);
             surPartyIdOnly.add(m.SurvivorPartyId__c);
             surPartyId.add('%'+m.SurvivorPartyId__c+'%');
             strSurPID.add('%'+m.SurvivorPartyId__c+'%');
         }
         //Collect External Ids of ASR for the surviving records
         //for(Assigned_Sales_Rep__c asr:[select id,Account__c,Sales_Rep__c,Sales_Rep__r.user_id__c,Party_Id__c,External_id__c from Assigned_Sales_Rep__c where External_Id__c like:surPartyId])
         for(Assigned_Sales_Rep__c asr:[select id,Account__c,Sales_Rep__c,Sales_Rep__r.user_id__c,Party_Id__c,External_id__c from Assigned_Sales_Rep__c where party_id__c IN :surPartyIdOnly])
         {
             asrSurDet.add(asr.External_id__c);
         }
         for(Assigned_Sales_Rep__c currASRRec: asrList)
         {
             if(mapSurVic.ContainsKey(currASRRec.Account__c))
             {
                 if(mapSurVicPID.containsKey(currASRRec.Party_ID__c))
                 {
                     string sSurExtId;
                     //Build the External Id of the surviving Record
                     if(String.isBlank(currASRRec.Dealer_Code__c)){
                 	 sSurExtId = mapSurVicPID.get(currASRRec.Party_ID__c)+'_'+currASRRec.Sales_Rep__r.user_id__c+'_';
                     }else
                     {
                       sSurExtId = mapSurVicPID.get(currASRRec.Party_ID__c)+'_'+currASRRec.Sales_Rep__r.user_id__c+'_'+currASRRec.Dealer_Code__c;  
                     }
                     //Check for Duplicate--Does ASR already Exist if we change the Victim ASR record
                     boolean result = asrSurDet.contains(sSurExtId);
                // integer isCount = [select count() from Assigned_Sales_Rep__c where external_id__c=:sSurExtId];
                // Delete Victim ASR if already exists
                     if(result){
                         delList.add(currASRRec);
                     }
                     //Update Victim ASR if it doesnt exist
                     else{
                         currASRRec.Account__c = mapSurVic.get(currASRRec.Account__c); 
                         listUpdASR.add(currASRRec);
                     }
                                 
                 }
             }             
            
         }
         if(delList.size()>0){
             Database.delete(delList,false);
         }
         if(listUpdASR.size()>0){
             Database.update(listUpdASR,false);
         }
     }
    global void finish(Database.BatchableContext BC) 
    {
        	database.executeBatch(new Vgtna_BatchMergeCustomerProfile(), 1000); 
            // execute any post-processing operations
    }

}