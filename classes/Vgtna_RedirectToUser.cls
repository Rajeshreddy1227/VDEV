public with sharing class Vgtna_RedirectToUser {
	@AuraEnabled
    public static String redirectToUsr(String caId) {
        try {
            Customer_Activity__c ca = [SELECT Id, OwnerId FROM Customer_Activity__c WHERE Id = :caId];
            return ca.OwnerId;
        } catch (exception ex) {
            String msg = 'An exception occured in class Vgtna_RedirectToUser at line number '+ex.getLineNumber()+'with error message '+ex.getMessage();
            System.debug(msg);
        	return null;
        }
    }
}