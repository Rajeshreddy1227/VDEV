public with sharing class Vgtna_TaskTriggerHandler  extends Vgtna_TriggerHandler {

    private Map <Id, Task> newObjMap;
    private Map <Id, Task> oldObjMap;
    private List <Task> newObjList;
    private List <Task> oldObjList;
    public User loggedInUser = new User();

    public Vgtna_TaskTriggerHandler() { 
        this.newObjMap = (Map<Id, Task>) Trigger.newMap;
        this.newObjList = (List<Task>) Trigger.new;
        this.oldObjMap = (Map<Id, Task>) Trigger.oldMap;
        this.oldObjList = (List<Task>) Trigger.old;
        loggedInUser = [select id, contactid,Profile.Name from User where id= :userinfo.getUserId() limit 1];
    }


    public override void beforeInsert() {
        //Rajesh Adding Below
            Vgtna_TaskTriggerHelper.populateSurvivorAccount(newObjList);
            //End
        Vgtna_TaskTriggerHelper.populateDealerCode(newObjList);
    }

    public override void beforeUpdate() { 
         //Rajesh Adding Below
        Vgtna_TaskTriggerHelper.populateSurvivorAccount(newObjList);
    }

    public override void beforeDelete() {
    }

    public override void afterInsert() {
        Vgtna_TaskTriggerHelper.reparentAccTask(newObjList, new Map<Id, Task>(), true);
        Vgtna_TaskTriggerHelper.updateActivityType(newObjList);
    }

    public override void afterUpdate() {
        if(!System.isFuture()) {
            Vgtna_TaskTriggerHelper.reparentAccTask(newObjList, oldObjMap, false);
        }
    }

    public override void afterDelete() {
    }

    public override void afterUndelete() {
    }
}