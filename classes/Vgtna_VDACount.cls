global class Vgtna_VDACount implements Database.Batchable<SObject>, Database.Stateful
{
     // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(
            'SELECT Id from Account where RecordTypeId =\'012f200000122gBAAQ\''
        );
    }

    global void execute(Database.BatchableContext bc, List<Account> scope)
    {
        // process each batch of records
        Account[] updates = new Account[] {};
        Account[] Vupdates = new Account[] {};

		List<Account> accToUpdate = new List<Account>();

        for (AggregateResult ar : [ select AccountId a, count(Id) c from Asset where Brand__c = 'Mack' and AccountId in :scope
                                    group by AccountId ]) 
        {
            updates.add(new Account( Id = (Id) ar.get('a'), Mack_VDA_Count__c = (Integer) ar.get('c') ));
        }
        for (AggregateResult ar1 : [ select AccountId aa, count(Id) cc from Asset where Brand__c = 'Volvo' and AccountId in :scope
                                    group by AccountId ]) 
        {
            Vupdates.add(new Account( Id = (Id) ar1.get('aa'), Volvo_VDA_Count__c = (Integer) ar1.get('cc') ));
        }
        if(updates.size() > 0)
            update updates;
        if(Vupdates.size() > 0)
            update Vupdates;
    }

    global void finish(Database.BatchableContext bc)
    {
        System.debug(recordsProcessed + ' records processed.!');
    }    
}