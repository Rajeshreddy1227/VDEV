public with sharing class Vgtna_FetchCustomerActivities {
    @AuraEnabled 
    public static List<wrapActivity> getCustActivities(String recId, Boolean viewAll, String location) {
        try {
            //system.debug('recid: '+recId);
            User u = [SELECT Id, Dealer_Code__c, Dealer_Brand__c, ContactId, Primary_Dealer_Code__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
            system.debug('contactId: '+u.contactId);
            AccountContactRelation acr;
            if(u.ContactId != null) {
                acr = [SELECT Id, Roles FROM AccountContactRelation WHERE ContactId = :u.ContactId and Account_Dealer_Code__c = :u.Dealer_Code__c LIMIT 1];
            }
            //system.debug('u.profile.name: '+u.Profile.Name);
            List<Task> tList = new List<Task>();
            if(String.isNotBlank(recId)) {
                if(viewAll == true && location != 'activitiestab') {
                    if(u.ContactId == null || (u.ContactId != null && (acr.Roles.contains('Manager') || acr.Roles.contains('Executive')))) {
                        tList = [SELECT Id, Account__c, Account__r.Name,TaskSubtype, WhatId, What.Name, Subject, CreatedDate, Status, Dealer_code__c, Owner.Name, ActivityDate, Brand__c FROM Task WHERE Account__c = :recId ORDER BY ActivityDate DESC NULLS LAST LIMIT 5];
                    } else {
                        tList = [SELECT Id, Account__c, Account__r.Name,TaskSubtype, WhatId, What.Name, Subject, CreatedDate, Status, Dealer_code__c, Owner.Name, ActivityDate, Brand__c FROM Task WHERE Account__c = :recId AND ownerId = :u.Id ORDER BY ActivityDate DESC NULLS LAST LIMIT 5];
                    }
                } else {
                   // system.debug('roles: '+acr.Roles);
                    if(u.ContactId == null || (u.ContactId != null && (acr.Roles.contains('Manager') || acr.Roles.contains('Executive')))) {
                        tList = [SELECT Id, Account__c, Account__r.Name,TaskSubtype, WhatId, What.Name, Subject, CreatedDate, Status, Dealer_code__c, Owner.Name, ActivityDate, Brand__c FROM Task WHERE Account__c = :recId ORDER BY ActivityDate DESC NULLS LAST];
                    } else {
                        tList = [SELECT Id, Account__c, Account__r.Name,TaskSubtype, WhatId, What.Name, Subject, CreatedDate, Status, Dealer_code__c, Owner.Name, ActivityDate, Brand__c FROM Task WHERE Account__c = :recId AND OwnerId = :u.Id ORDER BY ActivityDate DESC NULLS LAST];
                    }
                }
            } else {
                if(viewAll == true && location != 'activitiestab') {
                    if(u.ContactId == null || (u.ContactId != null && (acr.Roles.contains('Manager') || acr.Roles.contains('Executive')))) {
                        tList = [SELECT Id, Account__c, Account__r.Name,TaskSubtype, WhatId, What.Name, Subject, CreatedDate, Status, Dealer_code__c, Owner.Name, ActivityDate, Brand__c FROM Task WHERE Status!='Completed' ORDER BY ActivityDate DESC NULLS LAST LIMIT 5];
                    } else {
                        tList = [SELECT Id, Account__c, Account__r.Name,TaskSubtype, WhatId, What.Name, Subject, CreatedDate, Status, Dealer_code__c, Owner.Name, ActivityDate, Brand__c FROM Task WHERE Status!='Completed' AND OwnerId = :u.Id ORDER BY ActivityDate DESC NULLS LAST LIMIT 5];
                    }
                } else {
                    if(u.ContactId == null || (u.ContactId != null && (acr.Roles.contains('Manager') || acr.Roles.contains('Executive')))) {
                        tList = [SELECT Id, Account__c, Account__r.Name,TaskSubtype, WhatId, What.Name, Subject, CreatedDate, Status, Dealer_code__c, Owner.Name, ActivityDate, Brand__c FROM Task ORDER BY ActivityDate DESC NULLS LAST];
                    } else {
                        tList = [SELECT Id, Account__c, Account__r.Name,TaskSubtype, WhatId, What.Name, Subject, CreatedDate, Status, Dealer_code__c, Owner.Name, ActivityDate, Brand__c FROM Task WHERE OwnerId = :UserInfo.getUserId() ORDER BY ActivityDate DESC NULLS LAST];
                    }
                }
            }          
            
                                        
            
            
            List<Event> eList = new List<Event>();
            if(String.isNotBlank(recId)) {
                if(viewAll == true && location != 'activitiestab') {
                    if(u.ContactId == null || (u.ContactId != null && (acr.Roles.contains('Manager') || acr.Roles.contains('Executive')))) {
                        eList = [SELECT Id, Account__c, Account__r.Name, WhatId, What.Name, Subject, CreatedDate, Dealer_code__c, Owner.Name, ActivityDate, Brand__c FROM Event WHERE Account__c = :recId ORDER BY ActivityDate DESC NULLS LAST LIMIT 5];
                    } else {
                        eList = [SELECT Id, Account__c, Account__r.Name, WhatId, What.Name, Subject, CreatedDate, Dealer_code__c, Owner.Name, ActivityDate, Brand__c FROM Event WHERE Account__c = :recId AND ownerId = :u.Id ORDER BY ActivityDate DESC NULLS LAST LIMIT 5];
                    }
                } else {
                    if(u.ContactId == null || (u.ContactId != null && (acr.Roles.contains('Manager') || acr.Roles.contains('Executive')))) {
                        eList = [SELECT Id, Account__c, Account__r.Name, WhatId, What.Name, Subject, CreatedDate, Dealer_code__c, Owner.Name, ActivityDate, Brand__c FROM Event WHERE Account__c = :recId ORDER BY ActivityDate DESC NULLS LAST];
                    } else {
                        eList = [SELECT Id, Account__c, Account__r.Name, WhatId, What.Name, Subject, CreatedDate, Dealer_code__c, Owner.Name, ActivityDate, Brand__c FROM Event WHERE Account__c = :recId AND ownerId = :u.Id ORDER BY ActivityDate DESC NULLS LAST];
                    }
                }
            } else {
                DateTime currentTime = System.now();
                if(viewAll == true && location != 'activitiestab') {
                    if(u.ContactId == null || (u.ContactId != null && (acr.Roles.contains('Manager') || acr.Roles.contains('Executive')))) {
                        eList = [SELECT Id, Account__c, Account__r.Name, WhatId, What.Name, Subject, CreatedDate, Dealer_code__c, Owner.Name, ActivityDate, Brand__c FROM Event WHERE EndDateTime >= :currentTime ORDER BY ActivityDate DESC NULLS LAST LIMIT 5];
                    } else {
                        eList = [SELECT Id, Account__c, Account__r.Name, WhatId, What.Name, Subject, CreatedDate, Dealer_code__c, Owner.Name, ActivityDate, Brand__c FROM Event WHERE EndDateTime >= :currentTime AND OwnerId = :u.Id ORDER BY ActivityDate DESC NULLS LAST LIMIT 5];
                    }
                } else {
                    if(u.ContactId == null || (u.ContactId != null && (acr.Roles.contains('Manager') || acr.Roles.contains('Executive')))) {
                        eList = [SELECT Id, Account__c, Account__r.Name, WhatId, What.Name, Subject, CreatedDate, Dealer_code__c, Owner.Name, ActivityDate, Brand__c FROM Event WHERE EndDateTime >= :currentTime ORDER BY ActivityDate DESC NULLS LAST];
                    } else {
                        eList = [SELECT Id, Account__c, Account__r.Name, WhatId, What.Name, Subject, CreatedDate, Dealer_code__c, Owner.Name, ActivityDate, Brand__c FROM Event WHERE EndDateTime >= :currentTime AND OwnerId = :UserInfo.getUserId() ORDER BY ActivityDate DESC NULLS LAST];
                    }
                }
            }
            List<wrapActivity> wrapActivities = new List<wrapActivity>();
            //system.debug('dcode: '+u.Dealer_Code__c+'--'+tList[0].Dealer_Code__c+'--'+tlist);
            for(Task t : tList) {
                //System.debug('tcode: '+t.Dealer_Code__c);
                if((String.isNotBlank(u.Dealer_Code__c) && String.isNotBlank(t.Dealer_Code__c) && u.Dealer_Code__c == t.Dealer_Code__c && u.ContactId != null) || (u.ContactId == null && u.Dealer_Brand__c == t.Brand__c) || u.Profile.Name == 'System Administrator') {
                    wrapActivity wa = new wrapActivity();
                    wa.ActivityLink = '/'+t.Id;
                    if(String.isNotBlank(t.Account__c)) {
                        wa.RelatedToLink = '/'+t.Account__c;
                    } else if(String.isNotBlank(t.WhatId)) {
                        wa.RelatedToLink = '/'+t.WhatId;
                    } else {
                        wa.RelatedToLink = null;
                    }
                    wa.Subject = String.isNotBlank(t.Subject)?t.Subject:'-';
                    wa.Status = t.Status;
                    wa.Type = t.TaskSubType;
                    wa.AssignedTo = t.Owner.Name;
                    if(String.isNotBlank(t.Account__c)) {
                        wa.RelatedTo = t.Account__r.Name;
                    } else if(String.isNotBlank(t.WhatId)) {
                        wa.RelatedTo = t.What.Name;
                        
                    } else {
                        wa.RelatedTo = null;
                    }
                    wa.CreatedDate = t.createddate;
                    wa.Duedate = t.ActivityDate;
                    wrapActivities.add(wa);
                }
            }
            for(Event e : eList) {
                if((String.isNotBlank(u.Dealer_Code__c) && String.isNotBlank(e.Dealer_Code__c) && u.Dealer_Code__c == e.Dealer_Code__c && u.ContactId != null) || (u.ContactId == null && u.Dealer_Brand__c == e.Brand__c) || u.Profile.Name == 'System Administrator') {
                    wrapActivity wa = new wrapActivity();
                    wa.ActivityLink = '/'+e.Id;
                    if(String.isNotBlank(e.Account__c)) {
                        wa.RelatedToLink = '/'+e.Account__c;
                    } else if(String.isNotBlank(e.WhatId)) {
                        wa.RelatedToLink = '/'+e.WhatId;
                    } else {
                        wa.RelatedToLink = null;
                    }
                    wa.Subject = String.isNotBlank(e.Subject)?e.Subject:'-';
                    wa.Status = '';
                    wa.Type = 'Event';
                    wa.AssignedTo = e.Owner.Name;
                    if(String.isNotBlank(e.Account__c)) {
                        wa.RelatedTo = e.Account__r.Name;
                    } else if(String.isNotBlank(e.WhatId)) {
                        wa.RelatedTo = e.What.Name;
                    } else {
                        wa.RelatedTo = null;
                    }
                    wa.CreatedDate = e.createddate;
                    wa.Duedate = e.ActivityDate;
                    wrapActivities.add(wa);
                }
            }
            List<wrapActivity> wrap5Activities = new List<wrapActivity>();
            integer k = 5;
            if(wrapActivities.size() < 5) {
                k = wrapActivities.size();
            }
            if(viewAll == true && location != 'activitiestab') {
                for(integer i = 0; i<k; i++) {
                    wrap5Activities.add(wrapActivities[i]);
                }
                return wrap5Activities;
            }
            //system.debug('tlist: '+tlist);
            return wrapActivities;
        } catch (exception e) {
            System.debug('exception occured at line number: '+e.getLineNumber()+' with error '+e.getMessage());
            return null;
        }
    }
    
    @AuraEnabled
    public static User getLoggedUser() {
        User u = [SELECT Id, Dealer_Code__c, Dealer_Brand__c, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        return u;
    }
    
    public class wrapActivity {
        @AuraEnabled public String ActivityLink;
        @AuraEnabled public String RelatedToLink;
        @AuraEnabled public String Subject;
        @AuraEnabled public String Status;
        @AuraEnabled public String Type;
        @AuraEnabled public String AssignedTo;
        @AuraEnabled public String RelatedTo;
        @AuraEnabled public DateTime CreatedDate;
        @AuraEnabled public Date Duedate;
        
        public wrapActivity(){
            ActivityLink = '';
            RelatedToLink = '';
            Subject = '';
            Status = '';
            Type = '';
            AssignedTo = '';
            RelatedTo = '';
            CreatedDate = null;
            Duedate = null;
        }
    }
}