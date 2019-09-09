({
    
    init: function (cmp, event, helper) {
        console.log('result1: '+result);
        console.log('location1:'+cmp.get("v.Location"));
        
        /*if(cmp.get("v.Location") == 'Account Page' || cmp.get("v.recordId") != null) {
            cmp.set("v.prevPage", 'Back To Account');
        }
        if(cmp.get("v.Location") == 'Home Page' && cmp.get("v.recordId") == null) {
            cmp.set("v.prevPage", 'Back To Home Page');
        }*/
        var param = 'showViewAll';
        var accParam = 'accId';
        var result=decodeURIComponent
        ((new RegExp('[?|&]' + param + '=' + '([^&;]+?)(&|#|;|$)').
            exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null;
        console.log('result: '+result);
        var accId=decodeURIComponent
        ((new RegExp('[?|&]' + accParam + '=' + '([^;]+?)(&|#|;|$)').
            exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null;
        if(accId != null) {
            cmp.set("v.recordId", accId);
        }    
            
        console.log('accId: '+accId);
        if(result != null) {
        	cmp.set("v.showViewAll",result);
        } else {
            if(cmp.get("v.internalShowViewAll") != false) {
            	cmp.set("v.showViewAll",true);
            } else {
                cmp.set("v.showViewAll",false);
            }
        }
        if(cmp.get("v.Location") == 'Account Page' || cmp.get("v.recordId") != null) {
            cmp.set("v.prevPage", 'Back To Account');
        }
        if(cmp.get("v.Location") == 'Home Page' && cmp.get("v.recordId") == null) {
            cmp.set("v.prevPage", 'Back To Home Page');
        }
        helper.fetchLoggedInUser(cmp, event);
        helper.fetchData(cmp);
    },
    
    updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // assign the latest attribute with the sorted column fieldName and sorted direction
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
    createNewActivity: function(cmp, event, helper) {
        var createRecordEvent = $A.get('e.force:createRecord');
                if ( createRecordEvent ) {
                    createRecordEvent.setParams({
                        'entityApiName': 'Task'
                        
                    });
                    createRecordEvent.fire();
                }
    },
    logaCall: function(cmp, event, helper) {
        var createRecordEvent = $A.get('e.force:createRecord');
        var today = new Date();
        console.log('today: '+today);
                if ( createRecordEvent ) {
                    createRecordEvent.setParams({
                        'entityApiName': 'Task',
                        "defaultFieldValues": {
                            'TaskSubtype' : 'Call',
                            'Status': 'Completed',
                            'ActivityDate':today
                            
                        }
                        
                    });
                    createRecordEvent.fire();
                }
    },
    createNewEvent: function(cmp, event, helper) {
        var createRecordEvent = $A.get('e.force:createRecord');
                if ( createRecordEvent ) {
                    createRecordEvent.setParams({
                        'entityApiName': 'Event'
                        
                        
                    });
                    createRecordEvent.fire();
                }
    },
    sendEmail: function(cmp, event, helper) {
        console.log('entered send email');
        $A.createComponent("c:Vgtna_NewEmailActivities", {
                
                'openModal' : true
            },
            function(modalComponent) {
                                   console.log('entered modal component');
                if (cmp.isValid()) {
                    console.log('entered modal component if');
                    //Appending the newly created component in div
                    var body = cmp.find( 'popupEmail' ).get("v.body");
                    body.push(modalComponent);
                    console.log('entered modal component if2');
                    cmp.find( 'popupEmail' ).set("v.body", body);
                }
            });  
    },
    
    viewAll : function(cmp, event, helper) {
        console.log('location:'+cmp.get("v.Location"));
        if(cmp.get("v.Location") == 'Account Page') {
            cmp.set("v.prevPage", 'Back To Account');
        }
        if(cmp.get("v.Location") == 'Home Page') {
            cmp.set("v.prevPage", 'Back To Home Page');
        }
        console.log('prevpag:'+cmp.get("v.prevPage"));
        cmp.set("v.showViewAll", false);
        var loggedContactId = cmp.get("v.loggedInUser").ContactId;
       if(loggedContactId != null)
       {
           if(cmp.get("v.recordId") == null) {
               var urlEvent = $A.get("e.force:navigateToURL");
               urlEvent.setParams({
                   "url": $A.get("$Label.c.Vgtna_Dealer_Community_URL")+'activities/?showViewAll=false'
               });
               urlEvent.fire();
           } else {
               var urlEvent = $A.get("e.force:navigateToURL");
               urlEvent.setParams({
                   "url": $A.get("$Label.c.Vgtna_Dealer_Community_URL")+'activities/?showViewAll=false&accId='+cmp.get("v.recordId")
               });
               urlEvent.fire();
           }
       }
        else {
            //alert('entered'+component.get("v.recordId"));
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:Vgtna_Ltng_CustomerActivities",
                componentAttributes: {
                    recordId : cmp.get("v.recordId"),
                    mydata : cmp.get("v.mydata"),
                    mycolumns : cmp.get("v.mycolumns"),
                    noResults : cmp.get("v.noResults"),
                    Location : cmp.get("v.Location"),
                    prevPage : cmp.get("v.prevPage"),
                    showViewAll: cmp.get("v.showViewAll"),  
                    loggedInUser: cmp.get("v.loggedInUser"),
                    internalShowViewAll: false
                }
            });
            evt.fire();
        }
        
    },
    
    previousPage : function(cmp, event, helper) {
        if(cmp.get("v.prevPage") == 'Back To Account') {
            
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": cmp.get("v.recordId"),
                "slideDevName": "detail"
            });
            navEvt.fire();
            
        }
        if(cmp.get("v.prevPage") == 'Back To Home Page') {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": $A.get("$Label.c.Vgtna_Dealer_Community_URL")
            });
            urlEvent.fire();
            
        }
    },
    
    downloadCsv : function(component,event,helper){
        var stockData = component.get("v.mydata");        
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData);   
         if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
    	hiddenElement.click(); // using click() js function to download csv file
    }

})