({
	init : function(component, event, helper) {
        console.log('Inside reroute controller');
        var device = $A.get("$Browser.formFactor");
        if(device == "DESKTOP")
        component.set("v.browser",true);
        else
            component.set("v.browser",false);
        console.log("Device" + $A.get("$Browser.formFactor"));
        helper.rerouteAccount(component,event,helper);
	},
 /*  GoMobile: function(component, event, helper) {
       // helper.rerouteAccount(component);
       console.log("Inside GoMobile"+component.get("v.SurvivorId"));
    var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      "recordId": component.get("v.SurvivorId"),
      "slideDevName": "detail"
    });
        console.log("after");
    navEvt.fire();
	}, */
    
    GoMobile : function (component, event, helper) {
  sforce.one.navigateToSObject(component.get("v.SurvivorId"), 'detail');
},
    
   Go: function(component) {
        
        var navLink = component.find("navLink");
        var pageRef = {
            "type": 'standard__recordPage',
            "attributes": {
                "actionName": "view",
                "objectApiName": "Account",
                "recordId" : component.get("v.SurvivorId")
            }
        };
        console.log("Inside GO" +component.get("v.SurvivorId"));
        navLink.navigate(pageRef, true);
    }
})