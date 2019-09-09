public with sharing class Vgtna_EventTriggerHelper {
    public static void populateDealerCode(List<Event> newList) {
        User usr = [SELECT Id, Dealer_Code__c,  Dealer_Brand__c, ContactId, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        for(Event e : newList) {
            e.Dealer_Code__c = String.isNotBlank(usr.Dealer_Code__c)?usr.Dealer_Code__c:'';
            e.Brand__C = String.isNotBlank(usr.Dealer_Brand__C)?usr.Dealer_Brand__c:'';
            e.CreatedBy_Profile__c = usr.Profile.Name;
            if(usr.ContactId != null) {
                e.IsVisibleInSelfService = true;
            }
        }
    }
 //Rajesh Adding Below method
    public static void populateSurvivorAccount(List<Event> newList)
    {
        map<id,id> eventAccMap = new map<id,id>();
        for(Event e: newList){
            if(e.WhatId != null && String.ValueOf(e.WhatId).StartsWith('001')&&trigger.isInsert){
                eventAccMap.put(e.Id,e.WhatId);
            }
            else if(e.Account__c != null && String.ValueOf(e.Account__c).StartsWith('001')&&trigger.isUpdate){
                eventAccMap.put(e.Id,e.Account__c);
            }
        }
        map<id,id> surVic = new Map<id,id>();
        for(Account a:[select SurvivingAccountId__c,id from Account where id = :eventAccMap.values()]){
            if(a.SurvivingAccountId__c !=null){
                surVic.put(a.id,a.SurvivingAccountId__c);
            }
        }
        for(Event e :newList){
            if(e.WhatId != null && String.ValueOf(e.WhatId).StartsWith('001') && trigger.isInsert){
                if(surVic.get(e.WhatId)!=null){
                    e.WhatId = surVic.get(e.WhatId);
                }
            }
            else if(e.Account__c != null && String.ValueOf(e.Account__c).StartsWith('001') && trigger.isUpdate){
                if(surVic.get(e.Account__c)!=null)    {
                    e.Account__c = surVic.get(e.Account__c);
                }
            }
        }
    }//End populateSurvivorAccount  
    
    public static void updateActivityType(List<Event> newList) {
        List<Id> eIds = new List<Id>();
        for(Event e : newlist) {
            eIds.add(e.Id);
        }    
        if(eIds.size() > 0) {
            futureUpdateActType(eIds);
        }
    }
    
    @future
    public static void futureUpdateActType(List<Id> eIds) {
        List<Event> eList = [SELECT Id, Activity_Type__c FROM Event WHERE Id IN :eIds];
        for(event e : eList) {
            e.Activity_Type__c = 'Event';
        }
        try {
          update eList;
        } catch (exception ex) {
            System.debug('entered exception with message in Vgtna_EventTriggerHelper '+ex.getMessage()+' at line number '+ex.getLineNumber());
        }
    }
    
    public static void reparentAccEvent(List<Event> newList, Map<Id, Event> oldMap, Boolean isInsert) {
        try {
            Id loggedUserId = UserInfo.getUserId();
            List<Event> newEvent = new List<Event>();
            for(Event E : newList) {
                if(E.WhatId != null && String.ValueOf(E.WhatId).StartsWith('001') && isInsert) {
                    newEvent.add(E);
                } else if(E.WhatId != null && String.ValueOf(E.WhatId).StartsWith('001') && !isInsert && (E.OwnerId != oldMap.get(E.Id).OwnerId || E.WhatId != oldMap.get(E.Id).WhatId)) { 
                    newEvent.add(E);
                }
            }
            if(!newEvent.isEmpty()) {
                //The variable tIdOwnAccIdMap stores the taskId in the key and 
                //the combination of CustomerActivity Id
                Map<Id, String> eIdOwnAccIdMap = new Map<Id, String>();
                List<Id> eOwnerId = new List<Id>();
                List<Id> eIdsToInsertCustAct = new List<Id>();
                Map<Id, Customer_Activity__c> caMap = new Map<Id, Customer_Activity__c>();
                
                for(Event e : newEvent) {
                system.debug('e.id: '+e.Id);
                    eownerId.add(e.OwnerId);
                }
                for(Customer_Activity__c ca : [SELECT Id, OwnerId FROM Customer_Activity__c WHERE OwnerId IN :eownerId]) {
                    caMap.put(ca.OwnerId, ca);
                }
                for(Event e  : newEvent) {
                    if(caMap.containsKey(e.OwnerId)) {
                        eIdOwnAccIdMap.put(e.Id, caMap.get(e.OwnerId).Id);
                    } else {
                        eIdsToInsertCustAct.add(e.Id);
                    }
                }
                system.debug('eIdOwnIdMap0: '+eIdOwnAccIdMap);
                if(!eIdOwnAccIdMap.isEmpty() || !eIdsToInsertCustAct.isEmpty()) {
                    updateAccEventsOwnerId(eIdOwnAccIdMap, eIdsToInsertCustAct, loggedUserId);
                }
            }
        } catch (exception e) {
            System.debug('exception occured in the method Vgtna_EventTriggerHelper.reparentAccEvent line: '+e.getLineNumber()+' with exception '+e.getMessage());
        }
    }
    
    @future
    public static void updateAccEventsOwnerId(Map<Id, String> eIdOwnAccIdMap, List<Id> eIdsToInsertCustAct, Id loggedUserId) {
        try {
            Map<Id, Event> eMap = new Map<Id, Event>([SELECT Id, OwnerId, WhatId, WhoId FROM Event WHERE Id IN :eIdsToInsertCustAct OR Id IN :eIdOwnAccIdMap.keySet()]);
            User usr = [SELECT Id, Dealer_Brand__c, ContactId, Dealer_Code__c, Primary_Dealer_Code__c, Profile.Name FROM User WHERE Id = :loggedUserId];
            List<Event> updateEvents = new List<Event>();
            List<Customer_Activity__c> caList = new List<Customer_Activity__c>();
            Map<Id, List<Id>> ownIdEventIdsMap = new Map<Id, List<Id>>();
            Map<Id, Customer_Activity__c> caOwnIdCaMap = new Map<Id, Customer_Activity__c>();
            system.debug('eIdOwnIdMap: '+eIdOwnAccIdMap);
            if(!eIdOwnAccIdMap.isEmpty()) {
                for(Id eId : eIdOwnAccIdMap.keySet()) {
                    Event e = new Event();
                    e.Id = eId;
                    e.Account__c = eMap.get(eId).WhatId;
                    e.WhoId = null;
                    e.WhatId = eIdOwnAccIdMap.get(eId);
                    e.Brand__c = usr.Dealer_Brand__c;
                    e.Dealer_code__c = usr.Dealer_Code__c;
                    updateEvents.add(e);
                }
            }
            if(!eIdsToInsertCustAct.isEmpty()) {
                //Map<Id, Task> tMap = new Map<Id, Task>([SELECT Id, OwnerId, WhatId, WhoId FROM Task WHERE Id IN :tIdsToInsertCustAct]);
                for(Id eId : eIdsToInsertCustAct) {
                    if(!ownIdEventIdsMap.containsKey(eMap.get(eId).OwnerId)) {
                        ownIdEventIdsMap.put(eMap.get(eId).OwnerId, new List<Id>{eId});
                    } else {
                        ownIdEventIdsMap.get(eMap.get(eId).OwnerId).add(eId);
                    }
                    Customer_Activity__c ca = new Customer_Activity__c();
                    ca.Name = userInfo.getFirstname()+' '+userInfo.getLastName();
                    if(usr.contactId != null) {
                        ca.IsPartner__c = true;
                    }
                    ca.OwnerId = eMap.get(eId).OwnerId;
                    ca.Dealer_Brand__c = usr.Dealer_Brand__c;
                    ca.CreatedBy_Profile__c = usr.Profile.Name;
                    caList.add(ca);
                }
                if(!caList.isEmpty()) {
                    insert caList;
                    for(Customer_Activity__c ca : caList) {
                        caOwnIdCaMap.put(ca.OwnerId, ca);
                    }
                    for(Id eOwnId : ownIdEventIdsMap.keySet()) {
                        for(Id eId : ownIdEventIdsMap.get(eOwnId)) {
                            Event e = new Event();
                            e.Id = eId;
                            e.Account__c = eMap.get(eId).WhatId;
                            //e.Contact__c = eMap.get(eId).WhoId;
                            e.Brand__c = usr.Dealer_Brand__c;
                            e.WhatId = caOwnIdCaMap.get(eOwnId).Id;
                            e.WhoId = null;
                            e.Dealer_code__c = usr.Dealer_Code__c;
                            updateEvents.add(e);
                        }
                    }
                    
                }
            }
            if(!updateEvents.isEmpty()) {
                update updateEvents;
                
            }
        } catch (exception e) {
            System.debug('exception occured in the method Vgtna_EventTriggerHelper.updateAccEventsOwnerId line: '+e.getLineNumber()+' with exception '+e.getMessage());
        }
    }
}