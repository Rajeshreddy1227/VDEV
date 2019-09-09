({
	doInit : function(component, event, helper) {
	var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
               // set current user information on userInfo attribute
                component.set("v.userInfo", storeResponse);
                var dealerBrand = component.get("v.userInfo.Dealer_Brand__c");
                
                if(dealerBrand == "Volvo")
                {
                    component.set("v.toggleValue", false);
                }
                if(dealerBrand == "Mack")
                {
                    component.set("v.toggleValue", true);
                }
                
                
        
             }
        });
        $A.enqueueAction(action);
        
        // fetching ACRs
   
       $A.enqueueAction(component.get('c.getACR'));
    },
    changeBrand : function(component, event, helper){
        var currentLocation = window.location.href;
        
        //alert(currentLocation);
        if(currentLocation.includes("/detail/006") || currentLocation.includes("/opportunity/006") || currentLocation.includes("/detail/001") || currentLocation.includes("/account/001") || currentLocation.includes("/lead/00Q") || currentLocation.includes("/detail/00Q")||currentLocation.includes("/detail/003") ||currentLocation.includes("/contact/003"))
        {
           	var staticLabelToggleMsg = $A.get("$Label.c.Vgtna_Toggle_Validation_Message");
            alert(staticLabelToggleMsg);
            var toggleValue = component.get("v.toggleValue");
            if(toggleValue == true)
                {
                    component.set("v.toggleValue", false);
                }
                else
                {
                    component.set("v.toggleValue", true);
                }
        }
        
        else
        {
            
            var usid = component.get("v.userInfo.Id");
                var toggleValue = component.get("v.toggleValue");
                var brand;
                if(toggleValue == true)
                {
                    brand = 'Mack';
                }
                else
                {
                    brand = 'Volvo';
                }
                //alert("Toggle says: "+component.get("v.toggleValue")+" for "+usid);
                var action = component.get("c.updateUserBrand");
                action.setParams({
                    "userid": usid,
                    "brand": brand
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                       // alert("Please close this pop-up and refresh the community page to see changes.");
                        //alert("Page location is: "+window.location.href);             
                        window.location.reload();          
                    }
                });
                $A.enqueueAction(action);
        }
        
    },
    getACR : function(component, event, helper) {
      
		var action = component.get("c.fetchACR");     	 
        action.setCallback(this, function(response) {
            var state = response.getState();
           
            if (state === "SUCCESS")
            {
               //alert("Res :"+JSON.stringify(response.getReturnValue()));
               var userdealerBrand = component.get("v.userInfo.Dealer_Brand__c");
                // alert("userdealerBrand: "+userdealerBrand);
                var ACRResponse = response.getReturnValue();
                
              //  alert("ACRResponse :"+JSON.stringify(ACRResponse));
                component.set("v.acrInfo", ACRResponse); 
               // component.set("v.acrInfo", newlst);
               // var r = component.get("v.acrInfo");
                 //alert("r :"+JSON.stringify(r));       
            }
        });
        $A.enqueueAction(action);
    },
    updateDealerCode : function(component, event, helper){
        var selectedDealerCode = component.get("v.selectedACR");        
        var action = component.get("c.updateUserDealerCode");
                action.setParams({
                    "dealerCode": selectedDealerCode
                });
         action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                                    
                        window.location.reload(); 
                        
                    }
                });
            $A.enqueueAction(action);
    }
})