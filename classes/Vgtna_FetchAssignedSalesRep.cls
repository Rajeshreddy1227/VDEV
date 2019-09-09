public with sharing class Vgtna_FetchAssignedSalesRep {
    @AuraEnabled 
    public static List<wrapASR> getAssignedSalesRep(String recId) {
        try {
            Id loggedUserId = userInfo.getUserId();
            Map<Id, User> uMap = new Map<Id, User>([SELECT Id, Dealer_Code__c, Dealer_Brand__c, ContactId, Primary_Dealer_Code__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()]);
            List<Assigned_Sales_Rep__c> asrList = [SELECT Id, Name, Account__c, Account__r.Name, Dealer_Code__c, Sales_Rep__c, Party_ID__c, Primary_Address__c, OwnerId, Owner.Name FROM Assigned_Sales_Rep__c WHERE Account__c = :recId AND Dealer_Code__c = :uMap.get(loggedUserId).Dealer_Code__c];
            List<wrapASR> wrapASRList = new List<wrapASR>();
            for(Assigned_Sales_Rep__c asr : asrList) {
                wrapASR asrRec = new wrapASR();
                asrRec.ASRName = asr.Name;
                asrRec.ASRLink = '/'+asr.Id;
                asrRec.PartyId = asr.Party_ID__c;
                asrRec.Address = asr.Primary_Address__c;
                asrRec.SalesRepLink = '/'+asr.OwnerId;
                asrRec.SalesRepName = asr.Owner.Name;
                asrRec.accountName = asr.Account__r.Name;
                wrapASRList.add(asrRec);
            }
            return wrapASRList;
        } catch (exception e) {
            System.debug('exception occured at line number: '+e.getLineNumber()+' with error '+e.getMessage());
            return null;
        }
    }
    
    @AuraEnabled 
    public static String deleteASR(String recId) {
        try {    
            if(String.isNotBlank(recId)) {
                List<Assigned_Sales_Rep__c> asr = [SELECT Id FROM Assigned_Sales_Rep__c WHERE Id = :recId];
                if(!asr.isEmpty()) {
                    delete asr;
                    return 'Success';
                }
            }
            return 'Record not found';
        } catch(exception e) {
            return 'Error: Exception '+e.getMessage()+' occured at line number '+e.getLineNumber();
        }
    }
    
    public class wrapASR {
        @AuraEnabled public String ASRName;
        @AuraEnabled public String ASRLink;
        @AuraEnabled public String PartyId;
        @AuraEnabled public String Address;
        @AuraEnabled public String Street;
        @AuraEnabled public String State;
        @AuraEnabled public String City;
        @AuraEnabled public String PostalCode;
        @AuraEnabled public String Country;
        @AuraEnabled public String SalesRepLink;
        @AuraEnabled public String SalesRepName;
        @AuraEnabled public String accountName;
        
        public wrapASR(){
            ASRName = '';
            ASRLink = '';
            PartyId = '';
            Address = '';
            Street = '';
            State = '';
            City = '';
            PostalCode = '';
            Country = '';
            SalesRepLink = '';
            SalesRepName = '';
            accountName = '';
            
        }
    }
}