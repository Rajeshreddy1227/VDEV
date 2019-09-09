({
	fetchUsers : function(component, event, helper) {
		helper.helperUsers(component, event, helper);
	},
        Assign : function(component, event, helper) {
         helper.assignUser(component, event, helper);
     
	},
    Cancel:function(component, event, helper) {
         $A.get("e.force:closeQuickAction").fire();
    }
})