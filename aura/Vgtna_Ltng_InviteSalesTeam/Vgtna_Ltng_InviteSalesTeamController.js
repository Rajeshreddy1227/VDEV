({
	doInit : function(component, event, helper) {
		var oppId= component.get("v.recordId");
        var action = component.get("c.updateInviteSalesTeam");
                action.setParams({
                    "OppId": oppId
                });
        action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                                    
                        window.location.reload(); 
                       /** var navEvt = $A.get("e.force:navigateToSObject");
                              
                                navEvt.setParams({                    
                                  "recordId": oppId
                                  //"slideDevName": "Detail"
                                });
                                navEvt.fire();**/
                        
                    }
                });
        $A.enqueueAction(action); 
	}
                                  
})