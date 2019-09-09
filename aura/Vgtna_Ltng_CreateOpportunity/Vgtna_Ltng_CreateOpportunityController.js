({
	createRecord : function (component, event, helper) {
        var rtDet = document.querySelector('input[name="recordTypeRadio"]:checked');
        if(rtDet != null) {
            var customerRecTypeId = component.get("v.recordTypeId"); 
           // var currentAccntId = component.get("v.accountRecordId");
            var currentAccntId = component.get("v.recordId");
            console.log('create record, recordTypeId ' + currentAccntId)
            if(rtDet.id != customerRecTypeId)
           	{
                component.set("v.isOpen", false);
                document.getElementById("newClientSectionId").style.display = "none" ;
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    'entityApiName': "Opportunity",
                    'recordTypeId':rtDet.id,
                    'defaultFieldValues': {  "AccountId":currentAccntId}
                
                });
                // hide below modal.
                $A.get("e.force:closeQuickAction").fire();
            	createRecordEvent.fire();
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
        component.set("v.isOpen", true);
        document.getElementById("newClientSectionId").style.display = "block";
        
    },
    /*
    hideModal : function(component,event, helper){
        document.getElementById("newClientSectionId").style.display = "none" ;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/001/o"
         });
        urlEvent.fire();
    },
    */
    
 // this function is used to close the modal window and redirect to object or community home on cancel
    hideModal : function(component,event, helper){
		component.set("v.isOpen", false);
		// hide below modal.
                $A.get("e.force:closeQuickAction").fire();
        /**
        var action = component.get("c.isCommunity");
        var accountId = component.get("v.recordId");
        console.log('account id '+accountId);

        action.setCallback(this, function(response) {
	        
            var isCommunity = response.getReturnValue(); // do any operation needed here
            if(!isCommunity)
            {

                document.getElementById("newClientSectionId").style.display = "none" ;
                // hide below modal.
                $A.get("e.force:closeQuickAction").fire();
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": "/001/o"
                 }); 
                urlEvent.fire();
            }
            else
            {
                console.log('in Community, hiding modal');
                // hide below modal.
                $A.get("e.force:closeQuickAction").fire();
               
            }
      
           // urlEvent.fire();
		
            
        });
        $A.enqueueAction(action);
**/
            
    },   
    doInit : function(component, event, helper) {  

     // Get the account ID currently on the page
	//	var action2 = component.get("c.getAccount");
         // Hack to get the Account ID, i.e. /s/account/0013B00000WKwphQAD/new-account-in-sf
         /*
        var currentLocation = new URL(window.location.href);
        var accountId = currentLocation.pathname.replace('/s/account/','');
        accountId = accountId.substring(0, accountId.indexOf('/'));;
       component.set("v.accountRecordId", accountId);
       
        var accountId = component.get("v.accountRecordId");
        */
        var accountId = component.get("v.recordId");
        var curPage = component.get("v.pageReference");
        // get the brand for the current user, that's what we'll display
        var action = component.get("c.fetchUser");
        var storeResponse;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
              storeResponse = response.getReturnValue();
               // set current user information on brand attribute
                component.set("v.user", storeResponse);
                helper.RecordTypeSelectorController(component, storeResponse);
                
            }
            else if (state === "INCOMPLETE") {
                console.log("Error, incomplete callback");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
 

    }
    
})