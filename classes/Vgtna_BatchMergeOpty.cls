global class Vgtna_BatchMergeOpty implements Database.Batchable<sObject>{
    global string status = 'To Be Processed';
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query = 'select id,name,SurvivorPartyId__c,VictimPartyId__c,Status__c,SurvivorAccountId__c,VictimAccountId__c from Merge__c where Status__c =:status ';
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Merge__c> merList){
        map<string,string> mapSurVic = new map<string,string>();
        list<opportunity> updOpty = new list<opportunity>();
        
        for(Merge__c m:merList)
        {
            mapSurVic.put(m.VictimAccountId__c,m.SurvivorAccountId__c);
        }
        system.debug('MapSurVic--'+mapSurVic);
        system.debug('MapSurVic-KeySet--'+mapSurVic.keySet());
        
        for(opportunity o: [SELECT AccountId from Opportunity where AccountId=:mapSurVic.keySet()])
        {
            o.AccountId = mapSurVic.get(o.AccountId);
            updOpty.add(o);
        }
        system.debug('updateopty--'+updOpty);
        if(updOpty.size()>0){
            database.update (updOpty,false);
        }    
    }
    global void finish(Database.BatchableContext BC) 
    {
        	database.executeBatch(new Vgtna_BatchMergeContacts(), 1000);
            // execute any post-processing operations
    }

}