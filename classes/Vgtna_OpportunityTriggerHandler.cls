public Without Sharing class Vgtna_OpportunityTriggerHandler  extends Vgtna_TriggerHandler { 

    private Map <Id, Opportunity> newObjMap;
    private Map <Id, Opportunity> oldObjMap;
    private List <Opportunity> newObjList;
    private List <Opportunity> oldObjList;
    //private Vgtna_ByPassTriggers__c bypassFlag;
    private Map<Id, Schema.RecordTypeInfo> recordTypes;
    private Map<String, Schema.RecordTypeInfo> OpportunityRecordTypesByName;

    public Vgtna_OpportunityTriggerHandler() {
        this.newObjMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.newObjList = (List<Opportunity>) Trigger.new;
        this.oldObjMap = (Map<Id, Opportunity>) Trigger.oldMap;
        this.oldObjList = (List<Opportunity>) Trigger.old;
        if(Test.isRunningTest()){
        }
        
        if (recordTypes == null) {
            recordTypes = Schema.getGlobalDescribe()
                    .get('Opportunity')
                    .getDescribe()
                    .getRecordTypeInfosById();
        }
        if (OpportunityRecordTypesByName == null) {
            OpportunityRecordTypesByName = Schema.getGlobalDescribe()
                    .get('Opportunity')
                    .getDescribe()
                    .getRecordTypeInfosByName();
        }
    }


    public override void beforeInsert() {
//        if (bypassFlag == null || (bypassFlag <> null && bypassFlag.ByPass__c == false)) {
        Vgtna_OpportunityModel.SetCreditedToDealerCode(newObjList,null,Trigger.isInsert);
            
    }

    public override void beforeUpdate() {
        Vgtna_OpportunityModel.SetCreditedToDealerCode(newObjList,oldObjMap,Trigger.isInsert);
    }

    public override void beforeDelete() {
    }

    public override void afterInsert() {
            Vgtna_OpportunityModel.createAndAssignOpportunityTeam(newObjList,null,Trigger.isInsert);
        
        
    }

    public override void afterUpdate() {
           Vgtna_OpportunityModel.createAndAssignOpportunityTeam(newObjList,oldObjMap,Trigger.isInsert);
    }

    public override void afterDelete() {
    }

    public override void afterUndelete() {

    }
}