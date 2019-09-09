public without sharing class Vgtna_FetchDealerACHUsers {
    @AuraEnabled
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
                if((conRoleMap.get(usr.ContactId).contains('Sales Rep') && acr.Roles.Contains('Sales Rep')) ||  (conRoleMap.get(usr.ContactId).contains('Sales Executive') || conRoleMap.get(usr.ContactId).contains('Sales Manager'))){
                    if(!conRoleMap.get(usr.ContactId).contains('Sales Rep')) {
                    	acrConList.add(acr.ContactId);
                    } else {
                        acrConList.add(usr.ContactId);
                    }
                }
            }
            
            Map<Id, User> srUsers = new Map<Id, User>([SELECT Id, Name, FirstName, LastName, contactId FROM User WHERE contactId IN :acrConList]);
            
            if(srUsers.size() > 0) {
                return srUsers.values();
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static String ReAssignSalesReps(String srId, List<String> asrIds, String cityFilter, String countyFilter, String zipcodeFilter, String AccFilter, String salesRepFilter, Boolean selectAllRecs) {
        User usr = [SELECT Id, Dealer_Code__c, Name, User_Id__c FROM User WHERE Id = :UserInfo.getUserId()];
        User srUsr = [SELECT Id, User_Id__c FROM User WHERE Id = :srId];
        String usrDCode = usr.Dealer_Code__c;
        List<Assigned_Sales_Rep__c> asrList = new List<Assigned_Sales_Rep__c>();
        List<Id> delAsrList = new List<Id>();
        String msg = '';
        if(selectAllRecs == false && asrIds.size() > 0) {
            Map<Id, Assigned_Sales_Rep__c> asrMap = new Map<Id, Assigned_Sales_Rep__c>([SELECT Id, Account__r.Party_ID__c FROM Assigned_Sales_Rep__c WHERE Id IN :asrIds]);
            for(String asrid : asrIds) {
                Assigned_Sales_Rep__c asr = new Assigned_Sales_Rep__c();
                asr.Id = asrid;
                asr.External_ID__c = asrMap.get(asrid).Account__r.Party_ID__c+ '_'+srUsr.User_Id__c+'_'+usr.Dealer_Code__c;
                asr.Sales_Rep__c = srId;
                asrList.add(asr);
            }
        } else if(selectAllRecs == true) {
            String asrQuery = 'SELECT Id, Name, Dealer_Code__c, CreatedDate, Sales_rep__c, Sales_rep__r.Name, Account__c, Account__r.Name, Account__r.Primary_County__c, Account__r.Party_ID__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingCountry, Account__r.BillingPostalCode FROM Assigned_sales_rep__c WHERE Dealer_Code__c = :usrDCode';
            if(String.isNotBlank(cityFilter)) {
                cityFilter = '%'+cityFilter+'%';
                asrQuery = asrQuery+' AND Account__r.BillingCity LIKE :cityFilter';
            }
            if(String.isNotBlank(countyFilter)) {
                countyFilter = '%'+countyFilter+'%';
                asrQuery = asrQuery+' AND Account__r.Primary_County__c LIKE :countyFilter';
            }
            if(String.isNotBlank(zipcodeFilter)) {
                zipcodeFilter = '%'+zipcodeFilter+'%';
                asrQuery = asrQuery+' AND Account__r.BillingPostalCode LIKE :zipcodeFilter';
            }
            if(String.isNotBlank(AccFilter)) {
                AccFilter = '%'+AccFilter+'%';
                asrQuery = asrQuery+' AND Account__r.Name LIKE :AccFilter';
            }
            if(String.isNotBlank(salesRepFilter) && salesRepFilter != 'All Assigned Accounts' && salesRepFilter != 'All UnAssigned Accounts') {
                asrQuery = asrQuery+' AND Sales_rep__c = :salesRepFilter';
            }
            List<Assigned_sales_rep__c> allASR = new List<Assigned_sales_rep__c>();
            allASR = Database.query(asrQuery);
            for(Assigned_Sales_Rep__c a : allASR) {
                Assigned_Sales_Rep__c asr = new Assigned_Sales_Rep__c();
                asr.External_ID__c = a.Account__r.Party_ID__c+ '_'+srUsr.User_Id__c+'_'+usr.Dealer_Code__c;
                asr.Id = a.Id;
                asr.Sales_Rep__c = srId;
                asrList.add(asr);
            }
        }
        if(asrList.size() > 0) {
            //update asrList;
            Database.SaveResult[] reAssignList = Database.update(asrList, false);
            for(Integer i=0; i < reAssignList.size(); i++) {
                if(!reAssignList[i].isSuccess()) {
                    system.debug('sr fail: '+asrList[i]);
                    for(Database.Error err : reAssignList[i].getErrors()) {
                        if(err.getMessage().contains('duplicate value found: External_ID__c')) {
                            delAsrList.add(asrList[i].Id);
                        }
                    }
                } else {
                    system.debug('sr success: '+reAssignList.get(i).Id+'----'+asrList[i]);
                }
            }
            system.debug('delAsrList: '+delAsrList);
            if(delAsrList.size() > 0) {
                delete [SELECT Id FROM Assigned_Sales_Rep__c WHERE Id IN : delAsrList];
            }
            msg = 'SUCCESS';
        }
        return msg;
    }
    
    @AuraEnabled
    public static String insertASR(String srId, List<String> acctList) {
        User usr = [SELECT Id, Dealer_Code__c, Name, User_Id__c FROM User WHERE Id = :UserInfo.getUserId()];
        Map<Id, String> aIdPartyIdMap = new Map<Id, String>();
        for(Account a : [SELECT Id, Party_Id__c FROM Account WHERE Id IN :acctList]) {
            aIdPartyIdMap.put(a.Id, a.Party_ID__c);
        }
        system.debug('acctList: '+acctList);
        List<Assigned_Sales_Rep__c> asrList = new List<Assigned_Sales_Rep__c>();
        for(String s : acctList) {
            Assigned_Sales_Rep__c asr = new Assigned_Sales_Rep__c();
            asr.External_ID__c = aIdPartyIdMap.get(Id.valueOf(s))+ '_'+usr.User_Id__c+'_'+usr.Dealer_Code__c;
            asr.Account__c = s;
            asr.ownerId = srId;
            asr.Dealer_Code__c = usr.Dealer_Code__c;
            asr.Sales_Rep__c = srId;
            asrList.add(asr);
        }
        system.debug('asrList: '+asrList);
        if(!asrList.isEmpty()) {
            Database.upsert(asrList, Assigned_Sales_Rep__c.Fields.External_ID__c, false);
            //insert asrList;
        }
        return 'SUCCESS';
    }
    
    @AuraEnabled
    public static String insertAllASR(String srId, String cityFilter, String salesRepFilter, String countyFilter, String zipCodeFilter, String accFilter, List<String> allUnassignAcctIds, List<String> allTerrAccIds) {
        User usr = [SELECT Id, Dealer_Code__c, Name, User_Id__c FROM User WHERE Id = :UserInfo.getUserId()];
        User srUsr = [SELECT Id, User_Id__c FROM User WHERE Id = :srId];
        String usrDCode = usr.Dealer_Code__c;
        Map<String, String> aIdPartyIdMap = new Map<String, String>();
        List<Assigned_Sales_Rep__c> asrList = new List<Assigned_Sales_Rep__c>();
        String acctQuery = 'SELECT Id, Name, Dealer_Code__c, Partner_Account__c, CreatedDate, Party_ID__c, BillingStreet, Primary_County__c, BillingCity, BillingState, BillingCountry, BillingPostalCode FROM Account WHERE Party_Id__c != null';
        if(salesRepFilter == 'All Assigned Accounts') {
            acctQuery = acctQuery+' AND Id IN :allTerrAccIds';
        }
        if(salesRepFilter == 'All UnAssigned Accounts') {
            acctQuery = acctQuery+' AND Id IN :allUnassignAcctIds';
        }
        if(String.isNotBlank(cityFilter)) {
            cityFilter = '%'+cityFilter+'%';
            acctQuery = acctQuery+' AND BillingCity LIKE :cityFilter';
        }
        if(String.isNotBlank(countyFilter)) {
            countyFilter = '%'+countyFilter+'%';
            acctQuery = acctQuery+' AND Primary_County__c LIKE :countyFilter';
        }
        if(String.isNotBlank(zipCodeFilter)) {
            zipCodeFilter = '%'+zipCodeFilter+'%';
            acctQuery = acctQuery+' AND BillingPostalCode LIKE :zipCodeFilter';
        }
        if(String.isNotBlank(accFilter)) {
            accFilter = '%'+accFilter+'%';
            acctQuery = acctQuery+' AND Name LIKE :accFilter';
        }
        List<Account> allAccList = Database.query(acctQuery);
        for(Account a : allAccList) {
            aIdPartyIdMap.put(a.Id, a.Party_Id__c);
        }
        system.debug('usr dealer code: '+usr.Dealer_Code__c);
        //Query all ASR'S
        String asrQuery = 'SELECT Id, Name, Dealer_Code__c, CreatedDate, Sales_rep__c, Sales_rep__r.Name, Account__c, Account__r.Name, Account__r.Primary_County__c, Account__r.Party_ID__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingCountry, Account__r.BillingPostalCode FROM Assigned_sales_rep__c WHERE Dealer_Code__c = :usrDCode';
            if(String.isNotBlank(cityFilter)) {
                cityFilter = '%'+cityFilter+'%';
                asrQuery = asrQuery+' AND Account__r.BillingCity LIKE :cityFilter';
            }
            if(String.isNotBlank(countyFilter)) {
                countyFilter = '%'+countyFilter+'%';
                asrQuery = asrQuery+' AND Account__r.Primary_County__c LIKE :countyFilter';
            }
            if(String.isNotBlank(zipcodeFilter)) {
                zipcodeFilter = '%'+zipcodeFilter+'%';
                asrQuery = asrQuery+' AND Account__r.BillingPostalCode LIKE :zipcodeFilter';
            }
            if(String.isNotBlank(accFilter)) {
                accFilter = '%'+AccFilter+'%';
                asrQuery = asrQuery+' AND Account__r.Name LIKE :accFilter';
            }
        List<Assigned_Sales_Rep__c> allAsrList = Database.query(asrQuery);
        for(Assigned_Sales_Rep__c asr : allAsrList) {
                aIdPartyIdMap.put(asr.Account__c, asr.Account__r.Party_Id__c);
        }
       /* if(salesRepFilter == 'All Assigned Accounts') {
            for(Account a : [SELECT Id, Name, Party_Id__c FROM Account WHERE Id IN :allTerrAccIds]) {
                aIdPartyIdMap.put(a.Id, a.Party_Id__c);
            }    
        } else if(salesRepFilter == 'All UnAssigned Accounts') {
            for(Account a : [SELECT Id, Name, Party_Id__c FROM Account WHERE Id IN :allUnassignAcctIds]) {
                aIdPartyIdMap.put(a.Id, a.Party_Id__c);
            }    
        } else if(String.isNotBlank(salesRepFilter) && salesRepFilter.startsWith('005')){
            for(Assigned_Sales_Rep__c asr : [SELECT Id, Name, Account__c, Account__r.Party_Id__c FROM Assigned_Sales_Rep__c WHERE Sales_Rep__c = :salesRepFilter AND Dealer_Code__c = :usr.Dealer_Code__c]) {
                aIdPartyIdMap.put(asr.Account__c, asr.Account__r.Party_Id__c);
            }       
        }*/
        
        for(String accId : aIdPartyIdMap.keyset()) {
            Assigned_Sales_Rep__c asr = new Assigned_Sales_Rep__c();
            asr.External_ID__c = aIdPartyIdMap.get(accId)+ '_'+srUsr.User_Id__c+'_'+usr.Dealer_Code__c;
            asr.Account__c = accId;
            asr.ownerId = srId;
            asr.Dealer_Code__c = usr.Dealer_Code__c;
            asr.Sales_Rep__c = srId;
            asrList.add(asr);
        }
        
        if(!asrList.isEmpty()) {
            Database.upsert(asrList, Assigned_Sales_Rep__c.Fields.External_ID__c, false);
            //insert asrList;
        }
        return 'SUCCESS';
    }
}