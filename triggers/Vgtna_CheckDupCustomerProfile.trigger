trigger Vgtna_CheckDupCustomerProfile on Customer_Profile__c (before insert) {
 for(Customer_Profile__c cp:Trigger.new)
        {
            List<Customer_Profile__c> custPro=[select ID from Customer_Profile__c where Customer_Account__c=:cp.Customer_Account__c and Dealer_Account__c=:cp.Dealer_Account__c];
            if(custPro.size()>0)
            {
                cp.adderror('A Customer Profile has already been created for this account - a duplicate profile cannot be created.');
            }
        }
}