({
	doInit : function(component, event, helper) {
       // alert("hello");
		var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
           // alert(state);
            if (state === "SUCCESS") {
                
                
                var storeResponse = response.getReturnValue();
                // set current user information on userInfo attribute
                component.set("v.userInfo", storeResponse);
                
                var isCommunityUser = component.get("v.userInfo.IsPortalEnabled");
                //alert("isCommunityUser : "+isCommunityUser);
                component.set("v.isPortal",isCommunityUser);
                 
            }
        });
        $A.enqueueAction(action);
        helper.RecordTypeSelectorController(component); 
	},
    createRecord : function (component, event, helper) {
        var rtDet = document.querySelector('input[name="recordTypeRadio"]:checked');
        
        if(rtDet != null) {
        //document.getElementById("newClientSectionId").style.display = "none" ;
        component.set("v.isOpen", false);
            document.getElementById("newClientSectionId").style.display = "none";
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    "entityApiName": "Lead",
                    "recordTypeId":rtDet.id                   
                });
            	
            createRecordEvent.fire();
  
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
    
    hideModal : function(component,event, helper){
        component.set("v.isOpen", false);
        document.getElementById("newClientSectionId").style.display = "none" ;
        var isCommunityUser = component.get("v.isPortal");  
         //alert(isCommunityUser);
        //var isCommunityUser = component.get("v.userInfo.IsPortalEnabled");
        if(isCommunityUser == false)
        {
           // alert("hi");
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": "/00Q/o"
             });
            urlEvent.fire();
        }
        else
        {
            var staticLabelCommURL = $A.get("$Label.c.Vgtna_Dealer_Community_URL");
                var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                  "url": staticLabelCommURL
                 });
            urlEvent.fire();
        }
       
    }
})