({
   RecordTypeSelectorController: function(component) {
    var action = component.get("c.getListOfRecordType");
    action.setCallback(this, function(actionResult) {
        var infos = actionResult.getReturnValue();
       // component.set("v.recordTypes", infos);  
        	
        	if(infos.length == 1)
               {
                       var customerRecTypeId = component.get("v.recordTypeId");   
                   //alert("customerRecTypeId: "+ customerRecTypeId);
                   // alert("infos stringified: "+ JSON.stringify(infos));
                   //var stringifiedRT = JSON.stringify(infos[0].Id);
                  // alert("infos[0].Id: "+infos[0].Id);
                        if(infos[0].Id != customerRecTypeId)
                        {
                            // alert("Not equals");
                            document.getElementById("newClientSectionId").style.display = "none" ;
                            var createRecordEvent = $A.get("e.force:createRecord");
                            createRecordEvent.setParams({
                                "entityApiName": "Account",
                                "recordTypeId":infos.Id
                            });
                            createRecordEvent.fire();
                        }
                        else
                        {                         
                          // alert("Equals");
                            var evt = $A.get("e.force:navigateToComponent");
                            console.log('evt'+evt);
                            evt.setParams({
                                componentDef: "c:Vgtna_CustomerAccountForm",
                                componentAttributes :{
                                 recType: customerRecTypeId
                                }
                            });
                            
                            evt.fire();
                        }
               }
               else if(infos.length > 1)
                {
                     component.set("v.recordTypes", infos); 
                }
        
    });
    $A.enqueueAction(action);
  },
   CustomerRecordTypeIdController: function(component) {
    var RTid = component.get("c.getAccountRecordType");
            RTid.setCallback(this, function(actionResult) {
            var infos = actionResult.getReturnValue();
            component.set("v.recordTypeId", infos);  
    		});
    $A.enqueueAction(RTid);
  }, 
})