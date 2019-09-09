({
	rerouteAccount : function(component,event,helper) {
        var action = component.get("c.findAccount");
        var accountId = component.get("v.recordId");
        action.setParams({
           accountid :accountId 
        });
        action.setCallback(this,function(response){
         	var state = response.getState();  
            
            if(state === 'SUCCESS'){
            var retrnval = response.getReturnValue();                             
                if(retrnval!==null){
                    component.set("v.surAccRec",retrnval);
                     console.log('retrnval=='+response.getReturnValue().Party_ID__c+"and AccountId "+retrnval.Id);
                    component.set("v.SurvivorId", retrnval.Id);
                    component.set("v.SurvivorAccName", retrnval.Name);
                    component.set("v.SurAccPartyId",retrnval.Party_ID__c);
                    console.log('isopen: ');
                    component.set("v.isOpen", "true");
                }
                else
                {
                    component.set("v.SurvivorId", null);
                    component.set("v.isOpen", "false");
                }
            }
        });
        $A.enqueueAction(action);
	}
})