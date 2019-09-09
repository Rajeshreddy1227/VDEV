/**
* @author         salesforce services       
* @date           06/23/2016
* @description    model class for Account
* @group          Vgta_ContactTriggerHandler,Vgta_ContactTrigger
*
*
*/
public class Vgtna_ContactModel {
    public Vgtna_ContactModel() {
        
    }
    
/**
* @param Method Name: sample
* @param author: Salesforce Services
* @param Date: 09/19/2018
* @description : Method Looks at updated or New Contacts and sets source accordingly for non-corporate provided contacts
*                specifically when cloned by internal users or dealer contacts
* @param  : list<Contact>, map<Id,Contact>, boolean
* @return : None 
*/

    public static void assignSource(List<Contact> newContact, Map<Id,Contact> oldContact, Boolean isInsert)
    {
        Set<Id> ownerId = new Set<Id>();
        
        for(Contact cnt: newContact)
        {
           ownerId.add(cnt.OwnerId);
        }
        System.debug('User Id of Owners: '+ownerId);
        Map<Id, User> ContactOwner = new Map<Id, User>([Select Id, IsPortalEnabled From User Where Id In: ownerId]);

        for(Contact cnt: newContact)
        {
            {
                // Only bulk loaded contacts should have an External_Id__c value.  Cloning it 
                // causes an error when trying to save a cloned contact with a dupe external_id__c
                cnt.External_ID__c = null;
                cnt.Corporate_Lookup__c=null;
                if(ContactOwner.get(cnt.OwnerId).isPortalEnabled)
                {
                    system.debug('Dealer Source');
                    cnt.Source__c = vgtna_Constants.DEALER_CONTACT_SOURCE;
                }
                else 
                {
                    system.debug('Corporate User Source');
                    cnt.Source__c = vgtna_Constants.CORPORATE_CONTACT_SOURCE;
                }
                cnt.Non_Corporate_Contact__c = cnt.AccountId;
            }
        }
            
    }
    public static void FixSourceLookup(List<Contact> newContact, Map<Id,Contact> oldContact, Boolean isInsert)
    {
        for(Contact cnt: newContact)
        {
            if(cnt.Source__c == vgtna_Constants.FLEETSEEK_CONTACT_SOURCE || cnt.Source__c == vgtna_Constants.D_B_CONTACT_SOURCE)
            {
                cnt.Corporate_Lookup__c=cnt.AccountId;
                cnt.Non_Corporate_Contact__c = null;
            }
            else if(cnt.Source__c == vgtna_Constants.DEALER_CONTACT_SOURCE || cnt.Source__c == vgtna_Constants.CORPORATE_CONTACT_SOURCE)
            {
                cnt.Corporate_Lookup__c=null;
                cnt.Non_Corporate_Contact__c = cnt.AccountId;
            }
        }
    }
    
    
}