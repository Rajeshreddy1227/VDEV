/**
* @author         salesforce services       
* @date           06/23/2016
* @description    model class for Account
* @group          Vgta_LeadTriggerHandler,Vgta_LeadTrigger
*
*
*/
public Without Sharing class Vgtna_LeadModel {
    public Vgtna_LeadModel() {
        
    }
    
/**
* @param Method Name: sample
* @param author: Salesforce Services
* @param Date: 09/19/2018
* @description : Method Looks at incoming leads and assigns dealer code by using reference object called Area_Of_Responsibility__c
* @param  : list<Lead>, map<Id,Lead>, boolean
* @return : None 
*/

    public static void assignDealership(List<Lead> newLeads, Map<Id,Lead> oldLeads, Boolean isInsert){

        List<Lead> newLeadsToBeProcessed = new List<Lead>();
        List<Lead> leadsWithExceptions = new List<Lead>();
       // List<LeadErrorEvent__e> errLogs = new List<LeadErrorEvent__e>();
        List<Lead> leadsWithDealerCode = new List<Lead>();
        System.debug('newLeads----->'+newLeads);
        System.debug('isInsert----->'+isInsert);
        Set<String> newLeadZips = new Set<String>();
        // Build list of Leads that don't already contain a value for Dealer_Code__c.  Some leads come in with this value already
         for(Lead l: newLeads)
        {
            System.debug('l.Dealer_Code__c----->'+l.Dealer_Code__c);
            System.debug('l.Party_ID__c----->'+l.Party_ID__c);
            if(l.Dealer_Code__c != null)
            {
                // If dealer code and party id are present do nothing. Just add to a list for further assignment of dealer queue.
                //leadsWithDealerCode.add(l);
                Account acc = [select name from Account where dealer_code__c = :l.Dealer_Code__c limit 1];
                l.DealerAccountName__c = acc.name;
            }
            else
            {
                newLeadsToBeProcessed.add(l);
                if(l.PostalCode !=null && l.CountryCode=='US')
                {
                    newLeadZips.add(l.PostalCode.substring(0,5));
                }
                if(l.PostalCode !=null && l.CountryCode=='CA')
                {
                    newLeadZips.add(l.PostalCode.substring(0,3));
                }
                
            }
        }
        
         // If there are Leads to be processed, get reference data from custom setting Area_Of_Responsibility__c
        if(!newLeadsToBeProcessed.isEmpty() && !newLeadZips.isEmpty())
        //if(!newLeadsToBeProcessed.isEmpty())
        {
            
            //Assignment based on AOR sObject
            
            Map<String, AOR__c> CustomSettingsMapAOR_US = new Map<String,AOR__c>();
            Map<String, AOR__c> CustomSettingsMapAOR_CA = new Map<String,AOR__c>();
                        
            
            List<AOR__c> CustomSettingsAOR = [Select Id, Region__c, Brand__c, Dealer_Code__c ,City__c,Country__c,Postal_Code__c, State_Province__c
                                              from AOR__c
                                              where Postal_Code__c IN:newLeadZips
                                              Limit 50000];
           /** List<AOR__c> CustomSettingsAOR = [Select Id, Region__c,Brand__c, Dealer_Code__c ,City__c,Country__c,Postal_Code__c, State_Province__c
                                                                             from AOR__c
                                                                             Limit 50000];**/
            // build Maps for US and CA - Different keys so creating one for each
             for(AOR__c aor : CustomSettingsAOR)
            {
                String zipAOR;
                if(aor.Country__c=='CA')
                {
                   zipAOR = aor.Postal_Code__c == null ? null : aor.Postal_Code__c.substring(0,3);
                   // CustomSettingsMapAOR_CA.put(aor.Brand__c+'-'+aor.State_Province__c+'-'+aor.Postal_Code__c.substring(0,3)+'-'+aor.City__c, aor);
                    CustomSettingsMapAOR_CA.put(aor.Brand__c+'-'+aor.State_Province__c+'-'+zipAOR+'-'+aor.City__c, aor);
                } else if (aor.Country__c=='US')
                {
                     zipAOR = aor.Postal_Code__c == null ? null : aor.Postal_Code__c.substring(0,5);
                    //CustomSettingsMapAOR_US.put(aor.Brand__c+'-'+aor.Postal_Code__c.substring(0,5), aor);
                    CustomSettingsMapAOR_US.put(aor.Brand__c+'-'+zipAOR, aor);
                }
            }
            
            // Iterate through the leads to be processed, match in Maps to set Dealer Code or throw an error on the record
            String searchString='';
            for(Lead pl: newLeadsToBeProcessed)
            {
                searchString='';
                if(pl.CountryCode=='US')
                {
                    // searchString=pl.Brand__c+'-'+pl.PostalCode.substring(0,5);
                    searchString= pl.Brand__c+'-'+pl.PostalCode.left(5);
                    
                    if(CustomSettingsMapAOR_US.containsKey(searchString))
                    {
                        pl.Dealer_Code__c=CustomSettingsMapAOR_US.get(searchString).Dealer_Code__c;
                        pl.Region__c = CustomSettingsMapAOR_US.get(searchString).Region__c;
                        Account acc = [select name from Account where dealer_code__c = :CustomSettingsMapAOR_US.get(searchString).Dealer_Code__c limit 1];
                        pl.DealerAccountName__c = acc.name;
                    } 
                }
                 else if(pl.CountryCode=='CA')
                {
                   // searchString=pl.Brand__c+'-'+pl.StateCode+'-'+pl.PostalCode.substring(0,3)+'-'+pl.City;
                    searchString= pl.Brand__c+'-'+pl.StateCode+'-'+pl.PostalCode.left(3)+'-'+pl.City;
                    if(CustomSettingsMapAOR_CA.containsKey(searchString))    
                    {
                        pl.Dealer_Code__c=CustomSettingsMapAOR_CA.get(searchString).Dealer_Code__c;
                        pl.Region__c = CustomSettingsMapAOR_CA.get(searchString).Region__c;
                        Account acc = [select name from Account where dealer_code__c = :CustomSettingsMapAOR_CA.get(searchString).Dealer_Code__c limit 1];
                        pl.DealerAccountName__c = acc.name;
                    }
                }
            }
        }
    }
     
    public static void assignDealerQueuesAfterInsert(List<Lead> dealerQueuesToBeAssignedLeads)
    {
        Map<String,Group> matchingQueueMap = new Map<String,Group>();   
        List<Lead> newLeadqueuesToBeCreated = new List<Lead>();
        List<Lead> leadsMatchingLeadQueue = new List<Lead>();
       
        
        // Fetch the dealer codes from the leads and add to a list of string for query against Group.DeveloperName
        Set<String> dealerCodes = new Set<String>();
        
        for(Lead l: dealerQueuesToBeAssignedLeads)
        {
            if(l.Dealer_Code__c !=null && l.id != null)
            {
                // Dealer Codes that begin with a number are automatically prefaced with X for DeveloperName when created, adding X if needed for query filter
                String dc = l.Dealer_Code__c;
                if(dc.left(1).isNumeric())
                {
                    dc='X'+dc;
                }
                dealerCodes.add(dc.trim()); 
            }
        }
        System.debug('********* dealerCodes used to find matching groups by Developername are '+dealerCodes);
        // Now query salesforce DB for matching queues from Group to see if they are already present.
        // See if any matches found. If Yes assign the leads to their respective queues
        
        for(Group g: [Select Id, Name, DeveloperName
                     From Group
                     Where DeveloperName In: dealerCodes
                     And Type='Queue'])
            {
                System.debug('Dealer Code that is being added to MatchingQueueMap is : '+g.DeveloperName);
                matchingQueueMap.put(g.DeveloperName,g);
            }
        
        // Iterate through the map to find matching dealer queue and assign ownership. If no match found put them in a seperate list.
        
        for(Lead l: dealerQueuesToBeAssignedLeads)
        {

            String dc = l.Dealer_Code__c;
            if(dc.left(1).isNumeric())
            {
                dc='X'+dc;
            }

            if(matchingQueueMap.containsKey(dc))
            {
                
                Lead leadClone = new Lead(id=l.Id);
                leadClone.OwnerId= matchingQueueMap.get(dc).id;
                leadsMatchingLeadQueue.add(leadClone);
                
            }
            else
            {
              // Put them in a seperate list
                newLeadqueuesToBeCreated.add(l);
            }
        }
        
       
        
        if(!leadsMatchingLeadQueue.isEmpty())
        {
            update leadsMatchingLeadQueue;
            
        }
        
       

        // Pass the list for further processing- creation and assignment of dealer queues.
        // Don't need it
        
           /** if(!newLeadqueuesToBeCreated.isEmpty())
            {
                createDealerQueues(newLeadqueuesToBeCreated);
            }**/
        
    }
    
    
    
    public static void assignDealerCodeAndBrand(List<Lead> newLeads, Map<Id,Lead> oldLeads, Boolean isInsert)
    {
        
        Set<Id> sUser = new Set<Id>();    
        for (Lead oLead : newLeads)
        {
            sUser.Add(oLead.OwnerId);
        }
        
        Map<Id, User> lUser = new Map<Id, User>([Select Id, Dealer_Brand__c, Dealer_Code__c From User Where Id In :sUser]);
        
        for(Lead oLead : newLeads)
        {
            oLead.Dealer_Code__c = lUser.get(oLead.OwnerId).Dealer_Code__c;
            oLead.Brand__c = lUser.get(oLead.OwnerId).Dealer_Brand__c;
            System.debug('0.Dealer_Code__c----->'+oLead.Dealer_Code__c);
        }
        
        // Mimic AOR Logic just to get region and not dealer code
        
        Set<String> newLeadZips = new Set<String>();
        List<Lead> newLeadsToBeProcessed = new List<Lead>();
        List<Lead> leadsWithExceptions = new List<Lead>();
        
        System.debug('newLeads----->'+newLeads);
        System.debug('isInsert----->'+isInsert);
        
        // Build list of Leads that don't already contain a value for Dealer_Code__c.  Some leads come in with this value already
         for(Lead l: newLeads)
        {
            System.debug('l.Dealer_Code__c----->'+l.Dealer_Code__c);
            System.debug('l.Party_ID__c----->'+l.Party_ID__c);
            if(l.Dealer_Code__c != null && l.Party_ID__c != null)
            {
                // If dealer code and party id are present do nothing. Just add to a list for further assignment of dealer queue.
                //leadsWithDealerCode.add(l);
            }
            else
            {
                newLeadsToBeProcessed.add(l);
                if(l.PostalCode !=null && l.CountryCode=='US')
                {
                    newLeadZips.add(l.PostalCode.substring(0,5));
                }
                if(l.PostalCode !=null && l.CountryCode=='CA')
                {
                    newLeadZips.add(l.PostalCode.substring(0,3));
                }
            }
        }
        
         // If there are Leads to be processed, get reference data from custom setting Area_Of_Responsibility__c
         if(!newLeadsToBeProcessed.isEmpty() && !newLeadZips.isEmpty())
       // if(!newLeadsToBeProcessed.isEmpty())
        {
            system.debug('newLeadZips--->'+newLeadZips);
            //Assignment based on AOR sObject
            
            Map<String, AOR__c> CustomSettingsMapAOR_US = new Map<String,AOR__c>();
            Map<String, AOR__c> CustomSettingsMapAOR_CA = new Map<String,AOR__c>();
                        
            
             List<AOR__c> CustomSettingsAOR = [Select Id, Region__c, Brand__c, Dealer_Code__c ,City__c,Country__c,Postal_Code__c, State_Province__c
                                              from AOR__c
                                              where Postal_Code__c IN:newLeadZips
                                              Limit 50000];
            system.debug('CustomSettingsAOR--->'+CustomSettingsAOR);
            /**List<AOR__c> CustomSettingsAOR = [Select Id, Region__c,Brand__c, Dealer_Code__c ,City__c,Country__c,Postal_Code__c, State_Province__c
                                                                             from AOR__c
                                                                             Limit 50000];**/
            // build Maps for US and CA - Different keys so creating one for each
            for(AOR__c aor : CustomSettingsAOR)
            {
                String zipAOR;
                if(aor.Country__c=='CA')
                {
                   zipAOR = aor.Postal_Code__c == null ? null : aor.Postal_Code__c.substring(0,3);
                   // CustomSettingsMapAOR_CA.put(aor.Brand__c+'-'+aor.State_Province__c+'-'+aor.Postal_Code__c.substring(0,3)+'-'+aor.City__c, aor);
                    CustomSettingsMapAOR_CA.put(aor.Brand__c+'-'+aor.State_Province__c+'-'+zipAOR+'-'+aor.City__c, aor);
                } else if (aor.Country__c=='US')
                {
                     zipAOR = aor.Postal_Code__c == null ? null : aor.Postal_Code__c.substring(0,5);
                    //CustomSettingsMapAOR_US.put(aor.Brand__c+'-'+aor.Postal_Code__c.substring(0,5), aor);
                    CustomSettingsMapAOR_US.put(aor.Brand__c+'-'+zipAOR, aor);
                }
            }
            
            
            
            // Iterate through the leads to be processed, match in Maps to set Dealer Code or throw an error on the record
            String searchString='';
            for(Lead pl: newLeadsToBeProcessed)
            {
                searchString='';
                if(pl.CountryCode=='US')
                {
                   // searchString=pl.Brand__c+'-'+pl.PostalCode.substring(0,5);
                    searchString= pl.PostalCode == null ? pl.Brand__c+'-'+null : pl.Brand__c+'-'+pl.PostalCode.substring(0,5);
                    if(CustomSettingsMapAOR_US.containsKey(searchString))
                    {
                       // pl.Dealer_Code__c=CustomSettingsMapAOR_US.get(searchString).Dealer_Code__c;
                        pl.Region__c = CustomSettingsMapAOR_US.get(searchString).Region__c;
                        
                        
                    } 
                    
                }
                 else if(pl.CountryCode=='CA')
                {
                   // searchString=pl.Brand__c+'-'+pl.StateCode+'-'+pl.PostalCode.substring(0,3)+'-'+pl.City;
                   searchString= pl.PostalCode == null ? pl.Brand__c+'-'+pl.StateCode+'-'+null+'-'+pl.City : pl.Brand__c+'-'+pl.StateCode+'-'+pl.PostalCode.substring(0,3)+'-'+pl.City;
                    if(CustomSettingsMapAOR_CA.containsKey(searchString))    
                    {
                       // pl.Dealer_Code__c=CustomSettingsMapAOR_CA.get(searchString).Dealer_Code__c;
                        pl.Region__c = CustomSettingsMapAOR_CA.get(searchString).Region__c;
                        
                    }
                   
                }
            }
        }
      
       
        
    }
    
    public static void assignLeadShare(List<Lead> newLeads, Map<Id,Lead> oldLeads)
    {
        List<Lead> newLeadsToBeProcessed = new List<Lead>();
        for(Id o: oldLeads.keyset())
        {
            for(Lead n: newLeads)
            {
                if(o==n.id && (oldLeads.get(o).Dealer_Code__c != n.Dealer_Code__c || oldLeads.get(o).OwnerId != n.OwnerId))
                {
                    newLeadsToBeProcessed.add(n);
                }
            }
        }
        
        if(!newLeadsToBeProcessed.isEmpty())
            {
                assignLeadShare4PortalUsers(newLeadsToBeProcessed);
            }
    }
    
    public static void assignLeadShare4PortalUsers(List<Lead> newLeads)
    {
         Set<String> dealerCode4PublicGroup = new Set<String>();
         Map<String,Id> dealerCode2LeadIdMap = new Map<String,Id>();
         Map<Id,Id> groupId2LeadIdMap = new Map<Id,Id>(); 
            
             for(Lead l: newLeads)
            {
                if(l.Dealer_Code__c != null)
                {
                    String sname = l.Dealer_Code__c+'_Managers';
                    if(l.Dealer_Code__c.left(1).isNumeric())
                    {
                        sname='X'+sname;
                    }
                    dealerCode4PublicGroup.add(sname);
                    dealerCode2LeadIdMap.put(l.Dealer_Code__c,l.Id);
                }
                
            }
        
            if(!dealerCode4PublicGroup.isEmpty())
            {
                List<Group> managersPublicGroup = Vgtna_GroupModel.findDealerSharingGroup(dealerCode4PublicGroup);
                System.debug('managersPublicGroup--->'+ managersPublicGroup);
                
                if(!managersPublicGroup.isEmpty())
                    {
                        for(Group g: managersPublicGroup)
                        {
                            List<String> newCode = g.DeveloperName.split('_');
                            String dc = newCode[0];
                            if(dc.left(1)=='X')
                            {
                                dc=dc.mid(1, dc.length()-1);
                            }
                            if(dealerCode2LeadIdMap.get(dc) != null)
                            {
                                groupId2LeadIdMap.put(g.id,dealerCode2LeadIdMap.get(dc));
                            }
                        }
                    }
            }
            // Send it for assignment to share object
            if(!groupId2LeadIdMap.isEmpty())
                 {
                     Vgtna_SharingModel.setObjectShare(groupId2LeadIdMap,'Lead');
                 }
                
    }
}