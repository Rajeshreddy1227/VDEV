/**********************************************************************
 Name:  Vgtna_OppRecordTypeSelectorController
 Copyright © 2018  Salesforce
 ======================================================
======================================================
Purpose: Apex controller for Lightning component Vgtna_Ltng_CreateOpportunity.cmp to pool in recordtype info. according to Brand in User                                                          
-------                                                            
======================================================
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL            Description
   1.0    Matt        11/01/2018      INITIAL DEVELOPMENT          DE51/52 
***********************************************************************/

public with sharing class Vgtna_OppRecordTypeSelectorController {

    @AuraEnabled 
    public static User fetchUser(){
     // query current user brand information 
     /* 
      String s = [select Dealer_Brand__c 
                 FROM User Where id =: userInfo.getUserId() limit 1].Dealer_Brand__c;
     */
      User u = [select Dealer_Brand__c,Dual_Branded__c,IsPortalEnabled  
                 FROM User Where id =: userInfo.getUserId() limit 1];
      return u;
    }

        @AuraEnabled 
    public static Account getAccount(String accountIdString){
    //  Id i = Id.valueOf(accountIdString);
      Account acc = [select Id,Name FROM Account WHERE Id=:accountIdString limit 1];
      system.debug('in getAccount, id is ' + acc);
      return acc;
    }
    
    @AuraEnabled 
    public static List<RecordType> getListOfRecordType(User user){
        system.debug('in get list of Record types, with brand' + user.Dealer_Brand__c); 
          
        List<SelectOption> recordTypes = new List<SelectOption>();
        Map<SelectOption, String> rtMaps = new Map<SelectOption, String>();
        List<RecordType> rtNames = new List<RecordType>(); 
        RecordTypeInfo inf;
        RecordType otherRT;
        // Save off Other record ID to be used later.
            for(RecordTypeInfo info: Opportunity.SObjectType.getDescribe().getRecordTypeInfos()) {
                if(  info.getName() == System.Label.Vgtna_Other_OEM) {
                    //otherRT = info.getRecordTypeId();
                    inf  = info;
                    otherRT = new RecordType(Id = info.getRecordTypeId(),Name = info.getName());
                }               
            }
        	if(user.IsPortalEnabled == true)
            {
                for(RecordTypeInfo info: Opportunity.SObjectType.getDescribe().getRecordTypeInfos()) {
                    system.debug('in getListOfRecordType, name: ' + info.getName() + ' available:'+ info.isAvailable()); 
                    system.debug('in getListOfRecordType, name: ' + info.getName() + ' RT:'+ info.getRecordTypeId()); 
    
                 //  Removing 'isAvailable' to satisfy requirements if(info.isAvailable() && info.getName()!= System.Label.Vgtna_Master_RT && (user.Dual_Branded__c == true ||info.getName() == user.Dealer_Brand__c || info.getName() == 'Other')) {
                  //  if( info.getName()!= System.Label.Vgtna_Master_RT && (user.Dual_Branded__c == true ||info.getName() == user.Dealer_Brand__c || info.getName() == 'Other')) {
                    if( info.getName() == user.Dealer_Brand__c&& user.Dealer_Brand__c==System.Label.Vgtna_Volvo_OEM) {
                        recordTypes.add(new SelectOption(info.getRecordTypeId(), info.getName()));
                       // rtNames.add(new RecordType(Id = info.getRecordTypeId(),Name = info.getName()));
                        rtNames.add(new RecordType(Id = info.getRecordTypeId(),Name = info.getName()));
                        //rtNames.add(new RecordType(Id = otherRT,Name = System.Label.Vgtna_Other_OEM));
                        rtNames.add(otherRT);
                        
                    }
                    
                    else if( info.getName() == user.Dealer_Brand__c&& user.Dealer_Brand__c==System.Label.Vgtna_Mack_OEM) 
                    {
                        recordTypes.add(new SelectOption(info.getRecordTypeId(), info.getName()));
                        rtNames.add(new RecordType(Id = info.getRecordTypeId(),Name = info.getName()));
                        rtNames.add(otherRT);
    
                    }
                    
                    /**if(info.isAvailable() && info.getName()== 'Other')
                    {
                        rtNames.add(otherRT);
                    }**/
                    /*
                    // Adding Other first, appears last in the list
                 if( info.getName()!= System.Label.Vgtna_Master_RT && info.getName() == 'Other' )
                 {
                     recordTypes.add(new SelectOption(info.getRecordTypeId(), System.Label.Vgtna_Other_OEM));
                     rtNames.add(new RecordType(Id = info.getRecordTypeId(),Name = info.getName()));
                 } */
                     
            }
    }
        
        if(user.IsPortalEnabled == false)
        {
            for(RecordTypeInfo info: Opportunity.SObjectType.getDescribe().getRecordTypeInfos()) {
                if(info.isAvailable() && info.getName()!= System.Label.Vgtna_Master_RT ) {
                    recordTypes.add(new SelectOption(info.getRecordTypeId(), info.getName()));
                    rtNames.add(new RecordType(Id = info.getRecordTypeId(),Name = info.getName()));
                   
            	}
        	}
        }

        // Include these next 3 lines to output the results during development and debugging
        for( SelectOption selopt: recordTypes ) {
            System.debug( selopt.getLabel() + ',' + selopt.getValue() );
        }
         List<SelectOption> recordTypesDisplayed = new List<SelectOption>();
                 // if recordTypes
        return rtNames;   
       
    }
    
    @AuraEnabled
    public static Id getOpportunityRecordType() {
       Id ClientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Opportunity').getRecordTypeId();
       return ClientRecordTypeId;
    } 
    
    @AuraEnabled
    public static boolean isCommunity(){
        Id siteId = Site.getSiteId(); // take a look at the apex class Site, you may find more useful method concerning site/community
        if (siteId != null) {
            return true;
        }
        return false;
    }    
    
}