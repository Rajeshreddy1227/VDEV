({
	init : function(component, event, helper) {
        component.set("v.openModal", true);
		var action = component.get("c.getACHUsers");
           
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var options=[{id: 'None', label:'None', selected: true}];
                    console.log('entered response'+response.getReturnValue());
                    if(response.getReturnValue() != null) {
                        console.log('entered response1'+response.getReturnValue());
                        var retVal = response.getReturnValue();
                        
                        //component.set("v.salesRepsList",response.getReturnValue());
                        for(var i=0; i<retVal.length; i++) {
                           // alert('retvalu: '+retVal[i].Id);
                            options.push({id: retVal[i].Id, label: retVal[i].FirstName+' '+retVal[i].LastName});
                        }
                        component.set("v.srOptions", options);
                    }
                }
            });
        $A.enqueueAction(action);
	},
    
    closeModal : function(component, event, helper) {
        //$A.get("e.force:closeQuickAction").fire();
        component.destroy();
    }, 
    
    assignSR : function(component, event, helper) {
        var sVal = document.getElementById("mySelect");
        //alert('sel value: '+component.get("v.selectedRecs"));
        if(component.get("v.newASR") == true) {
           // alert('entered new asr');
            if(component.get("v.selectAllRecs") == true) {
                var action1 = component.get("c.insertAllASR");
            	action1.setParams({"srId" : component.get("v.selectedRep"),
                              	   "cityFilter" : component.get("v.cityFilter"),
                                   "salesRepFilter" : component.get("v.salesRepFilter"),
                                   "countyFilter" : component.get("v.countyFilter"),
                                   "zipcodeFilter" : component.get("v.zipcodeFilter"),
                                   "accFilter" : component.get("v.AccFilter"),
                                   "allUnassignAcctIds" : component.get("v.allUnassignAcctIds"),
                                   "allTerrAccIds" : component.get("v.allTerrAccIds")
                              });
            } else {
                var action1 = component.get("c.insertASR");
                action1.setParams({"srId" : component.get("v.selectedRep"),
                                  "acctList" : component.get("v.selectedRecs")
                                  });
            }
            action1.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS"){
                    if(response.getReturnValue() === 'SUCCESS') {
                        
                        helper.showNotification(component, 'Success!', 'Selected accounts are assigned to the salesrep', 'success');
                        $A.get("e.force:closeQuickAction").fire();
                        window.location.reload();
                        component.destroy();
                    }
                }
            });
            $A.enqueueAction(action1);
        } else {
            var action2 = component.get("c.ReAssignSalesReps");
            action2.setParams({"srId" : component.get("v.selectedRep"),
                              "asrIds" : component.get("v.selectedRecs"),
                               "cityFilter" : component.get("v.cityFilter"),
                               "salesRepFilter" : component.get("v.salesRepFilter"),
                               "countyFilter" : component.get("v.countyFilter"),
                               "zipcodeFilter" : component.get("v.zipcodeFilter"),
                               "accFilter" : component.get("v.AccFilter"),
                               "selectAllRecs" : component.get("v.selectAllRecs")
                              });
            action2.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS"){
                    if(response.getReturnValue() === 'SUCCESS') {
                        helper.showNotification(component, 'Success!', 'Records have been assigned to selected Sales Rep', 'success');
                        $A.get('e.force:refreshView').fire();
                        //var cmpEvent = component.getEvent("refreshParent");
                        // Get the value from Component and set in Event
                        //cmpEvent.fire();
                        window.location.reload();
                        component.destroy();
                        
                    }
                }
            });
             $A.enqueueAction(action2);
        }
       
        
        
    },
    
    onPicklistChange : function(component, event, helper) {
        alert('p change: '+event.getSource().get("v.value"));
    }
    
    
})