public class Vgtna_UserTriggerHandler  extends Vgtna_TriggerHandler {

    private Map <Id, User> newObjMap;
    private Map <Id, User> oldObjMap;
    private List <User> newObjList;
    private List <User> oldObjList;
    //private Vgtna_ByPassTriggers__c bypassFlag;

    public Vgtna_UserTriggerHandler() {
        this.newObjMap = (Map<Id, User>) Trigger.newMap;
        this.newObjList = (List<User>) Trigger.new;
        this.oldObjMap = (Map<Id, User>) Trigger.oldMap;
        this.oldObjList = (List<User>) Trigger.old;

    }

    public override void beforeInsert() {
    }
    public override void beforeUpdate() {
    }
    public override void beforeDelete() {
    }
    public override void afterInsert() {
        Vgtna_UserModel.manageDealerPermissionSets(newObjList, oldObjMap, Trigger.isInsert);
    }
    public override void afterUpdate() {
        Vgtna_UserModel.manageDealerPermissionSets(newObjList, oldObjMap, Trigger.isInsert);
    }
    public override void afterDelete() {
    }
    public override void afterUndelete() {
    }
}