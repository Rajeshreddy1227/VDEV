global class Vgtna_BatchMergeActivitiesEvents implements Database.Batchable<sObject>{
   global string status = 'To Be Processed';
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query = 'select id,name,SurvivorPartyId__c,VictimPartyId__c,Status__c,SurvivorAccountId__c,VictimAccountId__c from Merge__c where Status__c =:status AND SurvivorAccountId__c <> null and VictimAccountId__c <> null';
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Merge__c> merList){
        map<string,string> mapSurVic = new map<string,string>();
        list<Event> lstUpdEvent = new list<Event>();
        
        for(Merge__c m:merList)
        {
            mapSurVic.put(m.VictimAccountId__c,m.SurvivorAccountId__c);
        }
        system.debug('MapSurVic--'+mapSurVic);
        system.debug('MapSurVic-KeySet--'+mapSurVic.keySet());
        
        for(Event evt : [select id,Account__c,WhatId from Event where Account__c=:mapSurVic.keySet()])
        {
            evt.Account__c = mapSurVic.get(evt.Account__c);
            lstUpdEvent.add(evt);
        }
        system.debug('lstUpdEvent--'+lstUpdEvent);
        if(lstUpdEvent.size()>0){
            database.update (lstUpdEvent,false);
        }    
    }
    global void finish(Database.BatchableContext BC) 
    {
        database.executeBatch(new Vgtna_BatchMergeLeads(), 1000);
            // execute any post-processing operations
    }

}