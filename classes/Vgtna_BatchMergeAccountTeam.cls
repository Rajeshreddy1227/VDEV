global class Vgtna_BatchMergeAccountTeam implements database.Batchable<sObject>{
	global string status = 'To Be Processed';
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query = 'select id,name,SurvivorPartyId__c,VictimPartyId__c,Status__c,SurvivorAccountId__c,VictimAccountId__c from Merge__c where Status__c =:status and SurvivorAccountId__c <> null and VictimAccountId__c <> null';
        //system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Merge__c> merList){
        map<string,string> mapSurVic = new map<string,string>();
        list<AccountTeamMember> lstUpdAccTeam = new list<AccountTeamMember>();
        
        for(Merge__c m:merList)
        {
            mapSurVic.put(m.VictimAccountId__c,m.SurvivorAccountId__c);
        }
        system.debug('MapSurVic--'+mapSurVic);
        system.debug('MapSurVic-KeySet--'+mapSurVic.keySet());
        set<string> atmSur  = new set<string>();
        for(AccountTeamMember atm : [select id,AccountId,UserId from  AccountTeamMember where AccountId=:mapSurVic.Values()])
        {
            //t.Account__c = mapSurVic.get(t.Account__c);
           // lstUpdTask.add(t);
           //string accUserRec = atm.AccountId+'-'+atm.UserId;
           //Building the unique string set with combination of Surviving Account and User Id
           atmSur.add(atm.AccountId+'-'+atm.UserId);
        }
        for(AccountTeamMember atm : [select id,AccountId,UserId from  AccountTeamMember where AccountId=:mapSurVic.keySet()])
        {
            //Fetch Account Team for each Victim Account and build the similar key as built for Surviving Account and Search atmSur
            //If not found which means that this Account Team record needs to be updated to new Survivng Account
            if(!atmSur.contains(mapSurVic.get(atm.AccountId)+'-'+atm.UserId))
            {
              AccountTeamMember atmClone = atm.clone();
              atmClone.AccountId = mapSurVic.get(atm.AccountId);
                lstUpdAccTeam.add(atmClone);
            }
        }
        system.debug('lstUpdAccTeam--'+lstUpdAccTeam);
        if(lstUpdAccTeam.size()>0){
            database.insert (lstUpdAccTeam,false);
        }  
    }
    global void finish(Database.BatchableContext BC) 
    {
            // execute any post-processing operations
       Vgtna_MergeAccountDetails.mergeAccDet();
    }
}