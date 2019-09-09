global class Vgtna_BatchMergeContacts implements Database.Batchable<sObject>{
     global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query = 'select id,name,AccountId from Contact';
        //String query = 'select id,name,AccountId,Account.Name from Contact where AccountId in(select VictimAccountId__c from merge__c)';
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }

     global void execute(Database.BatchableContext BC, List<Contact> conList)
     {
         map<string,string> mapSurVic = new map<string,string>();
        list<Contact> lstUpdContacts = new list<Contact>();
         for(merge__c m:[select id,name,SurvivorPartyId__c,VictimPartyId__c,Status__c,SurvivorAccountId__c,VictimAccountId__c
                                                        from Merge__c 
                                                       where Status__c = 'To Be Processed' and SurvivorAccountId__c <> null and VictimAccountId__c <> null])
         {
             mapSurVic.put(m.VictimAccountId__c, m.SurvivorAccountId__c);             
         }
        system.debug('==mapSurVic=='+mapSurVic);
        for(Contact c:conList)
        {
            if(mapSurVic.containsKey(c.AccountId)){
                c.AccountId = mapSurVic.get(c.AccountId);
            }
            lstUpdContacts.add(c);
        }
         System.debug('lstUpdContacts=='+lstUpdContacts);
         if(lstUpdContacts.size()>0){
       	 database.update(lstUpdContacts,false);
    	}
     }
    
    global void finish(Database.BatchableContext BC) 
    {
        	database.executeBatch(new Vgtna_BatchMergeASR(), 500); 
            // execute any post-processing operations
    }
}