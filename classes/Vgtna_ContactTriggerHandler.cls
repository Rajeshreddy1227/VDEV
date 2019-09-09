public with sharing class Vgtna_ContactTriggerHandler  extends Vgtna_TriggerHandler {

    private Map <Id, Contact> newObjMap;
    private Map <Id, Contact> oldObjMap;
    private List <Contact> newObjList;
    private List <Contact> oldObjList;
    public User loggedInUser = new User();

    public Vgtna_ContactTriggerHandler() { 
        this.newObjMap = (Map<Id, Contact>) Trigger.newMap;
        this.newObjList = (List<Contact>) Trigger.new;
        this.oldObjMap = (Map<Id, Contact>) Trigger.oldMap;
        this.oldObjList = (List<Contact>) Trigger.old;
        loggedInUser = [select id, contactid,Profile.Name from User where id= :userinfo.getUserId() limit 1];
    }


    public override void beforeInsert() {
        if(loggedInUser.Profile.Name != Label.Vgtna_System_Integrator_Profile_Name)
        {
            Vgtna_ContactModel.assignSource(newObjList,null,true);
        }
        Vgtna_ContactModel.FixSourceLookup(newObjList,null,true);
		
    }

    public override void beforeUpdate() {
        Vgtna_ContactModel.FixSourceLookup(newObjList,null,true);
    }

    public override void beforeDelete() {
    }

    public override void afterInsert() {
    }

    public override void afterUpdate() {
    }

    public override void afterDelete() {
    }

    public override void afterUndelete() {
    }
}