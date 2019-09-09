({
	RecordTypeSelectorController: function(component) {
     
    var action = component.get("c.getListOfRecordType");
        
    action.setCallback(this, function(actionResult) {
        var infos = actionResult.getReturnValue();
        //alert("Size: "+infos.length);
        if(infos.length == 1)
        {
           component.set("v.isOpen", false);
            document.getElementById("newClientSectionId").style.display = "none";
            // hide below modal.
                $A.get("e.force:closeQuickAction").fire();
            var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    "entityApiName": "Lead",
                    "recordTypeId":infos.id                   
                });
            	createRecordEvent.fire();
        }
        else if(infos.length > 1)
        {
             component.set("v.recordTypes", infos);
        }
         
    });
    $A.enqueueAction(action);
   }
})