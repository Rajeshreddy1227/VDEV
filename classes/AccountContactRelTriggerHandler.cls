public class AccountContactRelTriggerHandler extends Vgtna_TriggerHandler {

    private Map <Id, AccountContactRelation> newObjMap;
    private Map <Id, AccountContactRelation> oldObjMap;
    private List <AccountContactRelation> newObjList;
    private List <AccountContactRelation> oldObjList;
    //private Vgtna_ByPassTriggers__c bypassFlag;

    public AccountContactRelTriggerHandler() {
        this.newObjMap = (Map<Id, AccountContactRelation>) Trigger.newMap;
        this.newObjList = (List<AccountContactRelation>) Trigger.new;
        this.oldObjMap = (Map<Id, AccountContactRelation>) Trigger.oldMap;
        this.oldObjList = (List<AccountContactRelation>) Trigger.old;
        
    }

    
    public override void beforeInsert() {

    }

    public override void beforeUpdate() {

    }

    public override void beforeDelete() {
            Vgtna_AccountContactRelationModel.removeSharingToRoles(oldObjMap);
    }

    public override void afterInsert() {
        Vgtna_AccountContactRelationModel.setSharingToRoles(newObjMap, oldObjMap, Trigger.isInsert);
    }

    public override void afterUpdate() {
        Vgtna_AccountContactRelationModel.setSharingToRoles(newObjMap, oldObjMap, Trigger.isInsert);
    }

    public override void afterDelete() {
        
    }

    public override void afterUndelete() {

    }

}