@isTest
public class Vgtna_AccountModelTest {
    static testMethod void ProcessAccountTest()
    {
        User runAsUsr = [SELECT Id FROM User WHERE profile.Name='System Administrator' and isActive=true and UserRoleId!=null Limit 1];
        User SystemAccountOwner = new User();

        System.RunAs(runAsUsr){
            // Create a System User to own the customer and partner accounts
            User SystemAcctOwner = new Vgtna_TestBuilder.UserBuilder().setlastName('Account Owner').setEmail('tstUser@Email.com.invalid').setProfileId('System Integrator').buildAndSave();
            SystemAcctOwner.UserRoleId=[Select Id From UserRole Where name='System Partner Role' Limit 1].Id;
            update SystemAcctOwner;
            SystemAccountOwner = SystemAcctOwner;
        }

        
        // Setup Territory2 Elements
        //   If you make sure these Territory2.delaer_code__c are in place, no need to create them with code below
        // 
        //   select id, name from territory2 
        //      where dealer_code__c in ('5571D', 'F243', 'N971', '2747K')
        /*  BEGIN TERRITORY SETUP
        
        List<Territory2> t2List = new List<Territory2>();

        Territory2 oNode = [Select Id, Name, Territory2TypeId, Territory2ModelId 
                 From Territory2 
                 Where DeveloperName = : vgtna_Constants.AOR_TERRITORY 
                 And Territory2Model.State='Active' Limit 1 ];
        System.debug('Territory Node: '+oNode.Name);

        t2List.add(new Territory2(
            AccountAccessLevel='Read',
            CaseAccessLevel='None',
            ContactAccessLevel='None',
            Dealer_Code__c = '5571D',
            DeveloperName='X5571D_AOR_test',
            Name='5571D- AOR',
            OpportunityAccessLevel='None',
            ParentTerritory2Id=oNode.Id,
            Territory2ModelId=oNode.Territory2ModelId,
            Territory2TypeId=oNode.Territory2TypeId
        ));         

        t2List.add(new Territory2(
            AccountAccessLevel='Read',
            CaseAccessLevel='None',
            ContactAccessLevel='None',
            Dealer_Code__c = 'F243',
            DeveloperName='F243_AOR_test',
            Name='F243- AOR',
            OpportunityAccessLevel='None',
            ParentTerritory2Id=oNode.Id,
            Territory2ModelId=oNode.Territory2ModelId,
            Territory2TypeId=oNode.Territory2TypeId
        ));         
        t2List.add(new Territory2(
            AccountAccessLevel='Read',
            CaseAccessLevel='None',
            ContactAccessLevel='None',
            Dealer_Code__c = 'N971',
            DeveloperName='N971_AOR_test',
            Name='N971- AOR',
            OpportunityAccessLevel='None',
            ParentTerritory2Id=oNode.Id,
            Territory2ModelId=oNode.Territory2ModelId,
            Territory2TypeId=oNode.Territory2TypeId
        ));         
        t2List.add(new Territory2(
            AccountAccessLevel='Read',
            CaseAccessLevel='None',
            ContactAccessLevel='None',
            Dealer_Code__c = '2747K',
            DeveloperName='X2747K_AOR_test',
            Name='2747K- AOR',
            OpportunityAccessLevel='None',
            ParentTerritory2Id=oNode.Id,
            Territory2ModelId=oNode.Territory2ModelId,
            Territory2TypeId=oNode.Territory2TypeId
        ));         
        
        System.RunAs(runAsUsr){

            insert t2List;
        }    
        */  // END TERRITORY SETUP
        
        system.debug('**** setup account owner '+SystemAccountOwner);

        // Setup AOR data
        
        List<AOR__c> aor = new List<AOR__c>();
        
        aor.add(New AOR__c(
            Brand__c=vgtna_Constants.VOLVO_BRAND,
            Country__c='US',
            Dealer_Code__c = '5571D',
            Postal_Code__c='56183'
        ));
        
        aor.add(New AOR__c(
            Brand__c=vgtna_Constants.MACK_BRAND,
            Country__c='US',
            Dealer_Code__c = 'F243',
            Postal_Code__c='79230'
        ));
        
        aor.add(New AOR__c(
            Brand__c=vgtna_Constants.MACK_BRAND,
            Country__c='CA',
            Dealer_Code__c = 'N971',
            Postal_Code__c='S0H',
            City__c='VICEROY',
            State_Province__c = 'AB'
        ));

        aor.add(New AOR__c(
            Brand__c=vgtna_Constants.VOLVO_BRAND,
            Country__c='CA',
            Dealer_Code__c = '2747K',
            Postal_Code__c='TOG',
            City__c='CLYDE',
            State_Province__c = 'SK'
        ));

        insert aor;
        System.debug('**** aor for test :'+aor);
        Set<Id> acctIds = new Set<Id>();
        
        // Setup the Customer Accounts
        Account tstCustAccount = new Vgtna_TestBuilder.AccountBuilder().setName('FedExTest').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().setBillingCountryCode('US').setBillingPostalCode('561832323').buildAndSave();
        acctIds.add(tstCustAccount.Id);
        Account tstCustAccount1 = new Vgtna_TestBuilder.AccountBuilder().setName('FedExTest1').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().setBillingCountryCode('US').setBillingPostalCode('79230').buildAndSave();
        acctIds.add(tstCustAccount1.Id);

        Account tstCustAccount2 = new Vgtna_TestBuilder.AccountBuilder().setName('FedExTest2').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().setBillingCountryCode('CA').setBillingPostalCode('S0HYTR').setBillingCity('VICEROY').setBillingStateCode('AB').buildAndSave();
        acctIds.add(tstCustAccount2.Id);

        Account tstCustAccount3 = new Vgtna_TestBuilder.AccountBuilder().setName('FedExTest3').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().setBillingCountryCode('CA').setBillingPostalCode('TOG').setBillingCity('CLYDE').setBillingStateCode('SK').buildAndSave();
        acctIds.add(tstCustAccount3.Id);

        

        List<ObjectTerritory2Association> testRes = [Select Id 
                                                     From ObjectTerritory2Association
                                                     Where ObjectId  In :acctIds];
        System.debug(testRes.size());
        System.assertEquals(4, testRes.size());
        
    }
    static testMethod void ProcessAccountAorRegionDlrTest()
    {
        //Setup the AOR
        List<AOR__c> aor = new List<AOR__c>();        
        aor.add(New AOR__c(
            Brand__c=vgtna_Constants.VOLVO_BRAND,
            Country__c='US',
            Dealer_Code__c = '5453D',
            Postal_Code__c='27409',
            Region__c = 'Southeast',
            County__c ='GUILFORD'
        ));
        
        aor.add(New AOR__c(
            Brand__c=vgtna_Constants.MACK_BRAND,
            Country__c='US',
            Dealer_Code__c = 'C551',
            Postal_Code__c='27409',
            Region__c = 'Southeast',
            County__c ='GUILFORD'
        ));
        
        insert aor;
        System.debug('**** aor for test :'+aor);
        
        // Setup the Customer Accounts
        Account tstCustAccount4 = new Vgtna_TestBuilder.AccountBuilder().setName('Embassy Suites by Hilton').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().setBillingCity('Greensboro').setBillingCountry('United States').setBillingCountryCode('US').setBillingPostalCode('274091234').buildAndSave();    
        Account acc = [Select Volvo_Dealer_Code__c, Mack_Dealer_Code__c, Region__c, Primary_County__c from Account where Id=:tstCustAccount4.Id];
                
        System.debug('Account VolvoDealerCode-> '+ acc.Volvo_Dealer_Code__c + 'Account MackDealerCode-> '+ acc.Mack_Dealer_Code__c + 'Account County-> '+ acc.Primary_County__c);
        System.assertEquals('5453D', acc.Volvo_Dealer_Code__c);
        System.assertEquals('C551', acc.Mack_Dealer_Code__c);
        System.assertEquals('GUILFORD', acc.Primary_County__c);
        System.assertEquals('Southeast', acc.Region__c);
    }
}