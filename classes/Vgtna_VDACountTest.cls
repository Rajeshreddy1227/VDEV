@isTest
private class Vgtna_VDACountTest {
    @testSetup 
    static void setup() 
	{
        List<Asset> assets = new List<Asset>();
        Account tstCustAccount = new Vgtna_TestBuilder.AccountBuilder().setName('VDATEST').setRecordType(vgtna_Constants.ACCOUNT_CUSTOMER_RECORDTYPE).setPartyId().setBillingCountryCode('US').setBillingPostalCode('561832323').buildAndSave();

        for(Account account : [select Id from account])
        {
            for (Integer i=0;i<10;i++) 
			{
				assets.add(new Asset(Name='MVIN'+account.id, Brand__c = 'Mack', PurchaseDate = system.today(), accountId=account.Id));
				assets.add(new Asset(Name='VVIN'+account.id, Brand__c = 'Volvo', PurchaseDate = system.today(), accountId=account.Id));
			}
        }
        insert assets;
    }
    static testmethod void test() {        
        Test.startTest();
        Vgtna_VDACount uca = new Vgtna_VDACount();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(10, [select count() from Asset where Brand__c = 'Mack' and AccountId IN (Select Id from Account Where NAME LIKE 'VDATEST')]);
        System.assertEquals(10, [select count() from Asset where Brand__c = 'Volvo' and AccountId IN (Select Id from Account Where NAME LIKE 'VDATEST')]);
    }
    
}