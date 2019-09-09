/**********************************************************************
Name:  Vgtna_Test_CustomLoginController()
Copyright © 2018  Salesforce
======================================================
======================================================
Purpose: Apex controller for Lightning component Vgtna_Ltng_DynamicBranding.cmp to pool in user info.                                                           
-------                                                            
======================================================
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL            Description
   1.0    Subho        10/01/2018      INITIAL DEVELOPMENT          US251 
***********************************************************************/

public without sharing class Vgtna_CustomLoginController {
@AuraEnabled 
    public static user fetchUser(){
     // query current user information  
      User oUser = [select id,Name,Dealer_Brand__c,Dual_Branded__c,TimeZoneSidKey,Username,Alias,Country,Email,FirstName,LastName,IsActive,IsPortalEnabled
                 FROM User Where id =: userInfo.getUserId()];
        return oUser;

    }

@AuraEnabled 
    public static List<AccountContactRelation> fetchACR(){
        
        User oUser = [select id,Name,Dealer_Code__c,UserRole.Name,Dealer_Brand__c,Dual_Branded__c,TimeZoneSidKey,Username,Alias,Country,Email,FirstName,LastName,IsActive,IsPortalEnabled 
                 FROM User Where id =: userInfo.getUserId() limit 1];
        String brand = oUser.Dealer_Brand__c;
        system.debug('brand--->'+brand);
        List<AccountContactRelation> acr = new List<AccountContactRelation>();
        List<AccountContactRelation> match_acr = new List<AccountContactRelation>();
        List<AccountContactRelation> others_acr = new List<AccountContactRelation>();
        List<AccountContactRelation> final_acr = new List<AccountContactRelation>();
        
     // query current ACR information  
       
        acr = [select Account.Dealer_Code__c, Dealer_Brand__c, IsDirect, ContactId, Id, IsActive, Roles From AccountContactRelation 
                                    Where contactid in (select contactid from user where id  =: userInfo.getUserId())
                                    And Account.RecordType.Name='Dealer' AND Dealer_Brand__c =:brand Order By Account.Dealer_Code__c asc NULLS LAST];
        system.debug('acr--->'+acr);
        system.debug('acr size--->'+acr.size());
       /** Old Logic starts
        if(acr.size()> 0)
        {
            oUser.Dealer_Code__c = acr[0].Account.Dealer_Code__c;
            
        }
        else
        {
            oUser.Dealer_Code__c = null;
        }

                                Old Logic ends **/
        
        if(acr.size()> 0)
        {
            // There are some matching ACRs. Check if existing dealer code is matching brand and present on list.
            
            String dealerCodes='';
            string brandfreeDealerCodes = '';
            for(AccountContactRelation a: acr)
            {
                if(a.Account.Dealer_Code__c == oUser.Dealer_Code__c)
                {
                    
                    match_acr.add(a);
                }
                else
                {
                    others_acr.add(a);
                }
            }
            
            // If match is found that needs to be at the top of the list else return original list.
            
            if(match_acr.size() > 0)
            {
                final_acr.addALL(match_acr);
                final_acr.addALL(others_acr);
            }
            else
            {
                // no match found. Set top value as user dealer code and add the rest to the final list to return that list.
                oUser.Dealer_Code__c = acr[0].Account.Dealer_Code__c;
                
                final_acr.addALL(others_acr);
            }
            
           
           if(oUser.UserRole.Name.contains('Executive')) {
                
                for(AccountContactRelation a: acr)
                {
                    dealerCodes += a.Account.Dealer_Code__c+',';
                }
                
                oUser.Executive_group__c = dealerCodes;
            } else {
                oUser.Executive_group__c = '';
            }
            //This code is to get all the dealer codes of the logged in user irrespective of the brand. used for reporting purposes--06182019
            if(oUser.UserRole.Name.contains('Executive') || oUser.UserRole.Name.contains('Partner Manager')) {
                for(AccountContactRelation a: [select Account.Dealer_Code__c, Dealer_Brand__c, IsDirect, ContactId, Id, IsActive, Roles From AccountContactRelation 
                                    Where contactid in (select contactid from user where id  =: userInfo.getUserId())
                                    And Account.RecordType.Name='Dealer'  Order By Account.Dealer_Code__c asc NULLS LAST])
                {
                    brandfreeDealerCodes += a.Account.Dealer_Code__c+',';
                }
                oUser.Mgmt_Dealer_Codes__c = brandfreeDealerCodes;
            }
            else{
                oUser.Mgmt_Dealer_Codes__c = '';
            }
            
            //
        }
        else
        {
            oUser.Dealer_Code__c = null;
        }
        try
            {
                update oUser;
            }
            catch(Exception e)
            {
                system.debug('Error updating user dealer code:'+e.getMessage()); 
            }
        return final_acr;

    }
    
    
    
@AuraEnabled 
    public static string updateUserBrand(String userid, String brand){
     // query  user information  
    
        try
        {
            User user = [select id, Dealer_Brand__c from User where id=:userid limit 1];
            if(user != null)
            {
                user.Dealer_Brand__c = brand;
                update user;
                
            }
        }
        catch(Exception e)
        {
            return 'Error updating user brand';
        }
        
               return 'SUCCESS';
    }
    
                @AuraEnabled 
    public static void updateUserDealerCode(String dealerCode)
    {
        try
        {
            User user = [select id, Dealer_Code__c from User where id=: userInfo.getUserId() limit 1];
            if(user != null)
            {
                user.Dealer_Code__c = dealerCode;
                update user;
                
            }
        }
        catch(Exception e)
        {
           system.debug('Error updating user dealer code:'+e.getMessage());
        }
    }
}