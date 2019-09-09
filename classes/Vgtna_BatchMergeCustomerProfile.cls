global class Vgtna_BatchMergeCustomerProfile implements Database.Batchable<sObject>{
    global string status = 'To Be Processed';
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query = 'select id,name,SurvivorPartyId__c,VictimPartyId__c,Status__c,SurvivorAccountId__c,VictimAccountId__c from Merge__c where Status__c =:status and SurvivorAccountId__c <> null and VictimAccountId__c <> null';
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Merge__c> merList){
        map<string,string> mapSurVic = new map<string,string>();
        list<Customer_Profile__c> lstUpdCustPro = new list<Customer_Profile__c>();
        
        for(Merge__c m:merList)
        {
            mapSurVic.put(m.VictimAccountId__c,m.SurvivorAccountId__c);
        }
        system.debug('MapSurVic--'+mapSurVic);
        system.debug('MapSurVic-KeySet--'+mapSurVic.keySet());
        
        for(Customer_Profile__c cp : [select id,name,key_account__c,customer_account__c,dealer_account__c from customer_profile__c where customer_account__c=:mapSurVic.keySet()])
        {
            cp.customer_account__c = mapSurVic.get(cp.customer_account__c);
            lstUpdCustPro.add(cp);
        }
        system.debug('lstUpdCustPro--'+lstUpdCustPro);
        if(lstUpdCustPro.size()>0){
            database.update (lstUpdCustPro,false);
        }    
    }
    global void finish(Database.BatchableContext BC) 
    {
        	database.executeBatch(new Vgtna_BatchMergeActivitiesTasks(), 1000);
            // execute any post-processing operations
    }

}