public class Vgtna_TestBuilder {

    public class AccountBuilder {
        private Account record { get; set; }

        public AccountBuilder() {
            record = new Account();
            record.OwnerId=[Select Id From User Where Profile.Name=:vgtna_Constants.INTEGRATION_USER_PROFILE And isActive=true and UserRoleId!=null Limit 1].Id;            
        }

        public AccountBuilder setBillingCountry(String billingCountry) {
            record.BillingCountry = billingCountry;
            return this;
        }
        
        public AccountBuilder setBillingCountryCode(String billingCountryCode) {
            record.BillingCountryCode = billingCountryCode;
            return this;
        }
        public AccountBuilder setBillingStreet(String billingStreet) {
            record.BillingStreet = billingStreet;
            return this;
        }
        public AccountBuilder setBillingPostalCode(String billingPostalCode) {
            record.billingPostalCode = billingPostalCode;
            return this;
        }
        
        public AccountBuilder setBillingCity(String billingCity) {
            record.billingCity = billingCity;
            return this;
        }

        public AccountBuilder setBillingState(String BillingState) {
            record.BillingState = BillingState;
            return this;
        }
        
        public AccountBuilder setBillingStateCode(String BillingStateCode) {
            record.BillingStateCode = BillingStateCode;
            return this;
        }

        public AccountBuilder setName(String name) {
            record.Name = name;
            return this;
        }
        
        public AccountBuilder setDealerCode(String name) {
            record.Dealer_Code__c = name;
            return this;
        }

        public AccountBuilder setIsPartner(boolean name) {
            record.isPartner = name;
            return this;
        }
        
        public AccountBuilder setPartyId() {
            record.Party_Id__c = generateRandomString(10);
            return this;
        }
        
        public AccountBuilder setSurvivingPartyId(String name) {
            record.SurvivingPartyId__c = name;
            return this;
        }
        
        public AccountBuilder setSurvivingPartyId() {
            record.SurvivingPartyId__c = null;
            return this;
        }

        public AccountBuilder setPartyIdConstant(String name) {
                    record.Party_Id__c = name;
                    return this;
                }        
        public AccountBuilder setrecordType(String name){
            record.RecordTypeId = getAccountRecordTypeId(name);
            return this;
        }

		public AccountBuilder setParent(Account acc) {
            record.ParentId = acc.Id;
            return this;
        }
        
        public AccountBuilder setBrand(String brand) {
            record.Brand__c = brand;
            return this;
        }
        
        public Account build() {
            return record.clone();
        }

        public Account buildAndSave() {
            Account newRecord = record.clone();
            insert newRecord;
            return newRecord;
        }
    }

    public class ContactBuilder {
        private Contact record { get; set; }

        public ContactBuilder() {
            record = new Contact();
        }

        public ContactBuilder setAccount(Account acc) {
            record.AccountId = acc.Id;
            return this;
        }

        public ContactBuilder setEmail(String email) {
            record.Email = email;
            return this;
        }

        public ContactBuilder setFirstName(String firstName) {
            record.FirstName = firstName;
            return this;
        }

        public ContactBuilder setLastName(String lastName) {
            record.LastName = lastName;
            return this;
        }

        public Contact build() {
            return record.clone();
        }

        public Contact buildAndSave() {
            Contact newRecord = record.clone();
            insert newRecord;
            return newRecord;
        }
    }

 
    public class UserBuilder {
        private User record { get; set; }
        public UserBuilder() {
            record = new User();
            record.userName='test'+generateRandomString(10)+'@vgtna.salesforce.com'; 
            record.Alias = 'Tcode';
            record.CommunityNickname = 'test'+generateRandomString(10);
            record.LocaleSidKey = 'en_US';
            record.TimeZoneSidKey = 'GMT';
            record.LanguageLocaleKey = 'en_US';
            record.EmailEncodingKey = 'UTF-8';            
        }

        public USerBuilder setContact(Contact cnt) {
            record.ContactId = cnt.Id;
            return this;
        }
        
        
        public UserBuilder setLastName (String name){
            record.LastName=name;
            record.FirstName='Test';
            return this;
        }
            
        public UserBuilder setEmail(String name){
            record.Email = name;
            return this;
        }
        
        public UserBuilder setProfileId(String name){
            record.ProfileId = getProfileId(name);
            return this;
        }
        
        public UserBuilder setRoleId(String name){
            record.UserRoleId = getRoleId(name);
            return this;
        }
        
        public UserBuilder setBrand(String name){
            record.Dealer_Brand__c = name;
            return this;
        }
                
        public User build() {
            return record.clone();
        }

        public User buildAndSave() {
            
            User newRecord = record.clone();
            insert newRecord;
            return newRecord;
        }
         
    }        
    

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }       
    
    
/***************************************************************************************************************************** 
    * @param Method Name: getAccountRecordTypeId
    * @param author: Salesforce Services
    * @param Date: 05/11/2016
    * @description : Method that returns Id of a RecordType with the Name
    * @param  : rtName
    * @return : RecordtypeId.Id  
*******************************************************************************************************************************/ 
    public static Id getAccountRecordTypeId(string rtName ) {
        List<RecordType> rtIdList = [Select Id From RecordType Where DeveloperName = :rtName And SobjectType = 'Account' Limit 1];
        return rtIdList[0].Id;
    }    
    
    public static Id getProfileId(string name)
    {
        List<Profile> profileIdList = [Select Id From Profile Where Name = :name Limit 1];
        return profileIdList[0].Id;
    }
    
    public static Id getRoleId(String name)
    {
        List<UserRole> roleIdList = [Select Id From UserRole Where Name=:name Limit 1];
        return roleIdList[0].Id;
    }
}