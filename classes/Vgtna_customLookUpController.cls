public class Vgtna_customLookUpController {
	@AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name';
        if(ObjectName == 'user') {
            sQuery += ', Email';
        }
            sQuery += ' from '+ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        system.debug('squery: '+sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}