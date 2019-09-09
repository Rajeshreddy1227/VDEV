public class Vgtna_PopulateMergeObjONETIMELOAD {
    public static void getAccDetailsOTL(){
        map<string,string> mapAccSurList = new map<string,string>();
        map<string,string> mapAccVicList = new map<string,string>();
        list<merge__c> updSurAccList = new list<merge__c>();
        list<merge__c> updVicAccList = new list<merge__c>();
        set<string> surPID = new set<string>();
        set<string> vicPID = new set<string>();
		 List<Merge__c> mergeList = new List<Merge__c> ([select id,name,SurvivorPartyId__c,VictimPartyId__c,Status__c,SurvivorAccountId__c,VictimAccountId__c
                                                        from Merge__c 
                                                       where Status__c = 'To Be Processed']);
        for(Merge__c m: mergeList){
            surPID.add(m.SurvivorPartyId__c);
            vicPID.add(m.VictimPartyId__c);
        }    
  //      system.debug('surPID'+surPID);
  //      system.debug('vicPID'+vicPID);
        for(Account a:[select id,party_id__c,name from Account where party_id__c in:surPID]){
            mapAccSurList.put(a.Party_ID__c,a.Id);
        }
 //       system.debug('mapAccSurList'+mapAccSurList);
        for(Account a:[select id,party_id__c,name from Account where party_id__c in:vicPID]){
            mapAccVicList.put(a.Party_ID__c,a.Id);
        }
  //      system.debug('mapAccVicList'+mapAccVicList);
        for(Merge__c mer:mergeList){
            if(mapAccSurList.containsKey(mer.SurvivorPartyId__c))
            {
                mer.SurvivorAccountId__c = mapAccSurList.get(mer.SurvivorPartyId__c);
                updSurAccList.add(mer);
            }
            if(mapAccVicList.containsKey(mer.VictimPartyId__c))
            {
                mer.VictimAccountId__c = mapAccVicList.get(mer.VictimPartyId__c);
                updVicAccList.add(mer);
            }
        }
        try{
            if(updSurAccList.size()>0){
                database.update(updSurAccList);
            }
             if(updVicAccList.size()>0){
                database.update(updVicAccList);
            }
        }
        catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
        }
        finally{
           // database.executeBatch(new Vgtna_BatchMergeOpty(), 1000); 
          /*  database.executeBatch(new Vgtna_BatchMergeContacts(), 1000); 
            database.executeBatch(new Vgtna_BatchMergeASR(), 500); 
            database.executeBatch(new Vgtna_BatchMergeCustomerProfile(), 1000); 
            database.executeBatch(new Vgtna_BatchMergeActivitiesTasks(), 1000); 
            database.executeBatch(new Vgtna_BatchMergeActivitiesEvents(), 1000); 
             database.executeBatch(new Vgtna_BatchMergeLeads(), 1000);
            Vgtna_MergeAccountDetails.mergeAccDet();*/
        }
    }

}