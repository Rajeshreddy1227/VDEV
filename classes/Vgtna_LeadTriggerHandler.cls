public with sharing class Vgtna_LeadTriggerHandler extends Vgtna_TriggerHandler {

    private Map <Id, Lead> newObjMap;
    private Map <Id, Lead> oldObjMap;
    private List <Lead> newObjList;
    private List <Lead> oldObjList;
    //private Vgtna_ByPassTriggers__c bypassFlag;
    private Map<Id, Schema.RecordTypeInfo> recordTypes;
    private Map<String, Schema.RecordTypeInfo> leadRecordTypesByName;
    public User loggedInUser = new User();

    public Vgtna_LeadTriggerHandler() { 
        this.newObjMap = (Map<Id, Lead>) Trigger.newMap;
        this.newObjList = (List<Lead>) Trigger.new;
        this.oldObjMap = (Map<Id, Lead>) Trigger.oldMap;
        this.oldObjList = (List<Lead>) Trigger.old;
        //this.bypassFlag = Vgtna_ByPassTriggers__c.getInstance('Lead');
        if(Test.isRunningTest()){
            //list<Vgtna_Record_Type_Cache__c> mappings = Vgtna_Record_Type_Cache__c.getall().values();
            //if (mappings.isEmpty() || (!mappings.isEmpty() && mappings.size() < 3)) Vgtna_Utils.loadRecordTypeCache();
        }
        
        if (recordTypes == null) {
            recordTypes = Schema.getGlobalDescribe()
                    .get('lead')
                    .getDescribe()
                    .getRecordTypeInfosById();
        }
        if (leadRecordTypesByName == null) {
            leadRecordTypesByName = Schema.getGlobalDescribe()
                    .get('lead')
                    .getDescribe()
                    .getRecordTypeInfosByName();
        }
        
        loggedInUser = [select id, contactid,Profile.Name from User where id= :userinfo.getUserId() limit 1];
    }


    public override void beforeInsert() {
//        if (bypassFlag == null || (bypassFlag <> null && bypassFlag.ByPass__c == false)) {
        
        // Matt on 10/26 as per Subho / Wulf 
        if(loggedInUser.contactid != null)
        {
           // It means it's a dealer user
            Vgtna_LeadModel.assignDealerCodeAndBrand(newObjList, null, Trigger.isInsert);
        }
        
        if(loggedInUser.Profile.Name == Label.Vgtna_System_Integrator_Profile_Name)
        {
            // It's system integrator doing data load. Fire AOR match
            
            Vgtna_LeadModel.assignDealership(newObjList,null,true);
        }
        
        

    }

    public override void beforeUpdate() {

//      if (bypassFlag == null || (bypassFlag <> null && bypassFlag.ByPass__c == false)) {
       
       // Matt on 10/26 as per Subho / Wulf
       
        //Vgtna_LeadModel.assignDealership(newObjList,oldObjMap,false);
    }

    public override void beforeDelete() {
//      if (bypassFlag == null || (bypassFlag <> null && bypassFlag.ByPass__c == false)) {
            
    }

    public override void afterInsert() {
        
        if(loggedInUser.Profile.Name == Label.Vgtna_System_Integrator_Profile_Name)
        {
            // It's system integrator doing data load. Fire AOR match
            
             Vgtna_LeadModel.assignDealerQueuesAfterInsert(newObjList);
        }
        
        if(loggedInUser.contactid != null)
        {
           // It means it's a dealer user. Invoke method to add Dealer Group to Lead share.
            Vgtna_LeadModel.assignLeadShare4PortalUsers(newObjList);
        }
        
       
    }

    public override void afterUpdate() {
			// Mantain sharing for the dealer public group managers
			Vgtna_LeadModel.assignLeadShare(newObjList,oldObjMap);
        
//        if (bypassFlag == null || (bypassFlag <> null && bypassFlag.ByPass__c == false)) {

    }

    public override void afterDelete() {
//        if (bypassFlag == null || (bypassFlag <> null && bypassFlag.ByPass__c == false)) {
    }

    public override void afterUndelete() {
//        if (bypassFlag == null || (bypassFlag <> null && bypassFlag.ByPass__c == false)) {

    }
}