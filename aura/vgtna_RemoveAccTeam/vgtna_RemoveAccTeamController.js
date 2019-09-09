({
	getAccountTeam : function(component, event, helper) {
		helper.fetchAccountTeam(component, event, helper);
	},
    deleteAccTeam : function(component, event, helper){
    helper.deleteAccountTeam(component, event, helper);
	},
    cancel:function(component, event, helper){
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})