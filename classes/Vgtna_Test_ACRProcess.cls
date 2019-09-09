/**********************************************************************
Name:  Vgtna_Test_LeadProcess
Copyright © 2018  Salesforce
======================================================
======================================================
Purpose: Test Class for following:
**Trigger- 
1. Vgtna_AccountContactRelTrigger - 100%


**Apex Classes- 
1. AccountContactRelTriggerHandler - 93%
2. Vgtna_AccountContactRelationModel - 100%
3. Vgtna_GroupModel - 100%



-------                                                            
======================================================
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL            Description
1.0    Subho        11/20/2018      INITIAL DEVELOPMENT          Test Class
***********************************************************************/
@isTest
private class Vgtna_Test_ACRProcess 
{

    static testMethod void acrTestMethod()
    {
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        User SystemAccountOwner = new User();
        User testPartnerUser = new User();
      
        System.RunAs(runAsUsr)
        {
            // Create a System User to own the customer and partner accounts
            User SystemAcctOwner = new Vgtna_TestBuilder.UserBuilder().setlastName('Test ACR Process Account Owner').setEmail('tstacrUser@Email.com.invalid').setProfileId(vgtna_Constants.INTERNAL_USER_PROFILE).buildAndSave();
            SystemAcctOwner.UserRoleId=[Select Id From UserRole Where name='System Partner Role' Limit 1].Id;
            update SystemAcctOwner;
            SystemAccountOwner = SystemAcctOwner;
        }
        
        system.debug('**** setup account owner '+SystemAccountOwner);
        
        // Create the Dealer Account
        Account tstDealerAccount;
        Account tstDealerMgmtAccount;
        
        System.runAs(runAsUsr)
        {
        	//mgmt grp
            tstDealerMgmtAccount = new Vgtna_TestBuilder.AccountBuilder().setName('ADVANTAGE TRUCK CENTER MGMT').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).buildAndSave();
            tstDealerMgmtAccount.IsPartner = true;
            update tstDealerMgmtAccount;
            tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('ADVANTAGE TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).setDealerCode('G243').buildAndSave();            
            tstDealerAccount.ParentId = tstDealerMgmtAccount.Id;
            tstDealerAccount.IsPartner = true;
            update tstDealerAccount;
        }        
        // Set owner to System User
        system.debug('*** MgmtDealerAccount: '+tstDealerMgmtAccount +'*** DealerAccount: '+tstDealerAccount);

        // Create the Contact that will be converted into the Partner User
        Contact tstContact = new Vgtna_TestBuilder.ContactBuilder().setLastName('Partner User').setFirstName('ACR Process').setEmail('testacr@vivo.com.invalid').setAccount(tstDealerMgmtAccount).buildAndSave();
        system.debug('*** contact '+tstContact);
        User tstUser;
        // Create the Partner User
        System.RunAs(runAsUsr){
            
            tstUser = new Vgtna_TestBuilder.UserBuilder().setContact(tstContact).setlastName('SNPartnerUser').setEmail(tstContact.Email).setProfileId(vgtna_Constants.DEALER_USER_PROFILE).buildAndSave();
          
            tstUser.IsPortalEnabled=true;
            tstUser.UserRoleId=[Select Id from UserRole Where PortalAccountId=:tstDealerMgmtAccount.Id And PortalRole='Worker' Limit 1].Id;            
            testPartnerUser = tstUser;
        }
        system.debug('*** testPartnerUser '+testPartnerUser+' AND isPartner: '+testPartnerUser.IsPortalEnabled);
        
        // Create the public Group in advance
        
        Group g = new Group(Name ='G243 - Managers', DeveloperName = 'G243_Managers', Type= 'Regular');
        insert g;
		//Group gsm = new Group(Name ='Dealer Sales Managers', DeveloperName = 'Dealer_Sales_Managers', Type= 'Regular');
        //insert gsm;
        //Group gsr = new Group(Name ='Dealer Sales Reps', DeveloperName = 'Dealer_Sales_Reps', Type= 'Regular');
        //insert gsr;
        
        List<Territory2> t2List = new List<Territory2>();

        Territory2 oNode = [Select Id, Name, Territory2TypeId, Territory2ModelId 
                 From Territory2 
                 Where DeveloperName = : vgtna_Constants.AOR_TERRITORY 
                 And Territory2Model.State='Active' Limit 1 ];
        System.debug('Territory Node: '+oNode.Name);
       
        //t2List = [SELECT Id from Territory2 WHERE DeveloperName ='G243_AOR_test']
        t2List.add(new Territory2(
            AccountAccessLevel='Read',
            CaseAccessLevel='None',
            ContactAccessLevel='None',
            Dealer_Code__c = 'G243',
            DeveloperName='G243_AOR_test',
            Name='G243 - AOR',
            OpportunityAccessLevel='None',
            ParentTerritory2Id=oNode.Id,
            Territory2ModelId=oNode.Territory2ModelId,
            Territory2TypeId=oNode.Territory2TypeId
        ));
        
        t2List.add(new Territory2(
            AccountAccessLevel='Read',
            CaseAccessLevel='None',
            ContactAccessLevel='None',
            Dealer_Code__c = '786D',
            DeveloperName='X786D_AOR_test',
            Name='786D - AOR',
            OpportunityAccessLevel='None',
            ParentTerritory2Id=oNode.Id,
            Territory2ModelId=oNode.Territory2ModelId,
            Territory2TypeId=oNode.Territory2TypeId
        ));
        
        System.RunAs(runAsUsr){
            insert t2List;
        }
        
		List<AOR__c> aor = new List<AOR__c>();
        aor.add(new AOR__c(
        	Brand__c= 'Mack',
            Country__c='US',
            Dealer_Code__c = 'G243',
            Postal_Code__c='79230'
        ));
		insert aor;
              
        AccountContactRelation acr = new AccountContactRelation(contactId = tstContact.Id, Roles = 'Sales Manager', AccountId=tstDealerAccount.Id);
        insert acr;
        system.debug('default acr==>'+acr);
		Test.startTest();
          
        Test.stopTest();
        List<UserTerritory2Association> res_ut2a = [Select UserId From UserTerritory2Association where UserId =:tstUser.Id];
        //System.debug('res_ut2a'+res_ut2a);
        //System.assertEquals(1, res_ut2a.size());
        if(acr != null)
        {
            acr.roles = 'Volvo Sales Rep';
            update acr;
            
            acr.roles = 'Volvo Sales Manager';
            update acr;    
        }
        List<User> s_usr = [Select Id 
                            From User 
                            Where ContactId = :acr.ContactId];
        
        
        List<GroupMember> gmRet = [Select Id, GroupId
                            From GroupMember
                            Where GroupId =: g.Id
                            And UserOrGroupId In :s_usr];
        
        //System.assertEquals(1, gmRet.size());
        Account tstDealerAccount1;
        Account tstDealerMgmtAccount1;
        System.runAs(runAsUsr)
        {
        	//mgmt grp
            tstDealerMgmtAccount1 = new Vgtna_TestBuilder.AccountBuilder().setName('ADVANTAGE TRUCK CENTER MGMT1').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).buildAndSave();
            tstDealerMgmtAccount1.IsPartner = true;
            update tstDealerMgmtAccount1;
            tstDealerAccount1 = new Vgtna_TestBuilder.AccountBuilder().setName('ADVANTAGE TRUCK CENTER1').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).setDealerCode('786D').buildAndSave();            
            tstDealerAccount1.ParentId = tstDealerMgmtAccount1.Id;
            tstDealerAccount1.IsPartner = true;
            update tstDealerAccount1;
        } 
        tstDealerAccount.IsPartner = true;
        system.debug('*** Account: '+tstDealerAccount1);
        update tstDealerAccount1;
        
        Group g1 = new Group(Name ='786D - Managers', DeveloperName = 'X786D_Managers', Type= 'Regular');
        insert g1;
        
        AccountContactRelation acr2 = new AccountContactRelation(accountid= tstDealerAccount1.id,
                                                                 contactid = tstContact.id,
                                                                 Roles = 'Sales Rep');

        System.RunAs(runAsUsr){
            insert acr2;
            delete acr2;
        }
    }
}