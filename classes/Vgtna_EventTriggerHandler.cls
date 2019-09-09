public with sharing class Vgtna_EventTriggerHandler  extends Vgtna_TriggerHandler {

    private Map <Id, Event> newObjMap;
    private Map <Id, Event> oldObjMap;
    private List <Event> newObjList;
    private List <Event> oldObjList;
    public User loggedInUser = new User();

    public Vgtna_EventTriggerHandler() { 
        this.newObjMap = (Map<Id, Event>) Trigger.newMap;
        this.newObjList = (List<Event>) Trigger.new;
        this.oldObjMap = (Map<Id, Event>) Trigger.oldMap;
        this.oldObjList = (List<Event>) Trigger.old;
        loggedInUser = [select id, contactid,Profile.Name from User where id= :userinfo.getUserId() limit 1];
    }


    public override void beforeInsert() {
        //Rajesh Adding Below
     	   Vgtna_EventTriggerHelper.populateSurvivorAccount(newObjList);
          //End
        Vgtna_EventTriggerHelper.populateDealerCode(newObjList);
    }

    public override void beforeUpdate() {     
        //Rajesh Adding Below
     	   Vgtna_EventTriggerHelper.populateSurvivorAccount(newObjList);
          //End
    }

    public override void beforeDelete() {
    }

    public override void afterInsert() {
        Vgtna_EventTriggerHelper.reparentAccEvent(newObjList, new Map<Id, Event>(), true);
        Vgtna_EventTriggerHelper.updateActivityType(newObjList);
    }

    public override void afterUpdate() {
        if(!System.isFuture()) {
            Vgtna_EventTriggerHelper.reparentAccEvent(newObjList, oldObjMap, false);
        }
    }

    public override void afterDelete() {
    }

    public override void afterUndelete() {
    }
}