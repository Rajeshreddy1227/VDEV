public with sharing class  VGTNA_rerouteAccountController{
 @AuraEnabled
    public static Account findAccount(Id accountid){        
     Account sur = [SELECT Party_Id__c,Id,description,SurvivingPartyId__c,name FROM Account WHERE id=:accountid];
      string survId = sur.SurvivingPartyId__c;
        if(survId !=null){
        	system.debug('surviving id'+sur);
        	return [SELECT Party_Id__c,Id,description,SurvivingPartyId__c,name FROM Account WHERE Party_Id__c=:survId];       
        }
        else{
            Account a = null;
             return a;
        }           
    }
}