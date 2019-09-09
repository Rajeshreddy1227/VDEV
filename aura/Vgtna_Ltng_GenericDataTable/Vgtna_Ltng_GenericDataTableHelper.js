({
    getDataHelper : function(component, event) {
        var action = component.get("c.getsObjectRecords");
        //Set the Object parameters and Field Set name
        action.setParams({
            strObjectName : component.get("v.ObjectName"),
            strFieldSetName : component.get("v.FieldSetName"),
            dealerCode : component.get("v.dealerCode"),
            dealerBrand : component.get("v.dealerBrand"),
            accountField : component.get("v.accountField"),
            newButton : component.get("v.newButton"),
            editButton : component.get("v.editButton"),
            deleteButton : component.get("v.deleteButton"),
            recordsDisplayed : component.get("v.recordsDisplayed"),
            recId : component.get("v.accId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.mycolumns", response.getReturnValue().lstDataTableColumns);
                component.set("v.mydata", response.getReturnValue().lstDataTableData);    
                component.set("v.totalNumberOfRows", response.getReturnValue().totalRecords);
            }else if (state === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
        });
        $A.enqueueAction(action);	
    },
    
    fetchLoggedInUser : function(component) {
        var action = component.get("c.getLoggedUser");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.loggedInUser", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    viewRec : function(component, row) {
        var loggedContactId = component.get("v.loggedInUser").ContactId;
        console.log('loggedcontactId: '+loggedContactId);
        if(loggedContactId != null) {
            var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": $A.get("$Label.c.Vgtna_Dealer_Community_URL")+'?Id=' + row.Id
                });
                urlEvent.fire();
        } else {
            console.log('viewrec: ');
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": row.Id,
              "slideDevName": "related"
            });
            navEvt.fire();
        }
    },
    
    deleteRec : function(component, row) {
        
        var action = component.get("c.deleteRec");
        action.setParams({
            Id : row.Id
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                if(response.getReturnValue() === 'SUCCESS'){
            		this.showNotification(component, 'Success!', 'Deleted the ASR', 'success');
                    $A.get('e.force:refreshView').fire();
                }
            } else {
                console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
        
    showNotification : function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
})