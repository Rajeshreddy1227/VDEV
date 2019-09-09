global class Vgtna_BatchMergeActivitiesTasks implements database.Batchable<sObject>{
	global string status = 'To Be Processed';
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query = 'select id,name,SurvivorPartyId__c,VictimPartyId__c,Status__c,SurvivorAccountId__c,VictimAccountId__c from Merge__c where Status__c =:status and SurvivorAccountId__c <> null and VictimAccountId__c <> null';
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Merge__c> merList){
        map<string,string> mapSurVic = new map<string,string>();
        list<Task> lstUpdTask = new list<Task>();
        
        for(Merge__c m:merList)
        {
            mapSurVic.put(m.VictimAccountId__c,m.SurvivorAccountId__c);
        }
        system.debug('MapSurVic--'+mapSurVic);
        system.debug('MapSurVic-KeySet--'+mapSurVic.keySet());
        
        for(Task t : [select subject, id, AccountId, WhatId, whoId, Account__c, description from Task where Account__c=:mapSurVic.keySet()])
        {
            t.Account__c = mapSurVic.get(t.Account__c);
            lstUpdTask.add(t);
        }
        system.debug('lstUpdTask--'+lstUpdTask);
        if(lstUpdTask.size()>0){
            database.update (lstUpdTask,false);
        }    
    }
    global void finish(Database.BatchableContext BC) 
    {
        database.executeBatch(new Vgtna_BatchMergeActivitiesEvents(), 1000); 
            // execute any post-processing operations
    }
}