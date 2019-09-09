@isTest
public class recordtypeControllerTest {

	static testMethod void testRecordTypeController()
    {
        recordtypeController rtc = new recordtypeController();
        List<String> ret = recordtypeController.fetchRecordTypeValues();
        Id rt = recordtypeController.getRecTypeId(vgtna_Constants.ACCOUNT_DEALER_RECORDTYPE);
    }
}