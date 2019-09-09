public with sharing class Vgtna_TaskTriggerHelper {
    public static void populateDealerCode(List<Task> newList) {
        User usr = [SELECT Id, Dealer_Code__c,Dealer_Brand__C, ContactId, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        for(Task T : newList) {
            T.Dealer_Code__c = String.isNotBlank(usr.Dealer_Code__c)?usr.Dealer_Code__c:'';
             T.Brand__C = String.isNotBlank(usr.Dealer_Brand__C)?usr.Dealer_Brand__C:'';
            T.CreatedBy_Profile__c = usr.Profile.Name;
            if(usr.ContactId != null) {
                t.IsVisibleInSelfService = true;
            }
        }
    }
//Rajesh Adding Below method
    public static void populateSurvivorAccount(List<Task> newList)
    {
        map<id,id> taskAccMap = new map<id,id>();
        for(Task t: newList){
            if(T.WhatId != null && String.ValueOf(T.WhatId).StartsWith('001')&&trigger.isInsert){
                taskAccMap.put(t.Id,t.WhatId);
            }
            else if(T.Account__c != null && String.ValueOf(T.Account__c).StartsWith('001')&&trigger.isUpdate){
                taskAccMap.put(t.Id,t.Account__c);
            }
        }
        map<id,id> surVic = new Map<id,id>();
        for(Account a:[select SurvivingAccountId__c,id from Account where id = :taskAccMap.values()]){
            if(a.SurvivingAccountId__c !=null){
                surVic.put(a.id,a.SurvivingAccountId__c);
            }
        }
        for(Task t:newList){
            if(T.WhatId != null && String.ValueOf(T.WhatId).StartsWith('001') && trigger.isInsert){
                if(surVic.get(T.WhatId)!=null){
                    t.WhatId = surVic.get(T.WhatId);
                }
            }
            else if(T.Account__c != null && String.ValueOf(T.Account__c).StartsWith('001') && trigger.isUpdate){
                if(surVic.get(T.Account__c)!=null)    {
                    t.Account__c = surVic.get(T.Account__c);
                }
            }
        }
    }//End populateSurvivorAccount    
    
    public static void updateActivityType(List<Task> newList) {
        List<Id> tIds = new List<Id>();
        for(Task t : newlist) {
            tIds.add(t.Id);
        }    
        if(tIds.size() > 0) {
            futureUpdateActType(tIds);
        }
    }
    
    @future
    public static void futureUpdateActType(List<Id> tIds) {
        List<Task> tlist = [SELECT Id, TaskSubtype, Activity_Type__c FROM Task WHERE Id IN :tIds];
        for(Task t : tlist) {
            t.Activity_Type__c = t.TaskSubtype;
        }
        update tlist;
    }
    
    public static void reparentAccTask(List<Task> newList, Map<Id, Task> oldMap, Boolean isInsert) {
    system.debug('newlist: '+newlist[0]+'--ownerid--'+newList[0].OwnerId);
        Id loggedUserId = UserInfo.getUserId();
        List<Task> newTask = new List<Task>();
        try {
            for(Task T : newList) {
                if(T.WhatId != null && String.ValueOf(T.WhatId).StartsWith('001') && isInsert) {
                    newTask.add(T);
                } else if(T.WhatId != null && String.ValueOf(T.WhatId).StartsWith('001') && !isInsert && (T.OwnerId != oldMap.get(T.Id).OwnerId || T.WhatId != oldMap.get(T.Id).WhatId)) { 
                    newTask.add(T);
                }
            }
            if(!newTask.isEmpty()) {
                //The variable tIdOwnAccIdMap stores the taskId in the key and 
                //the combination of CustomerActivity Id 
                Map<Id, String> tIdOwnAccIdMap = new Map<Id, String>();
                List<Id> tOwnerId = new List<Id>();
                List<Id> tIdsToInsertCustAct = new List<Id>();
                Map<Id, Customer_Activity__c> caMap = new Map<Id, Customer_Activity__c>();
                
                for(Task t : newTask) {
                system.debug('t.id: '+t.Id);
                    townerId.add(t.OwnerId);
                }
                for(Customer_Activity__c ca : [SELECT Id, OwnerId FROM Customer_Activity__c WHERE OwnerId IN :townerId]) {
                    caMap.put(ca.OwnerId, ca);
                }
                for(Task t  : newTask) {
                    if(caMap.containsKey(t.OwnerId)) {
                        tIdOwnAccIdMap.put(t.Id, caMap.get(t.OwnerId).Id);
                    } else {
                        tIdsToInsertCustAct.add(t.Id);
                    }
                }
                system.debug('tIdOwnIdMap0: '+tIdOwnAccIdMap);
                if(!tIdOwnAccIdMap.isEmpty() || !tIdsToInsertCustAct.isEmpty()) {
                    updateAccTasksOwnerId(tIdOwnAccIdMap, tIdsToInsertCustAct, loggedUserId);
                }
            }
        } catch (exception e) {
            System.debug('exception occured in the method Vgtna_TaskTriggerHelper.reparentAccTaskat line: '+e.getLineNumber()+' with exception '+e.getMessage());
        }
    }
    
    @future
    public static void updateAccTasksOwnerId(Map<Id, String> tIdOwnAccIdMap, List<Id> tIdsToInsertCustAct, Id loggedUserId) {
        try {
            Map<Id, Task> tMap = new Map<Id, Task>([SELECT Id, OwnerId, WhatId, WhoId, Status FROM Task WHERE Id IN :tIdsToInsertCustAct OR Id IN :tIdOwnAccIdMap.keySet()]);
            User usr = [SELECT Id, Dealer_Brand__c, ContactId, Dealer_Code__c,Primary_Dealer_code__c, Profile.Name FROM User WHERE Id = :loggedUserId];
            List<Task> updateTasks = new List<Task>();
            List<Customer_Activity__c> caList = new List<Customer_Activity__c>();
            Map<Id, List<Id>> ownIdTaskIdsMap = new Map<Id, List<Id>>();
            Map<Id, Customer_Activity__c> caOwnIdCaMap = new Map<Id, Customer_Activity__c>();
            system.debug('tIdOwnIdMap: '+tIdOwnAccIdMap);
            if(!tIdOwnAccIdMap.isEmpty()) {
                for(Id tId : tIdOwnAccIdMap.keySet()) {
                    Task t = new Task();
                    t.Id = tId;
                    t.Account__c = tMap.get(tId).WhatId;
                    //t.Status = tMap.get(tId).Status;
                    t.WhoId = null;
                    t.WhatId = tIdOwnAccIdMap.get(tId);
                    t.Brand__c = usr.Dealer_Brand__c;
                    t.Dealer_code__c = usr.Dealer_code__c;
                    updateTasks.add(t);
                }
            }
            if(!tIdsToInsertCustAct.isEmpty()) {
                for(Id tId : tIdsToInsertCustAct) {
                    if(!ownIdTaskIdsMap.containsKey(tMap.get(tId).OwnerId)) {
                        ownIdTaskIdsMap.put(tMap.get(tId).OwnerId, new List<Id>{tId});
                    } else {
                        ownIdTaskIdsMap.get(tMap.get(tId).OwnerId).add(tId);
                    }
                    Customer_Activity__c ca = new Customer_Activity__c();
                    ca.Name = userInfo.getFirstname()+' '+userInfo.getLastName();
                    ca.OwnerId = tMap.get(tId).OwnerId;
                    ca.Dealer_Brand__c = usr.Dealer_Brand__c;
                    ca.CreatedBy_Profile__c = usr.Profile.Name;
                    if(usr.contactId != null) {
                        ca.IsPartner__c = true;
                    }
                    caList.add(ca);
                }
                if(!caList.isEmpty()) {
                    insert caList;
                    for(Customer_Activity__c ca : caList) {
                        caOwnIdCaMap.put(ca.OwnerId, ca);
                    }
                    for(Id tOwnId : ownIdTaskIdsMap.keySet()) {
                        for(Id tId : ownIdTaskIdsMap.get(tOwnId)) {
                            Task t = new Task();
                            t.Id = tId;
                            t.Account__c = tMap.get(tId).WhatId;
                            //t.Status = tMap.get(tId).Status;
                            t.Brand__c = usr.Dealer_Brand__c;
                            t.WhatId = caOwnIdCaMap.get(tOwnId).Id;
                            t.WhoId = null;
                            t.Dealer_code__c = usr.Dealer_code__c;
                            updateTasks.add(t);
                        }
                    }
                    
                }
            }
            if(!updateTasks.isEmpty()) {
                update updateTasks;
                
            }
        } catch (exception e) {
            System.debug('exception occured in the method Vgtna_TaskTriggerHelper.updateAccTasksOwnerId at line: '+e.getLineNumber()+' with exception '+e.getMessage());
        }
    }
}