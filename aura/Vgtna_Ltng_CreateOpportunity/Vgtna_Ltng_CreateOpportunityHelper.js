({
   RecordTypeSelectorController: function(component, user) {
    var action = component.get("c.getListOfRecordType");
    action.setParams({ user : component.get("v.user") });

    action.setCallback(this, function(actionResult) {
        var infos = actionResult.getReturnValue(); 
       if(infos.length == 1)
       {
            var currentAccntId = component.get("v.recordId");
           component.set("v.isOpen", false);
           document.getElementById("newClientSectionId").style.display = "none" ;
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    'entityApiName': "Opportunity",
                    'recordTypeId':infos.id,
                    'defaultFieldValues': {  "AccountId":currentAccntId}
                
                });
                // hide below modal.
                $A.get("e.force:closeQuickAction").fire();
            	createRecordEvent.fire();
       }
       else if(infos.length > 1)
        {
             component.set("v.recordTypes", infos); 
        }
        
        

        //component.set("v.userId", userId);  

    });
    $A.enqueueAction(action);
  },

   CustomerRecordTypeIdController: function(component) {
    var RTid = component.get("c.getOpportunityRecordType");
    RTid.setCallback(this, function(actionResult) {
       var infos = actionResult.getReturnValue();
       component.set("v.recordTypeId", infos);  
    });
    $A.enqueueAction(RTid);
  }, 
  /*
   SetRecordId: function(component, str) {
    var action2 = component.get("c.getAccount");
    action2.setParams({ accountIdString : str});

    action2.setCallback(this, function(actionResult) {
        var accnt = actionResult.getReturnValue(); 
       // alert('accont'  + accnt.Name);
        component.set("v.account", accnt);  

        //component.set("v.userId", userId);  

    });
    $A.enqueueAction(action2);
  }*/
})