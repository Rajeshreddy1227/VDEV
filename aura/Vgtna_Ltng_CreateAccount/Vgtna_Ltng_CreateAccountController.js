({
	createRecord : function (component, event, helper) {
        var rtDet = document.querySelector('input[name="recordTypeRadio"]:checked');
        
        if(rtDet != null) {
            
            var customerRecTypeId = component.get("v.recordTypeId");           
            if(rtDet.id != customerRecTypeId)
           	{
                document.getElementById("newClientSectionId").style.display = "none" ;
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    "entityApiName": "Account",
                    "recordTypeId":rtDet.id
                });
            	createRecordEvent.fire();
           	}
            else
            {
               /** var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": "/001/o"
                 });
                urlEvent.fire();**/
                var evt = $A.get("e.force:navigateToComponent");
                console.log('evt'+evt);
                evt.setParams({
                    componentDef: "c:Vgtna_CustomerAccountForm",
                    componentAttributes :{
                   	 recType: customerRecTypeId
                	}
                });
                
                evt.fire();
            }
            
        }   
        
        else
        {            
            var errorLabel = $A.get("$Label.c.Vgtna_CDB_RT_Error");			
            component.set("v.error", errorLabel);
            component.find("outputTextId").set("v.class", "textClass");
        }
    },
    
    showModal : function(component, event, helper) {
        document.getElementById("newClientSectionId").style.display = "block";
        
    },
    
    hideModal : function(component,event, helper){
        document.getElementById("newClientSectionId").style.display = "none" ;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/001/o"
         });
        urlEvent.fire();
    },
    
    doInit : function(component, event, helper) {  
        //document.getElementById("newClientSectionId").style.display = "block";
        //helper.RecordTypeSelectorController(component); 
        helper.CustomerRecordTypeIdController(component);
        helper.RecordTypeSelectorController(component); 
        
    } 
})