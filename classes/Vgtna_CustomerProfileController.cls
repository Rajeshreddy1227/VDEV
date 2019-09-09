public with sharing class Vgtna_CustomerProfileController {

    @AuraEnabled 
    public static user fetchUser(){
     // query current user information  
      User oUser = [select id,Name,Dealer_Brand__c,Dual_Branded__c,Dealer_Code__c,TimeZoneSidKey,Username,Alias,Country,Email,FirstName,LastName,IsActive,IsPortalEnabled 
                 FROM User Where id =: userInfo.getUserId()];
        return oUser;

    }
    
    @AuraEnabled 
    public static String getCustomerProfile(Id accountId, String dealerCode){
        Customer_Profile__c customerProfile = new Customer_Profile__c();
        
        try
        {
            customerProfile = [Select id 
                               from Customer_Profile__c
                               where Customer_Account__c = :accountId
                               and Dealer_Account__r.Dealer_Code__c =:dealerCode Limit 1];
            return customerProfile.Id;
        }
        catch(Exception e)
        {
            // check if logged in user can create a customer profile
            	if (Schema.sObjectType.Customer_Profile__c.fields.Customer_Account__c.isCreateable())
                {
                   Account dealerAccount = new Account();
                   try
                   {
                       dealerAccount =[Select id
                                       from Account
                                       where Dealer_Code__c =:dealerCode limit 1];
                       return dealerAccount.Id;
                   }
                    catch(Exception ex)
                    {
                        return 'Insufficient privilege';
                    }
                }
                else
                {
                    return 'Insufficient privilege';
                }
            
        }
        
        
    }
  /**  
    @AuraEnabled 
    public static String getUserType(){
    //  Id i = Id.valueOf(accountIdString);
        String userType = [select UserType  
              FROM User Where Id =: UserInfo.getUserId() limit 1].UserType;
        System.debug('in GetCustomerProfileId, with userType:' + userType);
      return userType;
    }
    
    **/
/**
	@AuraEnabled
   // public static List<Customer_Profile__c> getCustomerProfileId(Id recordId) {
    public static Map<String, Id> getCustomerProfileId(Id accountId) {
        System.debug('in GetCustomerProfileId, with accntid:' + accountId);
  //[Select My_Position__c From User Where Id = :UserInfo.getUserId()][0].My_Position__c;
        Map<String, Id> results = new Map<String,Id>();
       
        Id customerProfileId;
        String sDealerCode = [select Primary_Dealer_Code__c  
              FROM User Where id =: UserInfo.getUserId() limit 1].Primary_Dealer_Code__c; //Dealer_Code__c;
        System.debug('in GetCustomerProfileId, with dealerCode:' + sDealerCode);
        String userType = Vgtna_CustomerProfileController.getUserType();
        if ( userType == 'PowerPartner')
            customerProfileId = [SELECT Customer_Account__c,Id FROM Customer_Profile__c 
                                WHERE Customer_Account__c = :accountId  AND Dealer_Account__r.Dealer_Code__c  = :sDealerCode LIMIT 1].Id; 
        else
            customerProfileId = [SELECT Customer_Account__c,Id FROM Customer_Profile__c 
                                WHERE Customer_Account__c = :accountId   LIMIT 1].Id; 
   **/         
        //            FROM User Where id =: UserInfo.getUserId() limit 1].Dealer_Code__c;
        /*  String sDealerCode = [Select Dealer_Code__c
                              From User
                              Where Id = :userInfo.getUserId() Limit 1];
        */
       // System.debug('in custom prof controller, cust Prof Id = '+ customerProfileId);
        //String recordIdstr = '0013B00000V5NK7QAN';
        //Id i = Id.valueOf(recordIdstr);

/*
        sDealerCode = '2701K';
        // List<Customer_Profile__c> lCustomerProfile 
        List<Customer_Profile__c> lCustomerProfile = [Select Application__c, Customer_Account__c, Daycab__c, Dealer_Account__c, FE_Current__c, FE_Goal__c, Id, 
               Key_Account__c, Miles_Driven__c, Name, OwnerId, Primary_Make__c, RSL_Cruise__c, RSL_Pedal__c, Sales_Target_Account__c, 
               Secondary_Make__c, Sleeper__c, Trade_Cycle__c, Trades__c, Trailer_Types__c, Warranty_Coverage__c 
               From Customer_Profile__c ];
        */      
                                                     
        /*
         *  Where Customer_Account__c = :i
               And Dealer_Account__r.Dealer_Code__c = :sDealerCode
*/
    //    System.debug('in custom prof controller, customer Profiles  = ' + lCustomerProfile);
        
       // return lCustomerProfile;
 /**     results.put(userType, customerProfileId);
        System.debug('my map result' + results);
        return results ;
    }
**/
}