({
	init: function(component, event, helper) {
    //var recId = "0012200000HT1G5AAL";
    window.history.back();
      console.log("recordid: "+component.get("v.recordId"));
      var action = component.get('c.redirectToUsr');
            action.setParams({"caId": component.get("v.recordId")
                             });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    if(response.getReturnValue() != null) {
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                          "recordId": response.getReturnValue(),
                          "slideDevName": "detail"
                        });
                              navEvt.fire();
                    }
                }
            });
            $A.enqueueAction(action);
    },
})