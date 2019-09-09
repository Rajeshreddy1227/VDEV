({
	helperUsers : function(component, event, helper) {
		var action = component.get("c.getDealerUsers");
        action.setParams({
            "optyId" : component.get("v.recordId")
         });
            action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                //  component.set("v.ACR", response.getReturnValue());
                var retVal = response.getReturnValue();
                var options=[{id: 'None', label:'None', selected: true}];              
                for(var i=0; i<response.getReturnValue().length; i+=1) {
                           // alert('retvalu: '+retVal[i].Id);
                            options.push({id: retVal[i].Id, label: retVal[i].FirstName+' '+retVal[i].LastName});
                        }
                component.set("v.srOptions", options);
            }
        });
        $A.enqueueAction(action);
	},
    assignUser : function(component, event, helper) {
        var actionAssign = component.get("c.changeOwner");
        actionAssign.setParams({"userId" : component.get("v.selectedRep"),
                              "optyId" : component.get("v.recordId")
                              });
            actionAssign.setCallback(this, function(response) {            
        var state = response.getState();
            if(state === 'SUCCESS'){
                 console.log('State'+state);
                alert('inside');
                var dataMap = response.getReturnValue();
                var toastEvent = $A.get('e.force:showToast');
                    if(dataMap == 'Success') {  
                        console.log('inside'+dataMap);
                    toastEvent.setParams({
                        'title': 'Success!',
                        'type': 'success',
                        'mode': 'dismissable',
                       'message' : 'Changed Owner Successfully!.' 
                    });
                        toastEvent.fire();
                      
                    }
                    else if(dataMap === 'Exists') {
                        toastEvent.setParams({
                            'title': 'User already Owner!',
                            'type': 'warning',
                            'mode': 'dismissable',
                            'message' : 'Already Owner!.' 
                    });
                    toastEvent.fire(); 
                 
                  }                
            }
            else {
                alert('Error in getting data');
            }   
        }); 
        
		$A.enqueueAction(actionAssign);
         $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
         
    }
})