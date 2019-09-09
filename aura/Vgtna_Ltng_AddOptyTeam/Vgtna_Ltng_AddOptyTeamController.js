({
	init : function(component, event, helper) 
    {
        helper.fetchMgmtUsers(component, event, helper);
	},
    
    updateSelectedText: function (component, event) 
    {
        var selectedRows = event.getParam('selectedRows');
		var selUserIds = [];
        for(var i = 0; i<selectedRows.length; i++){
            selUserIds.push(selectedRows[i].Id);
        }
        console.log('selUserIds -> ' + selUserIds);
        component.set('v.selectedUsers', selUserIds);
        component.set('v.selectedRowsCount', selectedRows.length);
    },
    
    addSelectedUsers: function (component, event, helper)
    {
        var oId = component.get("v.recordId");
        var actionAddUsers = component.get("c.addOptyTeam");
        var toastEvent = $A.get('e.force:showToast');
        actionAddUsers.setParams({
            					"optyId" : component.get("v.recordId"),
            					"optyTeamMemId" : component.get("v.selectedUsers")});
        actionAddUsers.setCallback(this, function(response){
            var state = response.getState();
            console.log('state '+state);
            if(state == "SUCCESS"){
                var controllerResponse = response.getReturnValue();
                console.log('controllerResponse'+ controllerResponse);
                if(controllerResponse == 'Assigned'){
                    toastEvent.setParams({
                        'title': 'Success!',
                        'type': 'success',
                        'mode': 'dismissable',
                       'message' : 'added Successfully!.' 
                    });
                        toastEvent.fire(); 
                }
                else if(controllerResponse == 'Exists'){
                    toastEvent.setParams({
                        'title'		: 'Success!',
                        'type'		: 'success',
                        'mode'		: 'dismissable',
                        'message' 	: 'added Successfully!' 
                    });
                    toastEvent.fire();
                }
            }else{
                console.log("Failed with state: " + state);
            }              
        });
        $A.enqueueAction(actionAddUsers);
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },
    
    handleCancel: function(component, event, helper)
    {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    filterKeyChange : function(component, event, helper)
    {
        
        if(!component.find("filter").get("v.value"))
        {	
            component.set('v.OptyTeamMember', component.get("v.myData"));
        }
        if(event.keyCode === 13)
        {
            var filterStr = component.find("filter").get("v.value");
            if(component.find("filter").get("v.value"))
            {
                var currData = [];
                currData = component.get('v.OptyTeamMember');
                var filteredData = [];
          /*      for(var i = 0; i<currData.length; i++)
                {
                    if(!!currData[i].LastName && !!currData[i].FirstName){
                        if(currData[i].FirstName.includes(filterStr) ||currData[i].LastName.includes(filterStr)) {
                       // if(currData[i].LastName.includes(filterStr)) 
                            filteredData.push(currData[i]);
                        }
                    }
                }*/
                //
                for(var i = 0; i<currData.length; i++)
                {
                    if(!!currData[i].Name.indexOf(' ') >= 0){
                        if(!!currData[i].Name){
                            if(currData[i].Name.toLowerCase().includes(filterStr.toLowerCase())) {
                                filteredData.push(currData[i]);
                            }
                        }
                    }
                    else
                    {
                        
                        if(!!currData[i].LastName){
                            if(currData[i].LastName.toLowerCase().includes(filterStr.toLowerCase())) {
                                filteredData.push(currData[i]);
                            }
                        }
                        if(!!currData[i].FirstName){
                            if(currData[i].FirstName.toLowerCase().includes(filterStr.toLowerCase())) {
                                filteredData.push(currData[i]);
                            }
                        }
                    }
                    //Including Name in the Search
                    
                }
                //
                component.set('v.OptyTeamMember', filteredData);
            }
            /*else
            {
                component.set('v.OptyTeamMember', component.get("v.myData"));
            }*/
        }        
    }
})