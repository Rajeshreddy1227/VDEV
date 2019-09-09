({
	init : function(component, event, helper) {
       // component.set("v.enableInfiniteLoad", true);
         console.log('spinner 1: '+component.get("v.Spinner"));
        component.set("v.onPageLoad", true);
        component.set('v.mycolumns', [
            
            {label: 'Account Name', 
             iconName: 'standard:opportunity',
                             fieldName : 'accLink', 
                             type:'url',
                             typeAttributes:{
                                 tooltip:{
                                     fieldName:'accountName'
                                 },
                                 target: '_self',
                                 label:{
                                     fieldName:'accountName' }
                                         }
                        },
            
              { label: 'Assigned Reps', fieldName: 'assignedReps', type: 'text'},          
            			
          //  { label: 'Dealer Code', fieldName: 'dealerCode', type: 'text'},
            			{ label: 'PARTY ID', fieldName: 'PartyId', type: 'text'},
            { label: 'Street', fieldName: 'street', type: 'text'},
            { label: 'City', fieldName: 'city', type: 'text'},
            { label: 'County', fieldName: 'county', type: 'text'},
            { label: 'State', fieldName: 'state', type: 'text'},
            { label: 'Country', fieldName: 'country', type: 'text'},
            { label: 'postal Code', fieldName: 'postalCode', type: 'text'}
            
            
                    ]);
        //component.set("v.Spinner", true);
        //helper.getTotalRecordsNum(component, event, helper);
        component.set("v.selectedRep",'All Assigned Accounts');
         console.log('spinner 2: '+component.get("v.Spinner"));
        helper.getSalesReps(component, event, helper);
		helper.fetchData(component, event);
       // component.set("v.Spinner", false);
       // component.set("v.onLoad", false);
         console.log('spinner 3: '+component.get("v.Spinner"));
	},
    
    onSalesRepChange : function(component, event, helper) {
        component.find("selectallrec").set("v.checked", false);
        component.set("v.recSelected", 0);
        var rows = [];
        component.set("v.selRows", rows);
        if(component.get("v.selectedRep") == 'All UnAssigned Accounts')  {
            component.set("v.keyfield", "accId");
            //component.set("v.unassignAcctIds", component.get("v.allUnassignAcctIds"));
            var unAssignedAccSize = component.get("v.allUnassignAcctIds").length;
            console.log('unAssignedAccSize: '+unAssignedAccSize);
            component.set("v.totalNumberOfRows", unAssignedAccSize);
            component.set("v.accCreatedDt", null);
            component.set("v.lastAccId", null);
        } else if(component.get("v.selectedRep") == 'All Assigned Accounts')  {
            //component.set("v.onPageLoad", true);
            component.set("v.keyfield", "uniqfield");
        } else {
            component.set("v.keyfield", "asrId");
        }
       // if(component.get("v.selectedRep") != 'All UnAssigned Accounts')  {
        	component.set("v.onLoad", true);  
        	component.set("v.loadMore", false);
       // }
        component.set("v.asrCreatedDt", null);
        component.set("v.lastAsrId", null);
        var sData = [];
        component.set("v.mydata",sData);
        component.set("v.asrData",sData);
        component.set("v.acctData",sData);
      var selRep = component.get("v.selectedRep");
        console.log('selreP: '+selRep);
      helper.fetchData(component, event, helper);
        console.log('salesrep: '+selRep);
    },
    
    assignSalesRep: function (component, event, helper) {
        var selectedAccts = component.get("v.selectedAccts");
        console.log('selectedAccts: '+selectedAccts);
        console.log('select all: '+component.find("selectallrec").get("v.checked"));
        console.log('restrict: '+component.get("v.restrictSalesRep"));
        if((selectedAccts.length > 0 || component.find("selectallrec").get("v.checked") == true) && component.get("v.restrictSalesRep") == false) {
            
            $A.createComponent("c:Vgtna_ACHUsersModal", {
                
                'openModal' : true,
                'selectedRecs' : selectedAccts,
                'newASR' : true,
                'selectAllRecs':component.find("selectallrec").get("v.checked"),           
                'salesRepFilter':component.get("v.selectedRep"),
                'cityFilter':component.find("cityname").get("v.value"),
                'countyFilter':component.find("countyname").get("v.value"),
                'zipcodeFilter':component.find("zipcodename").get("v.value"),
                'AccFilter':component.find("AccFilter").get("v.value"),
                'allTerrAccIds':component.get("v.allTerrAccIds"),
                'allUnassignAcctIds':component.get("v.allUnassignAcctIds")
            },
            function(modalComponent) {
                                   
                if (component.isValid()) {
                    //Appending the newly created component in div
                    var body = component.find( 'showSalesRepList' ).get("v.body");
                    body.push(modalComponent);
                    component.find( 'showSalesRepList' ).set("v.body", body);
                }
            });  
            
        } else if(component.get("v.restrictSalesRep") == true && component.get("v.isSalesRep") == true) {
            helper.showNotification(component, 'Info!', 'You do not have enough permission to perform the action. Please contact your manager.', 'info');
        } else {
        	helper.showNotification(component, 'Info!', 'Please select at least one account', 'info');
        }
        
    },
    
    handleSelectAll : function(component, event, helper) {
        //alert('entered all');
        var rows = [];
        if(component.find("selectallrec").get("v.checked") == true) {
            //var rows = [];
            var data = component.get("v.mydata");
            console.log('data; '+data);
            console.log('selectedrep: '+component.get("v.selectedRep"));
            var totalRec = component.get("v.totalNumberOfRows");
            component.set("v.recSelected", totalRec);
            if(component.get("v.selectedRep") == 'All Assigned Accounts') {
                for(var i = 0; i<data.length; i++) {
                    rows.push(data[i].uniqfield);
                }
            } else if(component.get("v.selectedRep") == 'All UnAssigned Accounts') {
                component.set("v.keyfield", "accId");
                for(var i = 0; i<data.length; i++) {
                    rows.push(data[i].accId);
                }
            } else {
                component.set("v.keyfield", "asrId");
                for(var i = 0; i<data.length; i++) {
                    rows.push(data[i].asrId);
                    
                }
            }
           /* for(var i = 0; i<data.length; i++) {
                if(data[i].asrId != null && data[i].asrId != '') {
                    console.log('asrid:::'+data[i].asrId);
                    rows.push(data[i].accId);
                } else {
                    console.log('accid:::'+data[i].accId);
                    rows.push(data[i].accId);
                }
                
            }*/
            
            console.log('rowssssss: '+rows);
            console.log('keyfield:'+component.get("v.keyfield"));
            
        } else {
            component.set("v.recSelected", 0);
        }
        component.set("v.selRows", rows);
    },
    
    handleSelectedRows : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows'); 
        //console.log('entered rows:');
       // console.log('entered rows: '+event.getParam('selectedRows'));
        component.set("v.recSelected",0);
        var setRows = []; 
        if(component.get("v.selectedRep") != 'All UnAssigned Accounts' && component.get("v.selectedRep") != 'All Assigned Accounts') {
            console.log('entered unassign rows');
            component.set("v.keyfield", "asrId");
            for ( var i = 0; i < selectedRows.length; i++ ) {
            //alert('selected id : '+selectedRows[i].accId);
            setRows.push(selectedRows[i].asrId);
            }
            component.set("v.reAssignUnAssignIds", setRows);
            
        } else if(component.get("v.selectedRep") == 'All UnAssigned Accounts') {
            component.set("v.keyfield", "accId");
            for ( var i = 0; i < selectedRows.length; i++ ) {
            //alert('selected id : '+selectedRows[i].accId);
            setRows.push(selectedRows[i].accId);
            }
            
            component.set("v.selectedAccts", setRows);
        } else {
            component.set("v.keyfield", "uniqfield");
            for ( var i = 0; i < selectedRows.length; i++ ) {
            //alert('selected id : '+selectedRows[i].accId);
            setRows.push(selectedRows[i].accId);
            }
            
            component.set("v.selectedAccts", setRows);
            
            //console.log('selected accs: '+component.get("v.keyfield"));
        }
        console.log('selected rows: '+selectedRows);
        component.set("v.recSelected",selectedRows.length);
        
        
    },
    
    cityKeyChange : function(component, event, helper) {
        
        var sData = [];
        component.set("v.mydata",sData);
        component.set("v.onLoad", true);
        component.set("v.asrCreatedDt", null);
        component.set("v.lastAsrId", null);
        component.set("v.lastAccId", null);
        component.set("v.accCreatedDt", null);
        component.set("v.loadedAsrSize", null);
        component.set("v.loadedAccSize", null);
        component.set("v.unassignAcctIds", null);
        component.set("v.loadMore", false);
        component.set("v.totalNumberOfRows",0);
        component.set("v.asrData",sData);
        component.set("v.acctData",sData);
        //component.set("v.onKeyUp", true);
        console.log('entered state'+component.get("v.mydata").length);
        var stateString = component.find("cityname").get("v.value");
        //component.set("v.offsetRows",0);
        console.log('stateString: '+stateString);
        console.log('mydata city: '+component.get("v.mydata"));
        //helper.fetchData(component,0);
        /*var timeout = null;
        window.clearTimeout(timeout);
        window.setTimeout(
            $A.getCallback(function() { 
                component.set("v.onLoad", true);
                helper.fetchData(component,0);
            }), 500
        );original*/
        var timeout = component.get("v.timeout");
        component.set("v.timeout", timeout);
        console.log('component.get("v.timeout"): '+component.get("v.timeout"));
        clearTimeout(component.get("v.timeout"));
        var tout = setTimeout(
            $A.getCallback(function() { 
                component.set("v.onLoad", true);
                helper.fetchData(component,0);
                if(component.find("selectallrec").get("v.checked") == true) {
                    var totalRec = component.get("v.totalNumberOfRows");
                    component.set("v.recSelected", totalRec);
                }
                clearTimeout(tout);
                component.set("v.timer", null);
            }), 500
        );
        component.set("v.timeout", tout);
        console.log('tout: '+tout);
        
    },
    
    countyKeyChange : function(component, event, helper) {
        var sData = [];
        component.set("v.mydata",sData);
        component.set("v.onLoad", true);
        component.set("v.asrCreatedDt", null);
        component.set("v.lastAsrId", null);
        component.set("v.lastAccId", null);
        component.set("v.accCreatedDt", null);
        component.set("v.loadedAsrSize", null);
        component.set("v.loadedAccSize", null);
        component.set("v.unassignAcctIds", null);
        component.set("v.loadMore", false);
        component.set("v.totalNumberOfRows",0)
        component.set("v.asrData",sData);
        component.set("v.acctData",sData);
        component.set("v.onKeyUp", true);
        console.log('entered state'+component.get("v.mydata").length);
        var stateString = component.find("countyname").get("v.value");
        component.set("v.offsetRows",0);
        console.log('stateString: '+stateString);
        var timeout = component.get("v.timeout");
        component.set("v.timeout", timeout);
        console.log('component.get("v.timeout"): '+component.get("v.timeout"));
        clearTimeout(component.get("v.timeout"));
        var tout = setTimeout(
            $A.getCallback(function() { 
                component.set("v.onLoad", true);
                helper.fetchData(component,0);
                if(component.find("selectallrec").get("v.checked") == true) {
                    var totalRec = component.get("v.totalNumberOfRows");
                    component.set("v.recSelected", totalRec);
                }
                clearTimeout(tout);
                component.set("v.timer", null);
            }), 500
        );
        component.set("v.timeout", tout);
        console.log('tout: '+tout);
        //window.clearTimeout(timeout);
       // helper.fetchData(component,0);
        
    },
    
    zipcodeKeyChange : function(component, event, helper) {
        var sData = [];
        component.set("v.mydata",sData);
        component.set("v.onLoad", true);
        component.set("v.asrCreatedDt", null);
        component.set("v.lastAsrId", null);
        component.set("v.lastAccId", null);
        component.set("v.accCreatedDt", null);
        component.set("v.loadedAsrSize", null);
        component.set("v.loadedAccSize", null);
        component.set("v.unassignAcctIds", null);
        component.set("v.loadMore", false);
        component.set("v.totalNumberOfRows",0)
        component.set("v.asrData",sData);
        component.set("v.acctData",sData);
        //component.set("v.onKeyUp", true);
        console.log('entered state'+component.get("v.mydata").length);
        var stateString = component.find("zipcodename").get("v.value");
        component.set("v.offsetRows",0);
        console.log('stateString: '+stateString);
        var timeout = component.get("v.timeout");
        component.set("v.timeout", timeout);
        console.log('component.get("v.timeout"): '+component.get("v.timeout"));
        clearTimeout(component.get("v.timeout"));
        var tout = setTimeout(
            $A.getCallback(function() { 
                component.set("v.onLoad", true);
                helper.fetchData(component,0);
                if(component.find("selectallrec").get("v.checked") == true) {
                    var totalRec = component.get("v.totalNumberOfRows");
                    component.set("v.recSelected", totalRec);
                }
                clearTimeout(tout);
                component.set("v.timer", null);
            }), 500
        );
        component.set("v.timeout", tout);
        console.log('tout: '+tout);
        //helper.fetchData(component,0);
        
    },
    
    accountNameChange : function(component, event, helper) {
        var sData = [];
        component.set("v.mydata",sData);
        component.set("v.onLoad", true);
        component.set("v.asrCreatedDt", null);
        component.set("v.lastAsrId", null);
        component.set("v.lastAccId", null);
        component.set("v.accCreatedDt", null);
        component.set("v.loadedAsrSize", null);
        component.set("v.loadedAccSize", null);
        component.set("v.unassignAcctIds", null);
        component.set("v.loadMore", false);
        //component.set("v.onKeyUp", true);
        component.set("v.totalNumberOfRows",0);
        component.set("v.asrData",sData);
        component.set("v.acctData",sData);
        console.log('entered state'+component.get("v.mydata").length);
        var accountString = component.find("AccFilter").get("v.value");
        component.set("v.offsetRows",0);
        console.log('accountString: '+accountString);
        var timeout = component.get("v.timeout");
        component.set("v.timeout", timeout);
        console.log('component.get("v.timeout"): '+component.get("v.timeout"));
        clearTimeout(component.get("v.timeout"));
        var tout = setTimeout(
            $A.getCallback(function() { 
                component.set("v.onLoad", true);
                helper.fetchData(component,0);
                if(component.find("selectallrec").get("v.checked") == true) {
                    var totalRec = component.get("v.totalNumberOfRows");
                    component.set("v.recSelected", totalRec);
                }
                clearTimeout(tout);
                component.set("v.timer", null);
            }), 500
        );
        component.set("v.timeout", tout);
        console.log('tout: '+tout);
        //helper.fetchData(component,0);
        
    },
    
    reAssign : function(component, event, helper) {
        if(component.get("v.restrictSalesRep") == true && component.get("v.isSalesRep") == true) {
            helper.showNotification(component, 'Info!', 'You do not have enough permission to perform the action. Please contact your manager.', 'info');
        } else if(component.get("v.loggedId") != component.get("v.selectedRep") && component.get("v.isSalesRep")) {
            helper.showNotification(component, 'Error!', 'You cannot reassign ASR that are owned by others', 'error');
        } else if(component.get("v.selectedRep") == 'All Assigned Accounts' || component.get("v.selectedRep") == 'All UnAssigned Accounts'){
                console.log('entered else none');
                helper.showNotification(component, 'Info!', 'Please select valid sales rep to ReAssign the ASR', 'info');
        }
          else {
      		helper.reAssignSalesRep(component, event, helper);  
        }
    },
    
    unAssign : function(component, event, helper) {
        console.log('issalesrep: '+component.get("v.isSalesRep"));
        if(component.get("v.restrictSalesRep") == true && component.get("v.isSalesRep") == true) {
            helper.showNotification(component, 'Info!', 'You do not have enough permission to perform the action. Please contact your manager.', 'info');
        } else if(component.get("v.loggedId") != component.get("v.selectedRep") && component.get("v.isSalesRep")) {
            helper.showNotification(component, 'Error!', 'You cannot unassign ASR that are owned by others', 'error');
        }
        
        else {
            if(component.find("selectallrec").get("v.checked") == true || (component.get("v.reAssignUnAssignIds").length > 0 && component.get("v.selectedRep")  != 'None' && component.get("v.selectedRep") != 'Unassigned Accounts')) {
                console.log('entered unassign');
                var action = component.get('c.deleteASR');
                action.setParams({"asrIds" : component.get("v.reAssignUnAssignIds"),
                                  "citySearch": component.find("cityname").get("v.value"),
                                  "countySearch": component.find("countyname").get("v.value"),
                                  "zipcodeSearch": component.find("zipcodename").get("v.value"),
                                  "accNameSearch": component.find("AccFilter").get("v.value"),
                                  "selectAllRecs" : component.find("selectallrec").get("v.checked"),
                                  "salesRepFilter": component.get("v.selectedRep")
                                  });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        console.log('entered return value : '+response.getReturnValue());
                        if(response.getReturnValue() != null) {
                            console.log('entered deleted');
                            if(response.getReturnValue() == 'SUCCESS') {
                                helper.showNotification(component, 'Success!', 'Removed the selected assignment', 'success');
                                window.location.reload();
                            } else if(response.getReturnValue() == 'You have selected different users ASR') {
                                helper.showNotification(component, 'Error!', 'You cannot delete ASR\'s that are assigned to other users', 'error');
                            }
                        }
                    }
                });
                $A.enqueueAction(action);
            } else if(component.get("v.selectedRep") == 'All Assigned Accounts' || component.get("v.selectedRep") == 'All UnAssigned Accounts'){
                console.log('entered else none');
                helper.showNotification(component, 'Info!', 'Please select valid sales rep to unassign the ASR', 'info');
            } else if(component.get("v.reAssignUnAssignIds").length == 0 && component.find("selectallrec").get("v.checked") == false){
                helper.showNotification(component, 'Info!', 'Please select at least one Account', 'info');
            }
        
            //helper.unAssignSalesRep(component);
        }
        
    },
    
    loadMoreData : function(component, event, helper) {
        
        console.log('entered: component.get("v.totalNumberOfRows") '+component.get("v.totalNumberOfRows"));
        console.log('entered: loaddata1 '+component.get("v.mydata").length);
        if(component.get("v.totalNumberOfRows") > component.get("v.mydata").length && component.get("v.mydata").length > 74 && (component.get("v.lastAccId") != null || component.get("v.lastAsrId") != null)) {
            component.set("v.onKeyUp", false);
            console.log('entered: loaddata inside if');
            event.getSource().set("v.isLoading", true);
            component.set("v.loadMore", true);
            helper.fetchData(component, event);
            //event.getSource().set("v.isLoading", false);
            
        } 
    },
    
    downloadCsv : function(component,event,helper){
        console.log('entered down');
        var accNameString = component.find("AccFilter").get("v.value");
        var zipcodeString = component.find("zipcodename").get("v.value");
        var cityString = component.find("cityname").get("v.value");
        var countyString = component.find("countyname").get("v.value");
        var action;
        console.log('entered down1:'+component.get("v.selectedRep"));
        if(component.get("v.selectedRep") == 'All Assigned Accounts' || component.get("v.selectedRep") == 'All UnAssigned Accounts')  {            
            action = component.get('c.exportAssignedAccounts');
            action.setParams({"citySearch": cityString,
                          	  "countySearch": countyString,
                          	  "zipcodeSearch": zipcodeString,
                              "accNameSearch": accNameString,
                          	  "salesRepFilter": component.get("v.selectedRep"),
                          	  
                             });
        } else if(component.get("v.selectedRep") != 'All UnAssigned Accounts' && component.get("v.selectedRep") != 'All Assigned Accounts')  {
            console.log('entered salesrep: ');
            action = component.get('c.exportSRAccounts');
            action.setParams({"citySearch": cityString,
                          	  "countySearch": countyString,
                          	  "zipcodeSearch": zipcodeString,
                              "accNameSearch": accNameString,
                              "salesRepFilter": component.get("v.selectedRep")
                             });
        }
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state: '+state);
            if (state === "SUCCESS") {
                var tdata = response.getReturnValue();
            }
            console.log('tdata: '+tdata+'---'+tdata.wrapASR);
            var adata = [];
            if(tdata.wrapASR != null) {
            	adata = adata.concat(tdata.wrapASR);
            }
            if(tdata.wrapAcc != null) {
            	adata = adata.concat(tdata.wrapAcc);
            }
            console.log('adataaa: '+adata);
            console.log('adataaa1: '+adata.length);
        
        
       // var stockData = component.get("v.mydata");        
       var stockData = adata;
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData);   
         if (csv == null){return;} 
            console.log('csv: '+encodeURIComponent(csv));
            //var csvData = new Blob([csv], { type: 'text/csv' }); 
			//var csvUrl = URL.createObjectURL(csvData);
			//a.href =  csvUrl;
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
        //hiddenElement.href =  csvUrl;
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
    	hiddenElement.click(); // using click() js function to download csv file
            });
        $A.enqueueAction(action);
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
        //component.set("v.LoadedAllRecords", false);
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       //component.set("v.LoadedAllRecords", true);
        component.set("v.Spinner", false); 
    }
})