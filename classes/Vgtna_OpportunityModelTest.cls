@isTest
public class Vgtna_OpportunityModelTest {
    
    static testMethod void testInviteSalesTeam() 
    {
        
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        User SystemAccountOwner = new User();
        User testPartnerUser = new User();
        User tstDSMUser = new User();
        User tstVolvoRFMUser = new User();
        User tstMackRFMUser = new User();
        
        
        System.RunAs(runAsUsr){
            // Create a System User to own the customer and partner accounts
            User SystemAcctOwner = new Vgtna_TestBuilder.UserBuilder().setlastName('Account Owner').setEmail('tstUser@Email.com').setProfileId(vgtna_Constants.INTEGRATION_USER_PROFILE).buildAndSave();
            SystemAcctOwner.UserRoleId=[Select Id From UserRole Where DeveloperName=:vgtna_Constants.SYSTEM_PARTNER_ROLE Limit 1].Id;
            update SystemAcctOwner;
            SystemAccountOwner = SystemAcctOwner;
        }
        
        system.debug('**** setup account owner '+SystemAccountOwner);
        
        // Create the Dealer Account
        Account tstDealerAccount = new Vgtna_TestBuilder.AccountBuilder().setName('ADVANTAGE TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).setDealerCode('5889D').buildAndSave();
        tstDealerAccount.IsPartner = true;
        // Set owner to System User
        tstDealerAccount.OwnerId=SystemAccountOwner.Id;
        system.debug('*** Account: '+tstDealerAccount);
        update tstDealerAccount;
        
        // Create the Contact that will be converted into the Partner User
        Contact tstContact = new Vgtna_TestBuilder.ContactBuilder().setLastName('Partner User').setFirstName('Test').setEmail('test@aol.com').setAccount(tstDealerAccount).buildAndSave();
        system.debug('*** contact '+tstContact);
        
        // Create the Partner User
        System.RunAs(runAsUsr){
            
            User tstUser = new Vgtna_TestBuilder.UserBuilder().setContact(tstContact).setlastName('Partner User').setEmail(tstContact.Email).setProfileId(vgtna_Constants.DEALER_USER_PROFILE).buildAndSave();
            
            tstUser.IsPortalEnabled=true;
            tstUser.UserRoleId=[Select Id 
                                From UserRole 
                                Where PortalAccountId=:tstDealerAccount.Id 
                                And PortalRole='Manager' Limit 1].Id;
            update tstUser;
            testPartnerUser = tstUser;
        }
        system.debug('*** testPartnerUser '+testPartnerUser+' AND isPartner: '+testPartnerUser.IsPortalEnabled);
        
        // Setup Distric Sales Manager
        System.RunAs(runAsUsr){
            
            User DSMUser = new Vgtna_TestBuilder.UserBuilder().setlastName('DSM User').setEmail(tstContact.Email).setProfileId(vgtna_Constants.MACK_INTERNAL_USER_PROFILE).buildAndSave();
            
            DSMUser.UserRoleId=[Select Id 
                                From UserRole 
                                Where DeveloperName =:vgtna_Constants.MACK_DSM_ROLE Limit 1].Id;
            update DSMUser;
            system.debug('*** DSM user '+DSMUser);
            tstDSMUser = DSMUser;
        }  
        
        // Setup Volvo RFM
        System.RunAs(runAsUsr){
            
            User VolvoRFMUser = new Vgtna_TestBuilder.UserBuilder().setlastName('Volvo RFM User').setEmail(tstContact.Email).setProfileId(vgtna_Constants.INTERNAL_USER_PROFILE).setBrand(vgtna_Constants.VOLVO_BRAND).buildAndSave();
            
            VolvoRFMUser.UserRoleId=[Select Id 
                                From UserRole 
                                Where DeveloperName =:vgtna_Constants.VOLVO_RFM_ROLE Limit 1].Id;
            update VolvoRFMUser;
            system.debug('*** Volvo RFM user '+VolvoRFMUser);
            tstVolvoRFMUser = VolvoRFMUser;
        }  
        

        // Setup Mack RFM
        System.RunAs(runAsUsr){
            
            User MackRFMUser = new Vgtna_TestBuilder.UserBuilder().setlastName('Volvo Mack User').setEmail(tstContact.Email).setProfileId(vgtna_Constants.INTERNAL_USER_PROFILE).setBrand(vgtna_Constants.MACK_BRAND).buildAndSave();
            
            MackRFMUser.UserRoleId=[Select Id 
                                From UserRole 
                                Where DeveloperName =:vgtna_Constants.MACK_RFM_ROLE Limit 1].Id;
            update MackRFMUser;
            system.debug('*** Volvo RFM user '+MackRFMUser);
            tstMackRFMUser = MackRFMUser;
        }  

        
        // Setup the Customer Account 
        Account tstCustAccount = new Vgtna_TestBuilder.AccountBuilder().setName('FedExTest').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().buildAndSave();
        tstCustAccount.OwnerId=SystemAccountOwner.Id;
        update tstCustAccount;
       
        //Setup the Account Team on the Partner Record
        AccountTeamMember acctTeamMember = new AccountTeamMember(
            AccountAccessLevel='Read',
            AccountId=tstDealerAccount.Id,
            CaseAccessLevel='None',
            ContactAccessLevel='None',
            OpportunityAccessLevel='None',
            TeamMemberRole='District Sales Manager',
            UserId=tstDSMUser.Id
        );
        insert acctTeamMember;
        
        AccountTeamMember acctTeamMemberCustomerVolvo = new AccountTeamMember(
            AccountAccessLevel='Read',
            AccountId=tstCustAccount.Id,
            CaseAccessLevel='None',
            ContactAccessLevel='None',
            OpportunityAccessLevel='None',
            TeamMemberRole='Regional Fleet Manager',
            UserId=tstVolvoRFMUser.Id
        );
        insert acctTeamMemberCustomerVolvo;
        
        AccountTeamMember acctTeamMemberCustomerMack = new AccountTeamMember(
            AccountAccessLevel='Read',
            AccountId=tstCustAccount.Id,
            CaseAccessLevel='None',
            ContactAccessLevel='None',
            OpportunityAccessLevel='None',
            TeamMemberRole='Regional Fleet Manager',
            UserId=tstMackRFMUser.Id
        );
        insert acctTeamMemberCustomerMack;

        // Setup an Opportunity on the Customer Account
        Opportunity oppty = new Opportunity(
            AccountId=tstCustAccount.Id,
            CloseDate=Date.Today().addDays(7),
            Desired_Delivery_Date__c=Date.Today().addDays(7),
            //Estimated_Quantity__c=2,
            Brand__c = vgtna_Constants.VOLVO_BRAND,
            Name='TestTheOppty',
            OwnerId=testPartnerUser.Id,
            StageName='Identify',
            Partner_Account__c= tstDealerAccount.Id,
            Invite_Sales_Team__c=false
        );
        insert oppty;
        System.debug('+++++++++++++++ Oppty inserted for test '+oppty);
        
        // End of Setup, start test
        test.startTest();
        /**oppty.Invite_Sales_Team__c=true;
        update oppty;**/
        Vgtna_InviteSalesTeamController.updateInviteSalesTeam(oppty.Id);
        
        oppty.Invite_Sales_Team__c=false;
        update oppty;
        oppty.Invite_Sales_Team__c=true;
        update oppty;
        List<OpportunityTeamMember> opptyTeamMembers = [Select Id, Name 
                                                        From OpportunityTeamMember 
                                                        Where OpportunityId =:oppty.Id];
        System.assertEquals(2, opptyTeamMembers.size());
        test.stopTest();
        
    }
    
    static testMethod void testOpportunityShare() 
    {
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        User SystemOpptyOwner = new User();
        List<Group> groups = new List<Group>();
        
        System.RunAs(runAsUsr)
        {
            SystemOpptyOwner = new Vgtna_TestBuilder.UserBuilder().setlastName('Test ACR Process Account Owner').setEmail('tstacrpUser@Email.com.invalid').setProfileId(vgtna_Constants.INTERNAL_USER_PROFILE).buildAndSave();
            SystemOpptyOwner.UserRoleId=[Select Id From UserRole Where DeveloperName=:vgtna_Constants.SYSTEM_PARTNER_ROLE Limit 1].Id; 
            
            // Create the Dealer Accounts
            Account tstDealerAccount1 = new Vgtna_TestBuilder.AccountBuilder().setName('Test Oppty PROCESS TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).setDealerCode('401K').buildAndSave();
            tstDealerAccount1.IsPartner = true;
            Account tstDealerAccount2 = new Vgtna_TestBuilder.AccountBuilder().setName('Test Oppty PROCESS TRUCK CENTER').setRecordType(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE).setDealerCode('A296').buildAndSave();
            tstDealerAccount2.IsPartner = true;
            
            // Create Groups
            Group g1 = new Group(Name ='401K - Managers', DeveloperName = 'X401K_Managers', Type= 'Regular');
            Group g2 = new Group(Name ='A296 - Managers', DeveloperName = 'XA296_Managers', Type= 'Regular');
            groups.add(g1);
            groups.add(g2);   
            insert groups;
            
            // Create customer account
            Account tstCustAccount = new Vgtna_TestBuilder.AccountBuilder().setName('FedExTest').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().buildAndSave();
            
            // Create opportunity
            Opportunity oppty = new Opportunity(
                AccountId=tstCustAccount.Id,
                CloseDate=Date.Today().addDays(7),
                Desired_Delivery_Date__c=Date.Today().addDays(7),
                //Estimated_Quantity__c=2,
                Name='TestTheOppty',
                Partner_Account__c = tstDealerAccount1.id,
                //OwnerId=testPartnerUser.Id,
                StageName='Identify',
                Invite_Sales_Team__c=false
            );
            insert oppty;
            
            oppty.OwnerId= SystemOpptyOwner.id;
            update oppty;
            
            oppty.Partner_Account__c = tstDealerAccount2.id;
            update oppty;
            
            // Test batch class- Vgtna_batchAssignTerrToOppty for territory assignment
            // Create two territories
            Test.startTest();
            
            Territory2Type oType = new Territory2Type();
            List<Territory2> terrList = new List<Territory2>();
            Territory2Model terrModel = new Territory2Model();
            terrModel .DeveloperName='ModelName'; // required field
            terrModel.Name = 'Name'; // required field
            //terrModel.State='Active';
            insert terrModel ;
            
            
            List<Territory2Type> terrType =[Select id from Territory2Type where developername='Area_of_Responsibility' limit 1];
            
            Territory2 ter401K= new Territory2(Name='401K',
                                               DeveloperName= 'X401K',
                                               Dealer_Code__c = '401K',
                                               OpportunityAccessLevel='None',
                                               //ParentTerritory2Id=oNode.Id,
                                               Territory2ModelId=terrModel.Id,
                                              Territory2TypeId=terrType[0].Id);
            
            Territory2 terA296 = new Territory2(Name='A296',
                                                DeveloperName= 'A296',
                                                Dealer_Code__c = 'A296',
                                              // ParentTerritory2Id=oNode.Id,
                                               Territory2ModelId=terrModel.Id,
                                               Territory2TypeId=terrType[0].Id);
            
            terrList.add(ter401K);
            terrList.add(terA296);
            insert terrList;
            system.debug('terrList test-->'+terrList);
            Vgtna_batchAssignTerrToOppty uca = new Vgtna_batchAssignTerrToOppty();
            Id batchId = Database.executeBatch(uca,100);
            
           
           oppty.Partner_Account__c = null;
            update oppty;
            Vgtna_batchAssignTerrToOppty uca1 = new Vgtna_batchAssignTerrToOppty();
            Id batchId1 = Database.executeBatch(uca1,100);
            
            oppty.Partner_Account__c = tstDealerAccount2.id;
            update oppty;
           /** Vgtna_batchAssignTerrToOppty uca2 = new Vgtna_batchAssignTerrToOppty();
            Id batchId2 = Database.executeBatch(uca2,100);**/
            
            Vgtna_batchAssignTerrToOpptySchedule uca2 = new Vgtna_batchAssignTerrToOpptySchedule();
            String cronStr = '0 0 13 * * ?';
            System.schedule('Dummy Opportunity Territory Assignment Job',cronStr,uca2);
             Test.stopTest();
        }
    }
    
}