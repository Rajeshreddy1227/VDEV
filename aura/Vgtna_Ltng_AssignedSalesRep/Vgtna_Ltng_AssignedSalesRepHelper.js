({
    fetchData: function (cmp) {
        var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ];
        cmp.set('v.mycolumns', [
                        {label: 'ASR#', 
                             fieldName : 'ASRLink', 
                             type:'url',
                             typeAttributes:{
                                 tooltip:{
                                     fieldName:'ASRName'
                                 },
                                 target: '_self',
                                 label:{
                                     fieldName:'ASRName' }
                                         }
                        },
            			
            			{ label: 'PARTY ID', fieldName: 'PartyId', type: 'text'},
                        { label: 'PRIMARY ADDRESS', fieldName: 'Address', type: 'text'},
            			
                       
                        {label: 'SALES REP', 
                             fieldName : 'SalesRepLink',
                         
                             type:'url',
                             typeAttributes:{
                                 tooltip:{
                                     fieldName:'SalesRepName'
                                 },
                                 target: '_self',
                                 label:{
                                     
                                     fieldName:'SalesRepName' 
                                 }
                             }    			
            			},
            { type: 'action', typeAttributes: { rowActions: actions }}
                    ]);
        var action = cmp.get('c.getAssignedSalesRep');
        action.setParams({"recId": cmp.get("v.recordId")
                         });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert('return value: '+response.getReturnValue()[0]);
                if(response.getReturnValue() != null && response.getReturnValue().length > 0) {
                	cmp.set("v.mydata",response.getReturnValue());
                    if(response.getReturnValue()[0].accountName != null){
                    	cmp.set("v.AccountName", response.getReturnValue()[0].accountName);
                    }
                }
               
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
                cmp.set("v.noResults", "An error occurred: No records to display");
            }
        });
        $A.enqueueAction(action);
    },
    deleteRec: function(cmp, row) {
        alert('row: '+row.ASRLink);
        var action = cmp.get('c.deleteASR');
        action.setParams({"recId": row.ASRLink.slice(1)
                         });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('return value: '+response.getReturnValue());
                if(response.getReturnValue() == "Success") {
                	var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "The record "+row.ASRName+" has been deleted successfully.",
                        "type": "success"
                    });
                    toastEvent.fire();
                }
               
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
                
            }
        });
        $A.enqueueAction(action);

    	var rows = cmp.get('v.mydata');
        var rowIndex = rows.indexOf(row);

        rows.splice(rowIndex, 1);
        cmp.set('v.mydata', rows);
	}
})