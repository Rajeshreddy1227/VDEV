public class Vgtna_AccountTriggerHandler  extends Vgtna_TriggerHandler {

    private Map <Id, Account> newObjMap;
    private Map <Id, Account> oldObjMap;
    private List <Account> newObjList;
    private List <Account> oldObjList;
    //private Vgtna_ByPassTriggers__c bypassFlag;

    public Vgtna_AccountTriggerHandler() {
        this.newObjMap = (Map<Id, Account>) Trigger.newMap;
        this.newObjList = (List<Account>) Trigger.new;
        this.oldObjMap = (Map<Id, Account>) Trigger.oldMap;
        this.oldObjList = (List<Account>) Trigger.old;

    }

    public override void beforeInsert() {
        Vgtna_AccountModel.setAorRegionCounty(newObjList, Trigger.isInsert);
    }
    public override void beforeUpdate() {
    }
    public override void beforeDelete() {
    }
    public override void afterInsert() {
        Vgtna_AccountModel.setTerritoryAOR(newObjList, oldObjMap, Trigger.isInsert);
    }
    public override void afterUpdate() {
        Vgtna_AccountModel.setTerritoryAOR(newObjList, oldObjMap, Trigger.isInsert);
    }
    public override void afterDelete() {
    }
    public override void afterUndelete() {
    }
}