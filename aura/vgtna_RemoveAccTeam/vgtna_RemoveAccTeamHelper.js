({
	fetchAccountTeam : function(component, event, helper) {
		var action = component.get("c.RemoveAccountTeamInternal");
        var accountId = component.get("v.recordId");
        action.setParams({
            accountId :accountId
        });
        action.setCallback(this,function(response){
          var state = response.getState();
            if(state === 'SUCCESS') {
                var accteam = response.getReturnValue();
                component.set("v.AccountTeam",accteam);
                if(accteam.length > 0) {
                    component.set("v.showTeamList", true);
                } else {
                    component.set("v.showTeamList", false);
                }
            }
            else {
                alert('Error in getting data');
            }
         });
        $A.enqueueAction(action);
	},
    deleteAccountTeam : function(component, event, helper) {
        var accMemToDelete = component.find("deleteMember");
        var idsToDelete = [];
        if(accMemToDelete.length!=undefined) {
            // Iterating the array to get contact ids
            for(var i=0;i<accMemToDelete.length;i++) {
                // If contact has delete checkbox checked, add contact id to list of ids to delete
                if(accMemToDelete[i].get("v.checked"))            
                    idsToDelete.push(accMemToDelete[i].get("v.value"));
            }            
        }
        else {
            // if contactsToDelete is not an array but single object, 
            // check if delete checkbox is checked and push id to list of ids to delete
            if(accMemToDelete.get("v.checked"))            
                idsToDelete.push(accMemToDelete.get("v.value"));            
        }
        var toastEvent = $A.get('e.force:showToast');
        var deleteAction = component.get('c.deleteTeam');
        
        deleteAction.setParams({
            accTeamMemId: idsToDelete
        });
		deleteAction.setCallback(this, function(response){
             var state = response.getState();
            if(state === 'SUCCESS') {                
                var dataMap = response.getReturnValue();
                    if(dataMap=='Success') {
                    toastEvent.setParams({
                        'title': 'Success!',
                        'type': 'success',
                        'mode': 'dismissable',
                       'message' : 'Contacts deleted sucessfully.' 
                    });
                    toastEvent.fire();  
                }
                else if(dataMap.status=='error') {
                         toastEvent.setParams({
                        'title': 'Error!',
                        'type': 'error',
                        'mode': 'dismissable',
                     //   'message': dataMap.message
                    });
                    toastEvent.fire();            
				}
        }
            else {
                alert('Error in getting data');
            }           
    });
        $A.enqueueAction(deleteAction);
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
                    
    }      
})