public without sharing class Vgtna_GetACHUsers {
    public static List<User> getACHUsers() {
    User usr = [SELECT Id, Dealer_Code__c, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        if(String.isNotBlank(usr.Dealer_Code__c)) {
            List<Account> dealAcc = [SELECT Id, Name, Dealer_Code__c FROM Account WHERE Dealer_Code__c = :usr.Dealer_Code__c LIMIT 1];
            List<String> acrConList = new List<String>();
            List<AccountContactRelation> acrList = [SELECT Id, ContactId, Roles FROM AccountContactRelation WHERE AccountId = :dealAcc[0].Id];
            Map<String, String> conRoleMap = new Map<String, String>();
            for(AccountContactRelation acr : acrList) {
                conRoleMap.put(acr.ContactId, acr.Roles);
            }
            for(AccountContactRelation acr : acrList) {
               // if((conRoleMap.get(usr.ContactId).contains('Sales Rep') && acr.Roles.Contains('Sales Rep')) ||  (conRoleMap.get(usr.ContactId).contains('Sales Executive') || conRoleMap.get(usr.ContactId).contains('Sales Manager'))){
                    acrConList.add(acr.ContactId);
               // }
            }
            
            Map<Id, User> srUsers = new Map<Id, User>([SELECT Id, Name, FirstName, LastName, contactId FROM User WHERE contactId IN :acrConList]);
            
            if(srUsers.size() > 0) {
                return srUsers.values();
            }
        }
        return null;
    }
}