public class Vgtna_AssetTriggerHandler extends Vgtna_TriggerHandler {

    private Map <Id, Asset> newObjMap;
    private Map <Id, Asset> oldObjMap;
    private List <Asset> newObjList;
    private List <Asset> oldObjList;
    //private Vgtna_ByPassTriggers__c bypassFlag;

    public Vgtna_AssetTriggerHandler() {
        this.newObjMap = (Map<Id, Asset>) Trigger.newMap;
        this.newObjList = (List<Asset>) Trigger.new;
        this.oldObjMap = (Map<Id, Asset>) Trigger.oldMap;
        this.oldObjList = (List<Asset>) Trigger.old;
        
    }


    public override void beforeInsert() {

    }

    public override void beforeUpdate() {

    }

    public override void beforeDelete() {
            
    }

    public override void afterInsert() {
      Vgtna_AssetModel.WriteTerritoryAndUserAssignmentForPSR(newObjList, oldObjMap, Trigger.isInsert);
    }

    public override void afterUpdate() {

    }

    public override void afterDelete() {
    }

    public override void afterUndelete() {

    }
}