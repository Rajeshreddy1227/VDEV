public with sharing class Vgtna_UserModel {
    public static void manageDealerPermissionSets(List<User> newList, Map<Id, User> oldMap, Boolean isInsert) {
        List<User> updateUser = new List<User>();
        Map<String, PermissionSet> psMap = new Map<String, PermissionSet>();
        List<PermissionSetAssignment> insertPaList = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> deletePaList = new List<PermissionSetAssignment>();
        try {
            for(PermissionSet ps : [SELECT Id, Name FROM Permissionset WHERE Name IN ('Mack_Dealer_User', 'Volvo_Dealer_User')]) {
                psMap.put(ps.Name, ps);
            }
            if(isInsert == true) {
                for(User u : newList) {
                    if(u.ContactId != null && u.Dealer_Brand__c != null) {
                        if(u.Dealer_Brand__c == 'Volvo') {
                            PermissionSetAssignment pa = new PermissionSetAssignment();
                            pa.AssigneeId = u.Id;
                            pa.PermissionSetId = psMap.get('Volvo_Dealer_User').Id;
                            insertPaList.add(pa);
                        }
                        if(u.Dealer_Brand__c == 'Mack') {
                            PermissionSetAssignment pa = new PermissionSetAssignment();
                            pa.AssigneeId = u.Id;
                            pa.PermissionSetId = psMap.get('Mack_Dealer_User').Id;
                            insertPaList.add(pa);
                        }
                    }
                }
            } else {
                Map<Id, User> newUidMap = new Map<Id, User>();
                Map<String, PermissionSetAssignment> userPsaIdPSAMap = new Map<String, PermissionSetAssignment>();
                for(User u : newList) {
                    if(u.ContactId != null && u.Dealer_Brand__c != null && u.Dealer_Brand__c != oldMap.get(u.Id).Dealer_Brand__c) {
                        newUidMap.put(u.Id, u);
                    }
                }
                for(PermissionSetAssignment psa : [SELECT Id, Assigneeid, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId IN :newUidMap.keySet() and PermissionSet.Name IN ('Volvo_Dealer_User', 'Mack_Dealer_User')]) {
                    userPsaIdPSAMap.put(psa.AssigneeId+'-'+psa.PermissionSetId, psa);
                }
                System.debug('userPsaIdPSAMap:'+userPsaIdPSAMap);
                for(User u : newUidmap.values()) {
                    if(u.Dealer_Brand__c == 'Volvo') {
                        if(!userPsaIdPSAMap.containsKey(u.Id+'-'+psMap.get('Volvo_Dealer_User').Id)) {
                            PermissionSetAssignment psa = new PermissionSetAssignment();
                            psa.AssigneeId = u.Id;
                            psa.PermissionSetId = psMap.get('Volvo_Dealer_User').Id;
                            insertPaList.add(psa);
                        }
                        if(userPsaIdPSAMap.containsKey(u.Id+'-'+psMap.get('Mack_Dealer_User').Id)) {
                            System.debug('delete mack');
                            PermissionSetAssignment psaDel = userPsaIdPSAMap.get(u.Id+'-'+psMap.get('Mack_Dealer_User').Id);
                            deletePaList.add(psaDel);
                        }
                    }
                    if(u.Dealer_Brand__c == 'Mack') {
                        if(!userPsaIdPSAMap.containsKey(u.Id+'-'+psMap.get('Mack_Dealer_User').Id)) {
                            PermissionSetAssignment psa = new PermissionSetAssignment();
                            psa.AssigneeId = u.Id;
                            psa.PermissionSetId = psMap.get('Mack_Dealer_User').Id;
                            insertPaList.add(psa);
                        }
                        if(userPsaIdPSAMap.containsKey(u.Id+'-'+psMap.get('Volvo_Dealer_User').Id)) {
                            System.debug('delete volvo');
                            PermissionSetAssignment psaDel = userPsaIdPSAMap.get(u.Id+'-'+psMap.get('Volvo_Dealer_User').Id);
                            deletePaList.add(psaDel);
                        }
                    }
                }
            }
            if(!insertPaList.isEmpty()) {
                insert insertpaList;
            }
            if(!deletePaList.isEmpty()) {
                delete deletePaList;
            }
        } catch(exception e) {
            System.debug('exception occured at line number '+e.getLineNumber()+' due to '+e.getMessage());
        }
    }
}