public without sharing class Vgtna_FetchDealerAccountsNew {
    public static string dealerCode = [SELECT Id, Dealer_Code__c FROM User WHERE Id = :UserInfo.getUserId()].Dealer_Code__c;
    public static User loggedUsr = [SELECT Id, Dealer_Code__c, Dealer_Brand__c, ContactId, Primary_Dealer_Code__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() and Dealer_Code__c != null LIMIT 1];
    public static Boolean restrictRepSelfAssign = [SELECT Id, Restrict_Rep_Self_Assign__c FROM Account WHERE Dealer_Code__c = :dealerCode LIMIT 1].Restrict_Rep_Self_Assign__c;
    @AuraEnabled(cacheable=true)
    public static wrapResponse allAccounts(String citySearch, String countySearch, String zipcodeSearch, String accNameSearch, String salesRepFilter, Boolean onPageLoad,
                                           Boolean onLoad, Integer noOfRec, dateTime asrCreatedDate, dateTime accCreatedDate, List<String> allTerrAccIds,
                                           Integer loadedAsrSize, Integer loadedAccSize, Integer totAsr, Integer totAcc, List<String> unassignAcctList, String lastAsrId, String lastAccId) {
                                               system.debug('allTerrAccIds::'+allTerrAccIds+'--'+accCreatedDate+'--'+asrCreatedDate+'---'+onLoad);
        List<wrapCustAcc> wrapCustAccList = new List<wrapCustAcc>();
        List<wrapCustAcc> wrapCustUnAccList = new List<wrapCustAcc>();
        List<Assigned_sales_rep__c> custAsrList = new List<Assigned_sales_rep__c>();
        Set<Id> acctIdSet = new Set<Id>();
        wrapResponse wr = new wrapResponse();
        wr.restrictSalesRep = restrictRepSelfAssign;
        if(salesRepFilter == 'All Assigned Accounts') {
            system.debug('salesrepfilter: '+salesRepFilter+'onpageload---'+onPageLoad);
            if(onPageLoad == true) {
                List<Territory2> terr = [SELECT Id, Dealer_Code__c FROM Territory2 WHERE Dealer_Code__c = :loggedUsr.Dealer_Code__c];
               
                for(ObjectTerritory2Association ota : [SELECT Id, Territory2Id, ObjectId FROM ObjectTerritory2Association WHERE Territory2Id = :terr[0].Id]) {
                    acctIdSet.add(ota.ObjectId);
                }
                allTerrAccIds = new List<Id>(acctIdSet);
                wr.allTerrAccIds = allTerrAccIds;
                system.debug('allTerrAccIds onload: '+allTerrAccIds+'--size--'+allTerrAccIds.size());
            }
            system.debug('asrCreatedDate: '+asrCreatedDate+'---'+loadedAsrSize);
            if(String.isNotBlank(lastAsrId) || onLoad == true) {
            	custAsrList = getASR(onLoad, loadedAsrSize, totAsr, citySearch, countySearch, zipcodeSearch, accNameSearch, salesRepFilter, asrCreatedDate, 75, lastAsrId);
            }
                SYSTEM.DEBUG('custAsrList:: '+custAsrList.size());   
            
                List<Assigned_Sales_Rep__c> wrapASRRec = new List<Assigned_Sales_Rep__c>();
            List<Account> wrapAccRec = new List<Account>();
                Integer asrSize;
                Integer unassignAccSize;
                Set<String> asrAccIds = new Set<String>();
                Map<Id, Account> accListWrapMap = new Map<Id, Account>();
                //Map<Id, Account> accListWrapMap = getUnAssignedAccounts(onLoad, citySearch, countySearch, zipcodeSearch, unassignAcctList, accCreatedDate);
            SYSTEM.DEBUG('acclistwrapmap: '+accListWrapMap.size());
                if(onLoad == true) {
                    asrSize = custAsrList.size();
                   // wr.totalAccSize = accListWrapMap.size();
                    system.debug('asrSize: '+asrSize);
                    wr.totalAsrSize = asrSize;
                    //wr.unassignAccts = new List<String>(accListWrap.keyset());
                    Integer counter = 0;
                    for(Assigned_Sales_Rep__c asr : custAsrList) {
                        if(counter < 76) {
                            wrapASRRec.add(asr);
                            counter ++;
                        }
                        asrAccIds.add(asr.Account__c);
                        
                    }
                    //accListWrapMap = getUnAssignedAccounts(onLoad, citySearch, countySearch, zipcodeSearch, accNameSearch, allTerrAccIds, accCreatedDate, salesRepFilter);
                    
                    Set<String> allTerrAccIdsSet = new Set<String>(allTerrAccIds);
                    if(allTerrAccIdsSet.removeAll(asrAccIds)) {
                        system.debug('acctIdSet.size(): '+allTerrAccIdsSet.size());
                        unassignAccSize = allTerrAccIdsSet.size();
                        //wr.totalAccSize = unassignAccSize;
                        wr.unassignAccts = new List<String>(allTerrAccIdsSet);
                    } else {
                        unassignAccSize = allTerrAccIdsSet.size();
                        //wr.totalAccSize = unassignAccSize;
                        wr.unassignAccts = new List<String>(allTerrAccIdsSet);
                    } 
                    accListWrapMap = getUnAssignedAccounts(onLoad, citySearch, countySearch, zipcodeSearch, accNameSearch, new List<String>(allTerrAccIdsSet), accCreatedDate, salesRepFilter,lastAccId);
                    system.debug('accListWrapMap size: '+accListWrapMap.size());
                    wr.totalAccSize = accListWrapMap.size();
                    system.debug('accListWrapMap size after: '+accListWrapMap.size());
                    if(counter < 75) {
                        Integer acctsToRetrieve = 75-counter;
                        //Map<Id, Account> accListWrapMap = getUnAssignedAccounts(onLoad, citySearch, countySearch, zipcodeSearch, new List<Id>(acctIdSet), null);
                        system.debug('acclistwrap: '+accListWrapMap.values()+'----'+accListWrapMap.values().size());
                        if(accListWrapMap.values().size() < acctsToRetrieve) {
                            acctsToRetrieve = accListWrapMap.values().size();
                        }
                        List<wrapCustAcc> wrapAccList = new List<wrapCustAcc>();
                        for(integer i = 0; i < acctsToRetrieve; i++) {
                            wrapAccRec.add(accListWrapMap.values()[i]);
                            
                        }
                        //wr.wrapAcc = wrapAccList;
                    }
                } else {
                    system.debug('loadedasrsize, totasr: '+loadedAsrSize+'----'+totAsr);
                    if(loadedAsrSize < totAsr) {
                       // custAsrList = getASR(onLoad, loadedAsrSize, totAsr, citySearch, countySearch, zipcodeSearch, accNameSearch, salesRepFilter, asrCreatedDate, 75, lastAsrId);
                        wrapASRRec.addAll(custAsrList);
                    } //else {
                    if(custAsrList.size() == 0) {
                        accListWrapMap = getUnAssignedAccounts(false, citySearch, countySearch, zipcodeSearch, accNameSearch, unassignAcctList, accCreatedDate, salesRepFilter,lastAccId);
                        //Map<Id, Account> accListWrapInfLoad = getUnAssignedAccounts(onLoad, citySearch, countySearch, zipcodeSearch, new List<String>(unassignAcctList), accCreatedDate);
                        wrapAccRec.addAll(accListWrapMap.values());
                        system.debug('wrapAccRec: : '+wrapAccRec.size()+'---'+wrapAccRec);
                    }
                    //}
                }
                system.debug('custAsrList: '+custAsrList);
                if(custAsrList.size() > 0) {
                    for(Assigned_sales_rep__c asr : wrapASRRec) {
                        wrapCustAcc asrRec = new wrapCustAcc();
                        asrRec.accLink = '/'+asr.Account__c;
                        asrRec.accId = asr.Account__c;
                        asrRec.accountName = asr.Account__r.Name;
                        //asrRec.dealerCode = usr[0].Dealer_Code__c;
                        asrRec.PartyId = asr.Account__r.Party_ID__c;
                        asrRec.street = asr.Account__r.BillingStreet;
                        asrRec.city = asr.Account__r.BillingCity;
                        asrRec.county = asr.Account__r.Primary_County__c;
                        asrRec.state = asr.Account__r.BillingState;
                        asrRec.country = asr.Account__r.BillingCountry;
                        asrRec.postalCode = asr.Account__r.BillingPostalCode;
                        asrRec.assignedReps = asr.Sales_Rep__r.Name;
                        asrRec.asrId = asr.Id;
                        asrRec.asrCreatedDt = asr.createddate;
                        asrRec.uniqfield = asr.Account__c+'-'+asr.Id;
                        wrapCustAccList.add(asrRec);
                        system.debug('wrapCustAccList: '+wrapCustAccList);
                        
                    }
                    if(wrapCustAccList.size() > 0) {
                        wr.wrapASR = wrapCustAccList;
                    }
                } 
            system.debug('wrapaccrec::::'+wrapAccRec.size());
                                          if(wrapAccRec.size() > 0) {
                                              system.debug('wrapaccsize entered: ');
                                              for(Account acc : wrapAccRec) {
                                                  wrapCustAcc accRec = new wrapCustAcc();
                                                  accRec.accLink = '/'+acc.Id;
                                                  accRec.accId = acc.Id;
                                                  accRec.accountName = acc.Name;
                                                  accRec.dealerCode = dealerCode;
                                                  accRec.PartyId = acc.Party_ID__c;
                                                  accRec.street = acc.BillingStreet;
                                                  accRec.city = acc.BillingCity;
                                                  accRec.county = acc.Primary_County__c;
                                                  accRec.state = acc.BillingState;
                                                  accRec.country = acc.BillingCountry;
                                                  accRec.postalCode = acc.BillingPostalCode;
                                                  accRec.accCreatedDt = acc.CreatedDate;
                                                  accRec.uniqfield = acc.Id+'-';
                                                  wrapCustUnAccList.add(accRec);
                                              }
                                              if(wrapCustUnAccList.size() > 0) {
                                                  wr.wrapAcc = wrapCustUnAccList;
                                                  system.debug('wrapaacc: '+wrapCustUnAccList.size()+'--'+wr.wrapAcc);
                                              }
                                          }
                    
                
                
            }
            wr.loggedUserId = userInfo.getUserId();
            List<AccountContactRelation> acr = [SELECT Id, contactId, Account_Dealer_Code__c, Roles FROM AccountContactRelation WHERE ContactId = :loggedUsr.ContactId AND Account_Dealer_Code__c = :loggedUsr.Dealer_Code__c LIMIT 1];
                                               if(acr.size() > 0 && acr[0].Roles.contains('Sales Rep')) {
                                                   system.debug('issalesrep');
                                                   wr.isSalesRep = true;
                                               } else {
                                                   wr.isSalesRep = false;
                                               }                                  
                                               system.debug('wr:::'+wr+'--');
        return wr;
    }
    
    @AuraEnabled
    public static wrapResponse loadUnAssignedAccounts(Boolean onLoad, String citySearch, String countySearch, String zipcodeSearch, String accNameSearch, List<String> accIds, DateTime accCreatedDate, String lastAccId){
        system.debug('onload: '+onLoad+'---'+accCreatedDate);
        Map<Id, Account> accList = getUnAssignedAccounts(onLoad, citySearch, countySearch, zipcodeSearch, accNameSearch, accIds, accCreatedDate, 'All Unassigned Accounts',lastAccId);
        system.debug('acclist: '+accList.size());
        List<Account> loadAccList = new List<Account>();  
        wrapResponse wr = new wrapResponse();        
        List<wrapCustAcc> loadUnAssignedAccWrap = new List<wrapCustAcc>();
        if(onLoad == true) {
            Integer accSize = accList.values().size();
            wr.totalAccSize = accSize;
            Integer counter = 0;
            for(Account acc : accList.values()) {
                if(counter < 76) {
                    loadAccList.add(acc);
                    counter ++;
                }  
            }
        } else {
            loadAccList.addAll(accList.values());
        }     
        if(loadAccList.size() > 0) {
            system.debug('wrapaccsize entered: ');
            for(Account acc : loadAccList) {
                wrapCustAcc accRec = new wrapCustAcc();
                accRec.accLink = '/'+acc.Id;
                accRec.accId = acc.Id;
                accRec.accountName = acc.Name;
                accRec.dealerCode = dealerCode;
                accRec.PartyId = acc.Party_ID__c;
                accRec.street = acc.BillingStreet;
                accRec.city = acc.BillingCity;
                accRec.county = acc.Primary_County__c;
                accRec.state = acc.BillingState;
                accRec.country = acc.BillingCountry;
                accRec.postalCode = acc.BillingPostalCode;
                accRec.accCreatedDt = acc.CreatedDate;
                loadUnAssignedAccWrap.add(accRec);
            }
            if(loadUnAssignedAccWrap.size() > 0) {
                wr.wrapAcc = loadUnAssignedAccWrap;
                system.debug('wrapaacc: '+loadUnAssignedAccWrap.size()+'--'+wr.wrapAcc);
            }
        }
        return wr;
    }
    
    @AuraEnabled
    public static Map<Id, Account> getUnAssignedAccounts(Boolean onLoad, String citySearch, String countySearch, String zipcodeSearch, String accNameSearch, 
                                                List<String> accIds, DateTime accCreatedDate, String salesRepFilter, String lastAccId){
                                                    system.debug('accIds: '+accIds+'----'+accCreatedDate);
        Map<Id, Account> unAssAccRecMap = new Map<Id, Account>();
        List<Account> unAssAccRec = new List<Account>();
        String acctQuery = 'SELECT Id, Name, Dealer_Code__c, Partner_Account__c, CreatedDate, Party_ID__c, BillingStreet, Primary_County__c, BillingCity, BillingState, BillingCountry, BillingPostalCode FROM Account WHERE Id IN :accIds AND Party_Id__c != null';
        if(String.isNotBlank(citySearch)) {
            citySearch = '%'+citySearch+'%';
            acctQuery = acctQuery+' AND BillingCity LIKE :citySearch';
        }
        if(String.isNotBlank(countySearch)) {
            countySearch = '%'+countySearch+'%';
            acctQuery = acctQuery+' AND Primary_County__c LIKE :countySearch';
        }
        if(String.isNotBlank(zipcodeSearch)) {
            zipcodeSearch = '%'+zipcodeSearch+'%';
            acctQuery = acctQuery+' AND BillingPostalCode LIKE :zipcodeSearch';
        }
        if(String.isNotBlank(accNameSearch)) {
            accNameSearch = '%'+accNameSearch+'%';
            acctQuery = acctQuery+' AND Name LIKE :accNameSearch';
        }
          
                                                    if(salesRepFilter == 'All Assigned Accounts' && onLoad == false) {
                                                        if(lastAccId != null) {
                                                            acctQuery = acctQuery+' AND Id IN :accIds AND Id > :lastAccId ORDER BY Id LIMIT 75';
                                                        } else {
                                                            acctQuery = acctQuery+' AND Id IN :accIds ORDER BY Id LIMIT 75';
                                                        }
                                                    } else {
        if(lastAccId != null && onLoad == false) {
            acctQuery = acctQuery+' AND Id IN :accIds AND Id > :lastAccId ORDER BY Id LIMIT 75';
        } else if(onLoad == true){
            acctQuery = acctQuery+' AND Id IN :accIds ORDER BY Id';
        }
                                                    }
        unAssAccRec = Database.query(acctQuery);
        for(Account acc : unAssAccRec) {
            unAssAccRecMap.put(acc.Id, acc);
        }
        return unAssAccRecMap;
        
    }
    
    @AuraEnabled
    public static wrapResponse getSelectedASR(String citySearch, String countySearch, String zipcodeSearch, String accNameSearch,  String salesRepFilter, DateTime asrCreatedDate, Boolean onLoad, String lastAsrId){
        system.debug('onLoad getselectedASR: '+onLoad);
        List<Assigned_Sales_rep__c> asrList = getASR(onLoad, null, null, citySearch, countySearch, zipcodeSearch, accNameSearch, salesRepFilter, asrCreatedDate, 75, lastAsrId);
        List<Assigned_Sales_Rep__c> loadAsrList = new List<Assigned_Sales_Rep__c>();
        wrapResponse wr = new wrapResponse();
        if(onLoad == true) {
            Integer asrSize = asrList.size();
            system.debug('onLoad getselectedASR size: '+asrSize);
            wr.totalAsrSize = asrSize;
            Integer counter = 0;
            for(Assigned_Sales_Rep__c asr : asrList) {
                if(counter < 76) {
                    loadAsrList.add(asr);
                    counter ++;
                }  
            }
        } else {
            loadAsrList.addAll(asrList);
        }
        List<wrapCustAcc> wrapCustAsrList = new List<wrapCustAcc>();
        for(Assigned_Sales_rep__c asr : loadAsrList) {
            wrapCustAcc asrRec = new wrapCustAcc();
            asrRec.accLink = '/'+asr.Account__c;
            asrRec.accId = asr.Account__c;
            asrRec.accountName = asr.Account__r.Name;
            asrRec.dealerCode = dealerCode;
            asrRec.PartyId = asr.Account__r.Party_ID__c;
            asrRec.street = asr.Account__r.BillingStreet;
            asrRec.city = asr.Account__r.BillingCity;
            asrRec.county = asr.Account__r.Primary_County__c;
            asrRec.state = asr.Account__r.BillingState;
            asrRec.country = asr.Account__r.BillingCountry;
            asrRec.postalCode = asr.Account__r.BillingPostalCode;
            asrRec.assignedReps = asr.Sales_Rep__r.Name;
            asrRec.asrId = asr.Id;
            asrRec.asrCreatedDt = asr.createddate;
            wrapCustAsrList.add(asrRec);
        }
        wr.wrapASR = wrapCustAsrList;
        return wr;
    }
    
    @AuraEnabled
    public static List<Assigned_sales_rep__c> getASR(Boolean onLoad, Integer loadedAsrSize, Integer totAsr, String citySearch, String countySearch, String zipcodeSearch, String accNameSearch, String salesRepFilter, DateTime asrCreatedDate, Integer limitRec, String lastAsrId){
        String asrQuery = 'SELECT Id, Name, Dealer_Code__c, CreatedDate, Sales_rep__c, Sales_Rep__r.ContactId, Sales_rep__r.Name, Account__c, Account__r.Name, Account__r.Primary_County__c, Account__r.Party_ID__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingCountry, Account__r.BillingPostalCode FROM Assigned_sales_rep__c WHERE Dealer_Code__c = :dealerCode AND Sales_rep__r.ContactId != NULL';
       /* if(!salesRepFilter.equalsIgnoreCase('All Assigned Accounts')) {
            asrQuery = asrQuery+' AND Sales_rep__c = :salesRepFilter';
        } else {
            asrQuery = asrQuery+' AND Sales_rep__c != null';
        }*/
        if(String.isNotBlank(citySearch)) {
            citySearch = '%'+citySearch+'%';
            asrQuery = asrQuery+' AND Account__r.BillingCity LIKE :citySearch';
        }
        if(String.isNotBlank(countySearch)) {
            countySearch = '%'+countySearch+'%';
            asrQuery = asrQuery+' AND Account__r.Primary_County__c LIKE :countySearch';
        }
        if(String.isNotBlank(zipcodeSearch)) {
            zipcodeSearch = '%'+zipcodeSearch+'%';
            asrQuery = asrQuery+' AND Account__r.BillingPostalCode LIKE :zipcodeSearch';
        }
        if(String.isNotBlank(accNameSearch)) {
            accNameSearch = '%'+accNameSearch+'%';
            asrQuery = asrQuery+' AND Account__r.Name LIKE :accNameSearch';
        }
        if(String.isNotBlank(salesRepFilter) && salesRepFilter != 'All Assigned Accounts' && salesRepFilter != 'All UnAssigned Accounts') {
            asrQuery = asrQuery+' AND Sales_rep__c = :salesRepFilter';
        }
       // if(salesRepFilter == 'All Assigned Accounts') {
       system.debug('onLoad query: '+onLoad);
            if(onLoad == true) {
                asrQuery = asrQuery+' ORDER BY Id';
            } else {
                asrQuery = asrQuery+' AND Id > :lastAsrId ORDER BY Id LIMIT '+limitRec;
            }
       /* }else {
            system.debug('asrCreatedDate: '+asrCreatedDate);
            if(asrCreatedDate == null) {
                asrQuery = asrQuery+' ORDER BY CreatedDate';
            } else {
                asrQuery = asrQuery+' AND CreatedDate > :asrCreatedDate ORDER BY CreatedDate LIMIT '+limitRec;
            } 
        }*/
        System.debug('asrquery:::'+asrQuery);
        List<Assigned_sales_rep__c> asrList = new List<Assigned_sales_rep__c>();
        asrList = Database.query(asrQuery);
        return asrList;
                                                   
   }
    
   /* @AuraEnabled(cacheable=true)
    public static Integer getTotalAccounts(){
        AggregateResult results = [SELECT Count(Id) TotalAccounts  From Account WHERE Party_Id__c != null];
        Integer totalAccounts = (Integer)results.get('TotalAccounts') ; 
        return totalAccounts;
    } */
    
    @AuraEnabled
    public static List<User> getACHUsers() {
        List<User> uList = Vgtna_GetACHUsers.getACHUsers();
        return uList;
       
    }
    
    @AuraEnabled
    public static List<wrapSROption> getFetchDealerSalesReps(String dCode) {
        List<Account> dealAcc = [SELECT Id, Name, Dealer_Code__c FROM Account WHERE Dealer_Code__c = :dCode LIMIT 1];
        List<String> acrConList = new List<String>();
        List<AccountContactRelation> acrList = [SELECT Id, ContactId FROM AccountContactRelation WHERE AccountId = :dealAcc[0].Id];
        for(AccountContactRelation acr : acrList) {
            acrConList.add(acr.ContactId);
        }
        List<wrapSROption> sroList = new List<wrapSROption>();
        Map<Id, User> srUsers = new Map<Id, User>([SELECT Id, Name, FirstName, LastName, contactId FROM User WHERE contactId IN :acrConList]);
        for(User u : srUsers.values()) {
            wrapSROption sro = new wrapSROption();
            sro.SRName = u.FirstName+' '+u.LastName;
            sro.SRUserId = u.Id;
            sroList.add(sro);
        }
        system.debug('srolist: '+sroList);
        return sroList;
    }
    
    /*@AuraEnabled
    public static String insertASR(String srId, List<String> acctList) {
        User u = [SELECT Id, User_Id__c FROM User WHERE Id = :srId];
        Map<Id, String> aIdPartyIdMap = new Map<Id, String>();
        for(Account a : [SELECT Id, Party_Id__c FROM Account WHERE Id IN :acctList]) {
            aIdPartyIdMap.put(a.Id, a.Party_ID__c);
        }
        List<Assigned_Sales_Rep__c> asrList = new List<Assigned_Sales_Rep__c>();
        for(String s : acctList) {
            Assigned_Sales_Rep__c asr = new Assigned_Sales_Rep__c();
            asr.External_ID__c = aIdPartyIdMap.get(Id.valueOf(s))+ '_'+u.User_Id__c+'_'+dealerCode;
            asr.Account__c = s;
            asr.ownerId = srId;
            asr.Dealer_Code__c = dealerCode;
            asr.Sales_Rep__c = srId;
            asrList.add(asr);
        }
        system.debug('asrList: '+asrList);
        if(!asrList.isEmpty()) {
            upsert asrList;
        }
        return 'Success';
    }*/
    @AuraEnabled 
    public static String deleteASR(List<String> asrIds, Boolean selectAllRecs, String citySearch, String countySearch, String zipcodeSearch, String accNameSearch, String salesRepFilter) {
        try {    
            
            system.debug('salesrepfilter--selectallrecs::'+salesRepFilter+'------'+selectAllRecs);
            User u = [SELECT Id, Name, Dealer_Code__c FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
            String asrQuery = 'SELECT Id, Name, Dealer_Code__c, CreatedDate, Sales_rep__c, Sales_Rep__r.ContactId, Sales_rep__r.Name, Account__c, Account__r.Name, Account__r.Primary_County__c, Account__r.Party_ID__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingCountry, Account__r.BillingPostalCode FROM Assigned_sales_rep__c WHERE Dealer_Code__c = :dealerCode AND Sales_rep__r.ContactId != NULL';
            if(String.isNotBlank(citySearch)) {
                citySearch = '%'+citySearch+'%';
                asrQuery = asrQuery+' AND Account__r.BillingCity LIKE :citySearch';
            }
            if(String.isNotBlank(countySearch)) {
                countySearch = '%'+countySearch+'%';
                asrQuery = asrQuery+' AND Account__r.Primary_County__c LIKE :countySearch';
            }
            if(String.isNotBlank(zipcodeSearch)) {
                zipcodeSearch = '%'+zipcodeSearch+'%';
                asrQuery = asrQuery+' AND Account__r.BillingPostalCode LIKE :zipcodeSearch';
            }
            if(String.isNotBlank(accNameSearch)) {
                accNameSearch = '%'+accNameSearch+'%';
                asrQuery = asrQuery+' AND Account__r.Name LIKE :accNameSearch';
            }
            if(String.isNotBlank(salesRepFilter) && salesRepFilter != 'All Assigned Accounts' && salesRepFilter != 'All UnAssigned Accounts') {
                asrQuery = asrQuery+' AND Sales_rep__c = :salesRepFilter';
            }
            List<Assigned_sales_rep__c> asrList = new List<Assigned_sales_rep__c>();
        	asrList = Database.query(asrQuery);
            Boolean otherUserASR = false;
            if(selectAllRecs == false && asrIds.size() > 0) {
                List<Assigned_Sales_Rep__c> asr = [SELECT Id, Sales_Rep__c FROM Assigned_Sales_Rep__c WHERE Id IN :asrIds];
                delete asr;
                return 'SUCCESS';
                 
            } else if(selectAllRecs == true) {
                //List<Assigned_Sales_Rep__c> asr = [SELECT Id, Sales_Rep__c FROM Assigned_Sales_Rep__c WHERE Sales_Rep__c = :salesRepFilter AND Dealer_Code__c = :u.Dealer_Code__c];
                delete asrList;
                return 'SUCCESS';
            }
            return 'Record not found';
        } catch(exception e) {
            return 'Error: Exception '+e.getMessage()+' occured at line number '+e.getLineNumber();
        }
    }
    
    //Export Logic begins
    @AuraEnabled
    public static wrapResponse exportAssignedAccounts(String citySearch, String countySearch, String zipcodeSearch, String accNameSearch, String salesRepFilter) {
        Set<Id> eAcctIdSet = new Set<Id>();
        wrapResponse wr = new wrapResponse();
        List<wrapCustAcc> wrapCustAccList = new List<wrapCustAcc>();
        List<wrapCustAcc> wrapCustUnAccList = new List<wrapCustAcc>();
        List<Territory2> eTerr = [SELECT Id, Dealer_Code__c FROM Territory2 WHERE Dealer_Code__c = :loggedUsr.Dealer_Code__c];               
        for(ObjectTerritory2Association ota : [SELECT Id, Territory2Id, ObjectId FROM ObjectTerritory2Association WHERE Territory2Id = :eTerr[0].Id]) {
            eAcctIdSet.add(ota.ObjectId);
        }
        String asrQuery = 'SELECT Id, Name, Dealer_Code__c, CreatedDate, Sales_rep__c, Sales_Rep__r.ContactId, Sales_rep__r.Name, Account__c, Account__r.Name, Account__r.Primary_County__c, Account__r.Party_ID__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingCountry, Account__r.BillingPostalCode FROM Assigned_sales_rep__c WHERE Dealer_Code__c = :dealerCode AND Sales_rep__r.ContactId != NULL';
        if(String.isNotBlank(citySearch)) {
            citySearch = '%'+citySearch+'%';
            asrQuery = asrQuery+' AND Account__r.BillingCity LIKE :citySearch';
        }
        if(String.isNotBlank(countySearch)) {
            countySearch = '%'+countySearch+'%';
            asrQuery = asrQuery+' AND Account__r.Primary_County__c LIKE :countySearch';
        }
        if(String.isNotBlank(zipcodeSearch)) {
            zipcodeSearch = '%'+zipcodeSearch+'%';
            asrQuery = asrQuery+' AND Account__r.BillingPostalCode LIKE :zipcodeSearch';
        }
        if(String.isNotBlank(accNameSearch)) {
            accNameSearch = '%'+accNameSearch+'%';
            asrQuery = asrQuery+' AND Account__r.Name LIKE :accNameSearch';
        }
        List<Assigned_sales_rep__c> asrList = new List<Assigned_sales_rep__c>();
        asrList = Database.query(asrQuery);
        if(asrList.size() > 0 && String.isNotBlank(salesRepFilter) && salesRepFilter == 'All Assigned Accounts') {
            for(Assigned_sales_rep__c asr : asrList) {
                wrapCustAcc asrRec = new wrapCustAcc();
                asrRec.accLink = '/'+asr.Account__c;
                asrRec.accId = asr.Account__c;
                asrRec.accountName = asr.Account__r.Name;
                //asrRec.dealerCode = usr[0].Dealer_Code__c;
                asrRec.PartyId = asr.Account__r.Party_ID__c;
                asrRec.street = asr.Account__r.BillingStreet;
                asrRec.city = asr.Account__r.BillingCity;
                asrRec.county = asr.Account__r.Primary_County__c;
                asrRec.state = asr.Account__r.BillingState;
                asrRec.country = asr.Account__r.BillingCountry;
                asrRec.postalCode = asr.Account__r.BillingPostalCode;
                asrRec.assignedReps = asr.Sales_Rep__r.Name;
                asrRec.asrId = asr.Id;
                asrRec.asrCreatedDt = asr.createddate;
                asrRec.uniqfield = asr.Account__c+'-'+asr.Id;
                wrapCustAccList.add(asrRec);
                                
            }
            if(wrapCustAccList.size() > 0) {
                wr.wrapASR = wrapCustAccList;
            }
        }
        Set<Id> accIds = new Set<Id>();
        for(Assigned_sales_rep__c asr : asrList) {
            accIds.add(asr.Account__c);
        }
        system.debug('eaccidset size before: '+eAcctIdSet);
        eAcctIdSet.removeAll(accIds);
        system.debug('eaccidset size after: '+eAcctIdSet);
        String acctQuery = 'SELECT Id, Name, Dealer_Code__c, Partner_Account__c, CreatedDate, Party_ID__c, BillingStreet, Primary_County__c, BillingCity, BillingState, BillingCountry, BillingPostalCode FROM Account WHERE Id IN :eAcctIdSet AND Party_Id__c != null';
        if(String.isNotBlank(citySearch)) {
            citySearch = '%'+citySearch+'%';
            acctQuery = acctQuery+' AND BillingCity LIKE :citySearch';
        }
        if(String.isNotBlank(countySearch)) {
            countySearch = '%'+countySearch+'%';
            acctQuery = acctQuery+' AND Primary_County__c LIKE :countySearch';
        }
        if(String.isNotBlank(zipcodeSearch)) {
            zipcodeSearch = '%'+zipcodeSearch+'%';
            acctQuery = acctQuery+' AND BillingPostalCode LIKE :zipcodeSearch';
        }
        if(String.isNotBlank(accNameSearch)) {
            accNameSearch = '%'+accNameSearch+'%';
            acctQuery = acctQuery+' AND Name LIKE :accNameSearch';
        }
        List<Account> accList = new List<Account>();
        accList = Database.query(acctQuery);
        if(accList.size() > 0) {
            system.debug('wrapaccsize entered: ');
            for(Account acc : accList) {
                wrapCustAcc accRec = new wrapCustAcc();
                accRec.accLink = '/'+acc.Id;
                accRec.accId = acc.Id;
                accRec.accountName = acc.Name;
                accRec.dealerCode = dealerCode;
                accRec.PartyId = acc.Party_ID__c;
                accRec.street = acc.BillingStreet;
                accRec.city = acc.BillingCity;
                accRec.county = acc.Primary_County__c;
                accRec.state = acc.BillingState;
                accRec.country = acc.BillingCountry;
                accRec.postalCode = acc.BillingPostalCode;
                accRec.accCreatedDt = acc.CreatedDate;
                accRec.uniqfield = acc.Id+'-';
                wrapCustUnAccList.add(accRec);
            }
            if(wrapCustUnAccList.size() > 0) {
                wr.wrapAcc = wrapCustUnAccList;
                system.debug('wrapaacc: '+wrapCustUnAccList.size()+'--'+wr.wrapAcc);
            }
        }
        return wr;
    }
    
    
    @AuraEnabled
    public static wrapResponse exportSRAccounts(String citySearch, String countySearch, String zipcodeSearch, String accNameSearch, String salesRepFilter) {
        List<wrapCustAcc> wrapCustAccList = new List<wrapCustAcc>();
        WrapResponse wr = new WrapResponse();
        String asrQuery = 'SELECT Id, Name, Dealer_Code__c, CreatedDate, Sales_rep__c, Sales_rep__r.Name, Account__c, Account__r.Name, Account__r.Primary_County__c, Account__r.Party_ID__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingCountry, Account__r.BillingPostalCode FROM Assigned_sales_rep__c WHERE Dealer_Code__c = :dealerCode';
        if(String.isNotBlank(citySearch)) {
            citySearch = '%'+citySearch+'%';
            asrQuery = asrQuery+' AND Account__r.BillingCity LIKE :citySearch';
        }
        if(String.isNotBlank(countySearch)) {
            countySearch = '%'+countySearch+'%';
            asrQuery = asrQuery+' AND Account__r.Primary_County__c LIKE :countySearch';
        }
        if(String.isNotBlank(zipcodeSearch)) {
            zipcodeSearch = '%'+zipcodeSearch+'%';
            asrQuery = asrQuery+' AND Account__r.BillingPostalCode LIKE :zipcodeSearch';
        }
        if(String.isNotBlank(accNameSearch)) {
            accNameSearch = '%'+accNameSearch+'%';
            asrQuery = asrQuery+' AND Account__r.Name LIKE :accNameSearch';
        }
        if(String.isNotBlank(salesRepFilter)) {
            asrQuery = asrQuery+' AND Sales_rep__c = :salesRepFilter';
        }
        List<Assigned_sales_rep__c> asrList = new List<Assigned_sales_rep__c>();
        asrList = Database.query(asrQuery);
        if(asrList.size() > 0 && String.isNotBlank(salesRepFilter) && salesRepFilter != 'All Assigned Accounts' && salesRepFilter != 'All UnAssigned Accounts') {
            for(Assigned_sales_rep__c asr : asrList) {
                wrapCustAcc asrRec = new wrapCustAcc();
                asrRec.accLink = '/'+asr.Account__c;
                asrRec.accId = asr.Account__c;
                asrRec.accountName = asr.Account__r.Name;
                //asrRec.dealerCode = usr[0].Dealer_Code__c;
                asrRec.PartyId = asr.Account__r.Party_ID__c;
                asrRec.street = asr.Account__r.BillingStreet;
                asrRec.city = asr.Account__r.BillingCity;
                asrRec.county = asr.Account__r.Primary_County__c;
                asrRec.state = asr.Account__r.BillingState;
                asrRec.country = asr.Account__r.BillingCountry;
                asrRec.postalCode = asr.Account__r.BillingPostalCode;
                asrRec.assignedReps = asr.Sales_Rep__r.Name;
                asrRec.asrId = asr.Id;
                asrRec.asrCreatedDt = asr.createddate;
                asrRec.uniqfield = asr.Account__c+'-'+asr.Id;
                wrapCustAccList.add(asrRec);
                                
            }
            if(wrapCustAccList.size() > 0) {
                wr.wrapASR = wrapCustAccList;
            }
        }
        return wr;
    }
    //Export Login Ends
    
    public class wrapSROption {
        @AuraEnabled public String SRName;
        @AuraEnabled public String SRUserId;
        public wrapSROption(){
            SRName = '';
            SRUserId = '';
        }
    }
    
    
    public class wrapCustAcc {
        @AuraEnabled public String accLink;
        @AuraEnabled public String accId;
        @AuraEnabled public String accountName;
        @AuraEnabled public String dealerCode;
        @AuraEnabled public String PartyId;
        @AuraEnabled public String street;
        @AuraEnabled public String state;
        @AuraEnabled public String city;
        @AuraEnabled public String county;
        @AuraEnabled public String postalCode;
        @AuraEnabled public String country;
        @AuraEnabled public String assignedReps;
        @AuraEnabled public String assignedRepIds;
        @AuraEnabled public String asrId;
        @AuraEnabled public DateTime asrCreatedDt;
        @AuraEnabled public DateTime accCreatedDt;
        @AuraEnabled public String uniqfield;
        
        public wrapCustAcc(){
            accLink = '';
            accId = '';
            accountName = '';
            dealerCode = '';
            PartyId = '';
            Street = '';
            State = '';
            City = '';
            county = '';
            PostalCode = '';
            country = '';
            assignedReps = '';
            assignedRepIds = '';
            asrId = '';
            uniqfield = '';
            
        }
    }
    
    public class wrapResponse {
        @AuraEnabled public List<wrapCustAcc> wrapAcc;
        @AuraEnabled public List<wrapCustAcc> wrapASR;
        @AuraEnabled public Integer totalAsrSize;
        @AuraEnabled public Integer totalAccSize;
        @AuraEnabled public List<String> unassignAccts;
        @AuraEnabled public String loggedUserId;
        @AuraEnabled public Boolean isSalesRep;
        @AuraEnabled public List<String> allTerrAccIds;
        @AuraEnabled public Boolean restrictSalesRep;
        public wrapResponse(){
            
        }
    }
}