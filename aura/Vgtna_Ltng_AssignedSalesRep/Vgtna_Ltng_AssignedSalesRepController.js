({
	init : function(component, event, helper) {
        
		helper.fetchData(component);
	},
    createAssignedSalesRep : function(component, event, helper) {
        var createAssignedSalesRepEvent = $A.get("e.force:createRecord");
        createAssignedSalesRepEvent.setParams({
            "entityApiName": "Assigned_Sales_Rep__c",
            "defaultFieldValues": {
                'Account__c' : component.get("v.recordId")
            }
        });
        createAssignedSalesRepEvent.fire();
    },
    viewAll : function(component, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": $A.get("$Label.c.Vgtna_Dealer_Community_URL")+'assigned-sales-rep/?accId=' + component.get("v.recordId")
    });
    urlEvent.fire();
        
    },
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'edit':
                
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                     "recordId": row.ASRLink.slice(1)
               });
                editRecordEvent.fire();
                break;
            case 'delete':
                helper.deleteRec(component, row);
                break;
        }
    },
    backToAccount: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
})