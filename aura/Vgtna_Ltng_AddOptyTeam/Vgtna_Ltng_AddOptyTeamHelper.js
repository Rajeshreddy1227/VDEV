({
	fetchMgmtUsers : function(component, event, helper) {
		component.set('v.mycolumns', [
                                        {label: 'First Name', fieldName: 'FirstName', type: 'text'},
                                        {label: 'Last Name', fieldName: 'LastName', type: 'text'}]);

        var optyId = component.get("v.recordId");
        var action = component.get("c.getMgmtUsers");
		action.setParams({
            optyId :optyId
        });
        action.setCallback(this, function(response){
            var status = response.getState();
            if(status == "SUCCESS"){
                var records = response.getReturnValue();              
                component.set('v.OptyTeamMember', response.getReturnValue());
                component.set('v.myData', response.getReturnValue());
            }
            else{
                console.log("Failed with state : "+ state);
            }
        });
        $A.enqueueAction(action);        
	}
})