public class Vgtna_LeadRecordTypeSelectorController 
{

    @AuraEnabled 
    public static user fetchUser(){
     // query current user information  
      User oUser = [select id,Name,Dealer_Brand__c,Dual_Branded__c,Dealer_Code__c,TimeZoneSidKey,Username,Alias,Country,Email,FirstName,LastName,IsActive,IsPortalEnabled 
                 FROM User Where id =: userInfo.getUserId()];
        return oUser;

    }
    
    @AuraEnabled
    public static List<RecordType> getListOfRecordType(){
        
        User oUser = [select id,Name,Dealer_Brand__c,Dual_Branded__c,Dealer_Code__c,TimeZoneSidKey,Username,Alias,Country,Email,FirstName,LastName,IsActive,IsPortalEnabled 
                 FROM User Where id =: userInfo.getUserId() limit 1];
        Boolean isCommunityUser = oUser.IsPortalEnabled;
        String dealerBrand = oUser.Dealer_Brand__c;
        
        List<SelectOption> recordTypes = new List<SelectOption>();
        List<RecordType> rtNames = new List<RecordType>(); 
        RecordTypeInfo inf;
         RecordType otherRT;
        // Save off Other record ID to be used later.
            for(RecordTypeInfo info: Lead.SObjectType.getDescribe().getRecordTypeInfos()) {
                if(  info.getName() == System.Label.Vgtna_Other_OEM) {
                    //otherRT = info.getRecordTypeId();
                    inf  = info;
                    otherRT = new RecordType(Id = info.getRecordTypeId(),Name = info.getName());
                }               
            }
        if(isCommunityUser == true && (dealerBrand != null || dealerBrand != ''))
        {
             for(RecordTypeInfo info: Lead.SObjectType.getDescribe().getRecordTypeInfos()) {
                    if(info.isAvailable() && info.getName()== dealerBrand) {
                        recordTypes.add(new SelectOption(info.getRecordTypeId(), info.getName()));
                        rtNames.add(new RecordType(Id = info.getRecordTypeId(),Name = info.getName()));
                       
                    }
        		}
             rtNames.add(otherRT);
            
            /**if(dealerBrand == 'Volvo')
             {
                 for(RecordTypeInfo info: Lead.SObjectType.getDescribe().getRecordTypeInfos()) {
                    if(info.isAvailable() && info.getName()!= System.Label.Vgtna_Master_RT && info.getName()!='Mack') {
                        recordTypes.add(new SelectOption(info.getRecordTypeId(), info.getName()));
                        rtNames.add(new RecordType(Id = info.getRecordTypeId(),Name = info.getName()));
                    }
        		}
             }
            if(dealerBrand == 'Mack')
             {
                 for(RecordTypeInfo info: Lead.SObjectType.getDescribe().getRecordTypeInfos()) {
                    if(info.isAvailable() && info.getName()!= System.Label.Vgtna_Master_RT && info.getName()!='Volvo') {
                        recordTypes.add(new SelectOption(info.getRecordTypeId(), info.getName()));
                        rtNames.add(new RecordType(Id = info.getRecordTypeId(),Name = info.getName()));
                    }
        		}
             }**/
            
            
            
        }
        else
        {
            for(RecordTypeInfo info: Lead.SObjectType.getDescribe().getRecordTypeInfos()) {
                if(info.isAvailable() && info.getName()!= System.Label.Vgtna_Master_RT ) {
                    recordTypes.add(new SelectOption(info.getRecordTypeId(), info.getName()));
                    rtNames.add(new RecordType(Id = info.getRecordTypeId(),Name = info.getName()));
                   
            	}
        	}
            // rtNames.add(otherRT);
        }
            

        // Include these next 3 lines to output the results during development and debugging
        for( SelectOption selopt: recordTypes ) {
            System.debug( selopt.getLabel() + ',' + selopt.getValue() );
        }
        return rtNames;   
       
    }
    
}