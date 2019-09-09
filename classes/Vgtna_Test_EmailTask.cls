@isTest
public class Vgtna_Test_EmailTask {
    static testMethod void sendEmailTaskMethod() {
        account a = new account();
        a.name = 'test name';
        a.party_id__c = '344455ff';
        insert a;
        
        Vgtna_EmailTask.sendMailMethod('Testemail@gmail.com','test subject','test body',a.Id);
    
    
    
    }
}