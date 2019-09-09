({
	doInit : function(component, event, helper) {
        //alert('accId: '+getUrlParameter('accId'));
        helper.getURLParameter(component,'accId');
       
                $A.createComponent("c:Vgtna_Ltng_AssignedSalesRep", { 
                    "recordId": component.get("v.accId"),
                    "showViewAll": false,
                    "showCheckBox": false
                    
                }, function(newCmp) {
                    if (component.isValid()) {
                        var body = component.get("v.body");
                            body.push(newCmp);
                        component.set("v.body", body);
                    }
                });
            }
        
})