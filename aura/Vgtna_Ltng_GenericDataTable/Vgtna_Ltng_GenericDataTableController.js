({
	doInit : function(component, event, helper) {	
        
        var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ];
        var param = 'accId';
        var result=decodeURIComponent
        ((new RegExp('[?|&]' + param + '=' + '([^&;]+?)(&|#|;|$)').
            exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null;
        if(result != null) {
        	component.set("v.accId",result);
        } else {
            //alert('accid doinit:'+component.get("v.accId")+'--'+component.get("v.FieldSetName"));
            if(component.get("v.viewAllInternal") == false) {
                //alert('entered view all');
                var aid = component.get("v.recordId");
                component.set("v.accId", aid);
            } else {
                component.set("v.viewAllButton", false);
            }
        }
    
        helper.fetchLoggedInUser(component, event);
        helper.getDataHelper(component, event);
    },
    
    createRecord : function(component, event, helper) {
       // alert('entered create');
        //var accparam = '{Account__c:'+component.get("v.recordId")+'}';
        if(component.get("v.ObjectName") == 'Assigned_Sales_Rep__c') {
            var createAssignedSalesRepEvent = $A.get("e.force:createRecord");
            createAssignedSalesRepEvent.setParams({
                "entityApiName":component.get("v.ObjectName"),
                "defaultFieldValues":{
                    Account__c:component.get("v.recordId")
                }
            });
            
            createAssignedSalesRepEvent.fire();
        }
        if(component.get("v.ObjectName") == 'Asset') {
            var createVDAAssetsEvent = $A.get("e.force:createRecord");
            createVDAAssetsEvent.setParams({
                "entityApiName":component.get("v.ObjectName"),
                "defaultFieldValues":{
                    
                    AccountId:component.get("v.recordId")
                }
            });
            
            createVDAAssetsEvent.fire();
        }
    },
    
    viewAll: function(component, event, helper) {
        var loggedContactId = component.get("v.loggedInUser").ContactId;
        console.log('loggedcontactId: '+loggedContactId+'--'+component.get("v.recordId"));
        if(loggedContactId != null) {
            if(component.get("v.ObjectName") == 'Assigned_Sales_Rep__c') {
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": $A.get("$Label.c.Vgtna_Dealer_Community_URL")+'asrgenericdatatable/?accId=' + component.get("v.recordId")
                });
                urlEvent.fire();
            }
            if(component.get("v.ObjectName") == 'Asset') {
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": $A.get("$Label.c.Vgtna_Dealer_Community_URL")+'vda-assets-genericdatatable/?accId=' + component.get("v.recordId")
                });
                urlEvent.fire();
            }
        } else {
            //alert('entered'+component.get("v.recordId"));
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:Vgtna_Ltng_GenericDataTable",
                componentAttributes: {
                    ObjectName : component.get("v.ObjectName"),
                    title : component.get("v.title"),
                    FieldSetName : component.get("v.FieldSetName"),
                    dealerCode : component.get("v.dealerCode"),
                    accountField : component.get("v.accountField"),
                    dealerBrand : component.get("v.dealerBrand"),
                    newButton : component.get("v.newButton"),
                    editButton : "true",
                    deleteButton : "true",
                    accId : component.get("v.recordId"),
                    viewAllButton : "false",
                    viewAllInternal : "true",
                    iconName : component.get("v.iconName")
                }
            });
            evt.fire();
        }
    },
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'Edit':
                
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                     "recordId": row.Id
               });
                editRecordEvent.fire();
                break;
            case 'Delete':
                helper.deleteRec(component, row);
                break;
            case 'View':
                helper.viewRec(component, row);
                break;
        }
    },
    
    backToAccount: function (component, event, helper) {
        //alert('navigate: '+component.get("v.accId"));
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.accId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    
    getURLParameter : function(component, param) {
    var result=decodeURIComponent
        ((new RegExp('[?|&]' + param + '=' + '([^&;]+?)(&|#|;|$)').
            exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null;
        component.set("v.accId",result);
    }
})