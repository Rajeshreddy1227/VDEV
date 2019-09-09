public without sharing class Vgtna_GenericDataTableCtrl {
    /*
    Method Name : getAccRecords
    Purpose     : To get the wrapper of Columns and Headers
    */
    @AuraEnabled
    public static DataTableResponse getsObjectRecords(String strObjectName, String strFieldSetName, String dealerCode, String dealerBrand, String accountField,
                                                  Boolean newButton, Boolean editButton, Boolean deleteButton, Boolean viewAllButton, 
                                                  Integer recordsDisplayed, String iconName, String recId){                
        Id loggedUserId = userInfo.getUserId();
        Map<Id, User> uMap = new Map<Id, User>([SELECT Id, Dealer_Code__c, Dealer_Brand__c, ContactId, Primary_Dealer_Code__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()]);
        String dCode = uMap.get(loggedUserId).Dealer_Code__c;
        String dBrand = uMap.get(loggedUserId).Dealer_Brand__c;
        
		//added by SN
		List<Profile> lstProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String sProflieName = lstProfile[0].Name;
        //added by SN
                                                      
        //Get the fields from FieldSet
        Schema.SObjectType SObjectTypeObj = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();            
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(strFieldSetName);
                                                              
        //To hold the table hearders 
        List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
        
        //Field to be queried - fetched from fieldset
        List<String> lstFieldsToQuery = new List<String>();
        
        //The final wrapper response to return to component
        DataTableResponse response = new DataTableResponse();
        system.debug('strFieldSetName: '+strFieldSetName+'====fieldSetObj==='+fieldSetObj);
        for( Schema.FieldSetMember eachFieldSetMember : fieldSetObj.getFields() ){
            String dataType = String.valueOf(eachFieldSetMember.getType()).toLowerCase();
            //This way we can set the type of a column
            //We do not get the exact type from schema object which matches to lightning:datatable component structure
            if(dataType == 'datetime'){
                dataType = 'date';
            }
            if(dataType.equalsIgnoreCase('Reference')) {
                labelName ln = new labelName(String.valueOf(eachFieldSetMember.getFieldPath()).replace('__c','__r.Name'));
                tooltip tt = new tooltip(String.valueOf(eachFieldSetMember.getFieldPath()).replace('__c','__r.Name'));
                typeAttributes refLink = new typeAttributes(ln, '_self', tt, null);
                system.debug('sale rep name: '+String.valueOf(eachFieldSetMember.getFieldPath()).replace('__c','__r.Name'));
                DataTableColumns dcolumns = new DataTableColumns( String.valueOf(eachFieldSetMember.getLabel()) , 
                                                                String.valueOf(eachFieldSetMember.getFieldPath()), 
                                                                'url', refLink );
                system.debug('dcolumns: '+dcolumns);
                lstDataColumns.add(dcolumns);
                lstFieldsToQuery.add(String.valueOf(eachFieldSetMember.getFieldPath()).replace('__c','__r.Name'));
                lstFieldsToQuery.add(String.valueOf(eachFieldSetMember.getFieldPath()));
            }
            if(dataType != 'Reference') {
                //Create a wrapper instance and store label, fieldname and type.
                DataTableColumns datacolumns = new DataTableColumns( String.valueOf(eachFieldSetMember.getLabel()) , 
                                                                    String.valueOf(eachFieldSetMember.getFieldPath()), 
                                                                    String.valueOf(eachFieldSetMember.getType()).toLowerCase(), null );
                lstDataColumns.add(datacolumns);
                lstFieldsToQuery.add(String.valueOf(eachFieldSetMember.getFieldPath()));
            }
            
            //lstFieldsToQuery.add(String.valueOf(eachFieldSetMember.getFieldPath()));
        }
        //To hold the row actions 
        List<rowAction> lstRowActions = new List<rowAction>();                                         
        if(editButton == true) {
            rowAction raEdit = new rowAction('Edit', 'Edit');
            lstRowActions.add(raEdit);
        }
        if(deleteButton == true) {
            rowAction raDelete = new rowAction('Delete', 'Delete');
            lstRowActions.add(raDelete);
        }
        rowAction raView = new rowAction('View', 'View');
        lstRowActions.add(raView);
        if(lstRowActions.size() > 0) {
            typeAttributes dataRowActions = new typeAttributes(null, null, null, lstRowActions);
            system.debug('dataRowActions: '+dataRowActions);
            DataTableColumns rActionColumn = new DataTableColumns(null, null, 'action', dataRowActions);
            system.debug('rActionColumn: '+rActionColumn);
            lstDataColumns.add(rActionColumn);
        }
        
        //Form an SOQL to fetch the data - Set the wrapper instance and return as response
        if(! lstDataColumns.isEmpty()){            
            response.lstDataTableColumns = lstDataColumns;
            String countQuery = 'SELECT COUNT() FROM '+strObjectName;
            String query = 'SELECT Id, ' + String.join(lstFieldsToQuery, ',') + ' FROM '+strObjectName;//+dealerBrand+' =:dBrand';
            if(String.isNotBlank(dealerBrand) || String.isNotBlank(dealerCode) || String.isNotBlank(recId)) {
                query += ' WHERE ';
                countQuery += ' WHERE ';
            }
            if(String.isNotBlank(recId)) {
                query += accountField+' =:recId';
                countQuery += accountField+' =:recId';
            }
            if(uMap.get(loggedUserId).ContactId == null && String.isNotBlank(dealerBrand))
            {
                //added by SN
                if(sProflieName == 'System Administrator')
                {
                    query += ' AND '+dealerBrand+' =:dBrand';
                	countQuery += ' AND '+dealerBrand+' =:dBrand';
                }
            } else if(String.isNotBlank(dealerCode)) {
                query += ' AND '+dealerCode+' =:dCode';
                countQuery += ' AND '+dealerCode+' =:dCode';
            }
            System.debug(query);
            System.debug('countquery: '+countQuery);
            
            if(strObjectName == 'Asset')
            {
                query += ' ORDER BY Retail_Date__c DESC NULLS LAST ';
            }
            
            if(recordsDisplayed != null) {
                query += ' LIMIT '+recordsDisplayed;
            }
            system.debug('dealercode: '+dCode+'--recId--'+recId);
            system.debug('query: '+query);
            response.lstDataTableData = Database.query(query);
            response.totalRecords = database.countQuery(countQuery);
            
        }
        
        return response;
    }
    
    @AuraEnabled
    public static User getLoggedUser() {
        User u = [SELECT Id, Dealer_Code__c, Dealer_Brand__c, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        return u;
    }
    
    @AuraEnabled
    public static String deleteRec(String Id) {
        try {
            Database.delete(Id);
        } catch (exception ex) {
            return 'Exception entered at linenumber '+ ex.getLineNumber() +' in class Vgtna_GenericDataTable with exception message '+ex.getMessage();
        }
        return 'SUCCESS';
    }
    
    //Wrapper class to hold Columns with headers
    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public typeAttributes typeAttributes {get;set;}
        
        //Create and set three variables label, fieldname and type as required by the lightning:datatable
        public DataTableColumns(String label, String fieldName, String type, typeAttributes typeAttributes){
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;  
            this.typeAttributes = typeAttributes;
        }
    }
    
    
    //Wrapper class to hold actions
    public class rowAction {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String name {get;set;}
        
        public rowAction(String label, String name){
            this.label = label;
            this.name = name;          
        }
    }
    
    //Wrapper class to hold label
    public class labelName {
        @AuraEnabled       
        public String fieldName {get;set;}
        public labelName(String fieldName){
            this.fieldName = fieldName;          
        }
    }
    
    //Wrapper class to hold tooltip
    public class tooltip {
        @AuraEnabled       
        public String fieldName {get;set;}
        public tooltip(String fieldName){
            this.fieldName = fieldName;          
        }
    }
    
    public class typeAttributes {
        @AuraEnabled
        public labelName label {get;set;}
        @AuraEnabled       
        public String target {get;set;}
        @AuraEnabled       
        public tooltip tooltip {get;set;}
        @AuraEnabled       
        public List<rowAction> rowActions {get;set;}
        
        public typeAttributes(labelName label, String target, tooltip tooltip, List<rowAction> rowActions){
            this.label = label;
            this.target = target;
            this.tooltip = tooltip;
            this.rowActions = rowActions;    
        }
    }
    
    //Wrapper calss to hold response - This response is used in the lightning:datatable component
    public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumns> lstDataTableColumns {get;set;}
        @AuraEnabled
        public List<sObject> lstDataTableData {get;set;}                
        @AuraEnabled Integer totalRecords {get;set;}
        public DataTableResponse(){
            lstDataTableColumns = new List<DataTableColumns>();
            lstDataTableData = new List<sObject>();
            totalRecords=0;
        }
    }
}