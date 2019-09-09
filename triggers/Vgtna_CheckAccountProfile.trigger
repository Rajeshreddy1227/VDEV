trigger Vgtna_CheckAccountProfile on Account_Profile__c (before insert) {
    set<id> ListAccIds = new set<id>();
    map<id,String> mAccReg = new map<id,String>();
    map<string,string> mRegRVP = new map<string,string>();
for(Account_Profile__c ap:Trigger.new)
        {            
            ListAccIds.add(ap.Account__c);
        }
    list<Account_Profile__c> apDupCheck = [select id,Account__c from Account_Profile__c where Account__c in:ListAccIds];
    if(Trigger.isInsert &&apDupCheck.size()>0){
        trigger.new[0].addError('An Account Profile has already been created for this account - a duplicate profile cannot be created.');
    }
    
    for(Account a: [select id,region__c from Account where id in :ListAccIds])
    {
        mAccReg.put(a.Id, '%'+a.region__c+' Mack Vice President%');
        system.debug('mAccReg'+mAccReg);
    }
    for(user u:[select region__c,name,id,userrole.name,userroleId from user where dealer_brand__c = 'Mack' and title like 'Regional Vice President%' and userrole.name like :mAccReg.values()]){
        mRegRVP.put(u.region__c,u.name);
        system.debug('mRegRVP'+mRegRVP);
    }
    for(Account_Profile__c aReg: Trigger.new){
        if(aReg.Region__c != null){
           aReg.RVP__c = mRegRVP.get(aReg.Region__c);
        }
    }
}