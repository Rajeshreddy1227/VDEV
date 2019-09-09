({
	fetchData: function (component, event) {
        
        //component.set("v.Spinner", true);
        var accNameString = component.find("AccFilter").get("v.value");
        var zipcodeString = component.find("zipcodename").get("v.value");
        var cityString = component.find("cityname").get("v.value");
        var countyString = component.find("countyname").get("v.value");
        console.log('entered all asr before'+ component.get("v.selectedRep"));
        console.log('component.get("v.allTerrAccIds"): '+component.get("v.allTerrAccIds"));
        var action;
        if(component.get("v.selectedRep") == 'All Assigned Accounts')  {            
            console.log('entered all asr after'+component.get("v.loadedAsrSize"));
            console.log('entered all asr after:::');
            action = component.get('c.allAccounts');
            action.setParams({"citySearch": cityString,
                          	  "countySearch": countyString,
                          	  "zipcodeSearch": zipcodeString,
                              "accNameSearch": accNameString,
                          	  "salesRepFilter": component.get("v.selectedRep"),
                          	  "onLoad": component.get("v.onLoad"),
                              "asrCreatedDate": component.get("v.asrCreatedDt"),
                              "accCreatedDate": component.get("v.accCreatedDt"),
                              "loadedAsrSize": component.get("v.loadedAsrSize"),
                              "loadedAccSize": component.get("v.loadedAccSize"),
                              "totAsr": component.get("v.totAsr"),
                              "unassignAcctList": component.get("v.unassignAcctIds"),
                              "allTerrAccIds":component.get("v.allTerrAccIds"),
                              "onPageLoad": component.get("v.onPageLoad"),
                              "lastAsrId": component.get("v.lastAsrId"),
                              "lastAccId": component.get("v.lastAccId")
                              
                             });
            //component.set("v.onPageLoad", false);
            console.log('entered all asr');
        } else if(component.get("v.selectedRep") == 'All UnAssigned Accounts')  {
            console.log('unassigned accounts: '+component.get("v.allUnassignAcctIds"));
            console.log('accNameString: '+accNameString);
            console.log('countyString: '+countyString);
            action = component.get('c.loadUnAssignedAccounts');
            action.setParams({"citySearch": cityString,
                          	  "countySearch": countyString,
                          	  "zipcodeSearch": zipcodeString,
                              "accNameSearch": accNameString,
                              "accCreatedDate": component.get("v.accCreatedDt"),
                              "accIds": component.get("v.allUnassignAcctIds"),
                              "onLoad": component.get("v.onLoad"),
                              "lastAccId":component.get("v.lastAccId")
                             });
            
        } else if(component.get("v.selectedRep") != 'All UnAssigned Accounts' && component.get("v.selectedRep") != 'All Assigned Accounts'){
            action = component.get('c.getSelectedASR');
            action.setParams({"citySearch": cityString,
                          	  "countySearch": countyString,
                          	  "zipcodeSearch": zipcodeString,
                              "accNameSearch": accNameString,
                          	  "salesRepFilter": component.get("v.selectedRep"),
                              "asrCreatedDate": component.get("v.asrCreatedDt"),
                              "onLoad": component.get("v.onLoad"),
                              "lastAsrId": component.get("v.lastAsrId")
                             });
        }
        
        
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state: '+state);
            if (state === "SUCCESS") {
                var tdata = response.getReturnValue();
                
                console.log('tdata: '+tdata.wrapASR+'----'+tdata.wrapAcc);
                console.log('accojnt string: '+component.find("AccFilter").get("v.value"));
                
                if(tdata != null) {
                    
                    var fData = [];
                   /* if(component.get("v.onKeyUp") == true) {
                        console.log('entered keyup: '+component.find("AccFilter").get("v.value"));
                        component.set("v.mydata",fData);
                        component.set("v.asrData",fData);
        				component.set("v.acctData",fData);
                        component.set("v.totalNumberOfRows",0);
                    }*/
                       // console.log('entered else'+component.get("v.mydata").length+'---'+tdata.length);
                       // var currentData = component.get("v.mydata");
                       // var newData = currentData.concat(tdata);
                        
                	//n console.log('entered enable infinite after: '+component.get("v.selectedRep"));
                        
                    if(component.get("v.selectedRep") == 'All Assigned Accounts')  {
                        if(component.get("v.onPageLoad") == true) {
                            component.set('v.restrictSalesRep', tdata.restrictSalesRep);
                          //n  console.log('tdata.isSalesRep: '+tdata.isSalesRep);
                            component.set("v.loggedId", tdata.loggedUserId);
                            component.set("v.isSalesRep", tdata.isSalesRep);
                        }
                     //n   console.log('issalesrep: '+component.get("v.isSalesRep"));
                        var newAsrData = [];
                        if(tdata.wrapASR != null) {
                            console.log('entered wrapasr');
                            var currentAsrData = component.get("v.asrData");
                            
                            newAsrData = currentAsrData.concat(tdata.wrapASR);
                            component.set("v.asrData", newAsrData);
                            
                        }
                        var newAccData = [];
                        if(tdata.wrapAcc != null) {
                            console.log('entered wrapacc');
                            var currentAccData = component.get("v.acctData");
                            newAccData = currentAccData.concat(tdata.wrapAcc);
                            component.set("v.acctData", newAccData);
                            
                        }
                        console.log('acctdata--asrdata::'+component.get("v.acctData").length+'---'+component.get("v.asrData").length);
                        /*if(component.get("v.acctData").length > 0 && component.get("v.asrData").length > 0) {
                            var totalRec = component.get("v.asrData").concat(component.get("v.acctData"));
                            component.set("v.mydata", totalRec);
                            
                        } else if(component.get("v.asrData").length > 0 && component.get("v.acctData").length == 0) {
                            component.set("v.mydata", component.get("v.asrData"));
                            
                        } else if(component.get("v.acctData").length > 0 && component.get("v.asrData").length == 0) {
                            component.set("v.mydata", component.get("v.acctData"));
                            
                        } */
                        //event.getSource().set("v.isLoading", false);
                       //n console.log('acctData: '+tdata.wrapAcc);
                        
                        console.log('component: '+component.get("v.mydata"));
                        
                        if(newAccData.length > 0) {
                            console.log('newAccData: '+'-----'+newAccData[newAccData.length - 1].accId);
                            //component.set("v.accCreatedDt", newAccData[newAccData.length - 1].accCreatedDt);
                            component.set("v.lastAccId", newAccData[newAccData.length - 1].accId);
                           // console.log('wrapasr length: '+tdata.wrapASR.length);
                            console.log('inside new acc data');
                            if(tdata.wrapAcc.length < 75 && tdata.wrapASR == null ) {
                                component.set("v.accCreatedDt", null);
                                component.set("v.lastAccId", null);
                            }
                        }
                        console.log('lastAsrId: '+component.get("v.lastAsrId")+'--newasrdata-'+newAsrData);
                        if(newAsrData.length > 0) {
                            component.set("v.asrCreatedDt", newAsrData[newAsrData.length - 1].asrCreatedDt);
                            component.set("v.lastAsrId", newAsrData[newAsrData.length - 1].asrId);
                            console.log('lastAsrId1: '+component.get("v.lastAsrId"));
                            if(tdata.wrapASR.length < 75) {
                                component.set("v.asrCreatedDt", null);
                                component.set("v.lastAsrId", null);
                            }
                        }
                       //n console.log('asrCreatedDt: '+component.get("v.asrCreatedDt"));
                        console.log('loadedAsrSize: '+component.get("v.loadedAsrSize"));
                        console.log('loadedAccSize: '+component.get("v.loadedAccSize"));
                        component.set("v.loadedAsrSize", newAsrData.length);
                      //n  console.log('loadedAsrSize: '+component.get("v.loadedAsrSize"));
                        component.set("v.loadedAccSize", newAccData.length);
                       //n console.log('loadedAccSize: '+component.get("v.loadedAccSize"));
                       //component.set("v.totAsr", tdata.totalAsrSize);
                        console.log('totalAsrSize: '+tdata.totalAsrSize);
                        console.log('totalAccSize: '+tdata.totalAccSize);
                        
                      //n  console.log('totalNumberOfRows: '+component.get("v.totalNumberOfRows"));
                        console.log('loadmore: '+component.get("v.loadMore"));
                        if(component.get("v.loadMore") == false) {
                           //n console.log('unassignAcctIds: '+tdata.unassignAccts);
                            if(component.get("v.onLoad") == true){
                                component.set("v.totAsr", tdata.totalAsrSize);
                                component.set("v.unassignAcctIds", tdata.unassignAccts);
                                component.set("v.allUnassignAcctIds", tdata.unassignAccts);
                                console.log('entered loadmore false: ');
                                component.set("v.totalNumberOfRows", tdata.totalAsrSize+tdata.totalAccSize);
                            }
                            if(component.get("v.onPageLoad") == true){
                                console.log('allTerrAccIds: '+tdata.allTerrAccIds);
                                component.set("v.allTerrAccIds", tdata.allTerrAccIds);
                                console.log('component.get("v.allTerrAccIds"): '+component.get("v.allTerrAccIds"));
                            }
                        }
                        console.log('entered isloading:');
                        if(component.get("v.onLoad") == true) {
                            component.set("v.onLoad", false);
                        }
                        if(component.get("v.onPageLoad") == true) {
                            component.set("v.onPageLoad", false);
                        }
                        console.log('after on page load:');
                        if(component.get("v.acctData").length > 0 && component.get("v.asrData").length > 0) {
                            var totalRec = component.get("v.asrData").concat(component.get("v.acctData"));
                            component.set("v.mydata", totalRec);
                            
                        } else if(component.get("v.asrData").length > 0 && component.get("v.acctData").length == 0) {
                            console.log('entered asrdata for all accounts');
                            component.set("v.mydata", component.get("v.asrData"));
                            
                        } else if(component.get("v.acctData").length > 0 && component.get("v.asrData").length == 0) {
                            component.set("v.mydata", component.get("v.acctData"));
                            
                        } 
						this.selectAllRecs(component, event);
                        event.getSource().set("v.isLoading", false);
                        //     if(component.get("v.totalNumberOfRows") == component.get("v.asrData").length+component.get("v.acctData").length) {
                             console.log('before is loading all accounts');
                        console.log('entered totalnoofrows: '+component.get("v.asrData").length+'---'+component.get("v.acctData").length);
                        
                        //  }
                        // if(component.get("v.mydata").length < 75) {
                        //   event.getSource().set("v.isLoading", false);
                        //  }
                    }
                    else if(component.get("v.selectedRep") == 'All UnAssigned Accounts')  {
                        console.log('acclenght0: '+tdata.wrapAcc.length);
                        console.log('load more unassigned: '+component.get("v.loadMore"));
                        if(component.get("v.onLoad") == true) {
                        component.set("v.onLoad", false);
                    }
                    if(component.get("v.onPageLoad") == true) {
                        component.set("v.onPageLoad", false);
                    }
                        if(component.get("v.loadMore") == false) {
                            console.log('totalaccsize: '+tdata.totalAccSize);
                            console.log('accCreatedDt[0]: '+tdata.wrapAcc[0].accCreatedDt);
                            component.set("v.totalNumberOfRows",tdata.totalAccSize);
                        	component.set("v.mydata", tdata.wrapAcc);
                            console.log('acccreateddate: '+tdata.wrapAcc[tdata.wrapAcc.length - 1].accCreatedDt);
                            component.set("v.accCreatedDt",tdata.wrapAcc[tdata.wrapAcc.length - 1].accCreatedDt);
                            component.set("v.lastAccId",tdata.wrapAcc[tdata.wrapAcc.length - 1].accId);
                            console.log('accCreatedDate0: '+component.get("v.accCreatedDt"));
                            event.getSource().set("v.isLoading", false);
                            
                        } else {
                            if(tdata.wrapAcc.length < 75) {
                                console.log('acclenght: '+tdata.wrapAcc.length);
                                var currData = component.get("v.mydata");
                                var newUnassignedData = currData.concat(tdata.wrapAcc);
                                component.set("v.mydata", newUnassignedData);
                                component.set("v.accCreatedDt", null);
                                component.set("v.lastAccId",null);
                                component.set("v.onLoad", false);
                                console.log('onload '+component.get("v.onLoad"));
                                var fullrows = component.get("v.mydata");
                                var rowids = [];
                                for(var i=0; i<fullrows.length; i++) {
                                    rowids.push(fullrows[i].accId);
                                }
                                console.log('rowids: '+rowids);
                                event.getSource().set("v.isLoading", false);
                                component.set("v.enableInfiniteLoading", false);
                                
                               // event.getSource().set("v.isLoading", false);
                            } else {
                                console.log('entered else createddate');
                                component.set("v.accCreatedDt",tdata.wrapAcc[tdata.wrapAcc.length - 1].accCreatedDt);
                                component.set("v.lastAccId", tdata.wrapAcc[tdata.wrapAcc.length - 1].accId);
                                var currData = component.get("v.mydata");
                                var newUnassignedData = currData.concat(tdata.wrapAcc);
                                component.set("v.mydata", newUnassignedData);
                               /* if(component.get("v.onLoad") == true) {
                                    component.set("v.onLoad", false);
                                }
                                if(component.get("v.onPageLoad") == true) {
                                    component.set("v.onPageLoad", false);
                                }*/
                                this.selectAllRecs(component, event);
                                event.getSource().set("v.isLoading", false);
                            }
                        }
                        console.log('accCreatedDate: '+component.get("v.accCreatedDt"));
                        //if(component.get("v.mydata").length < 50) {
                                //event.getSource().set("v.isLoading", false);
                          //  }
                        console.log('entered loading');
            
                        
                    }
                    
                    else if(component.get("v.selectedRep") != 'All UnAssigned Accounts' && component.get("v.selectedRep") != 'All Assigned Accounts') {
                        if(component.get("v.onLoad") == true) {
                        	component.set("v.onLoad", false);
                    	}
                    	if(component.get("v.onPageLoad") == true) {
                        	component.set("v.onPageLoad", false);
                    	}
                        if(component.get("v.loadMore") == false) {
                        	component.set("v.mydata", tdata.wrapASR);
                            component.set("v.totalNumberOfRows", tdata.totalAsrSize);
                            component.set("v.asrCreatedDt",tdata.wrapASR[tdata.wrapASR.length - 1].asrCreatedDt);
                            component.set("v.lastAsrId",tdata.wrapASR[tdata.wrapASR.length - 1].asrId);
                            this.selectAllRecs(component, event);
                            event.getSource().set("v.isLoading", false);
                            if(tdata.wrapASR.length < 75) {
                                console.log('entered if 75 loadmore if');
                                this.selectAllRecs(component, event);
                                event.getSource().set("v.isLoading", false);
                                component.set("v.enableInfiniteLoading", false);
                                component.set("v.lastAsrId", null);
                            }
                        } else {
                            console.log('after else length: '+component.get("v.mydata"));
                            if(tdata.wrapASR.length < 75) {
                                var currData = component.get("v.mydata");
                                var newAssignedData = currData.concat(tdata.wrapASR);
                                component.set("v.mydata", newAssignedData);
                                component.set("v.asrCreatedDate", null);
                                component.set("v.lastAsrId", null);
                                this.selectAllRecs(component, event);
                                event.getSource().set("v.isLoading", false);
                                component.set("v.enableInfiniteLoading", false);
                                
                                
                            } else {
                                console.log('entered else asr: '+tdata.wrapASR[tdata.wrapASR.length - 1].asrId);
                                //component.set("v.asrCreatedDate",tdata.wrapASR[tdata.wrapASR.length - 1].asrCreatedDt);
                                component.set("v.lastAsrId",tdata.wrapASR[tdata.wrapASR.length - 1].asrId);
                                var currData = component.get("v.mydata");
                                var newAssignedData = currData.concat(tdata.wrapASR);
                                component.set("v.mydata", newAssignedData);
                                this.selectAllRecs(component, event);
                                event.getSource().set("v.isLoading", false);
                            }
                        }
                        
            			//event.getSource().set("v.isLoading", false);
                        
                        
                    }
                    /*var recs = [];
                    if(component.find("selectallrec").get("v.checked") == true) {
                        
                        var data = component.get("v.mydata");
                        console.log('data; '+data);
                        console.log('selectedrep: '+component.get("v.selectedRep"));
                        //var totalRec = component.get("v.totalNumberOfRows");
                        //component.set("v.recSelected", totalRec);
                        if(component.get("v.selectedRep") == 'All Assigned Accounts') {
                            for(var i = 0; i<data.length; i++) {
                                recs.push(data[i].uniqfield);
                            }
                        } else if(component.get("v.selectedRep") == 'All UnAssigned Accounts') {
                            component.set("v.keyfield", "accId");
                            for(var i = 0; i<data.length; i++) {
                                recs.push(data[i].accId);
                            }
                        } else {
                            component.set("v.keyfield", "asrId");
                            for(var i = 0; i<data.length; i++) {
                                recs.push(data[i].asrId);
                                
                            }
                        }
                    }
                    component.set("v.selRows", recs);*/
                    this.selectAllRecs(component, event);
                    	//component.set("v.Spinner", false);
                   // event.getSource().set("v.isLoading", false);
                        //component.set("v.totalNumberOfRows",newData.length);
                    console.log('datamy: '+component.get("v.mydata").length);
                        
                /*    if(component.get("v.onLoad") == true) {
                        component.set("v.onLoad", false);
                    }
                    if(component.get("v.onPageLoad") == true) {
                        component.set("v.onPageLoad", false);
                    }*/
                    
                        
                    component.set("v.loadMoreStatus", '');
                    //event.getSource().set("v.isLoading", false);
                    console.log('loadMoreStatus onload: '+component.get("v.onLoad"));
                    
                   
                } else {
                    
                        component.set("v.noRecordsError","No records to display");
                    
                    
                }
                
                
               
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
                component.set("v.noResults", "An error occurred: No records to display");
                component.set("v.enableInfiniteLoading", false);
                
            }
            
        });
        
        $A.enqueueAction(action);
        
    },
    
    concatData : function(component, event) {
        var currentData = component.get("v.mydata");
        if(component.get("v.LoadedAllRecords")) {
            event.getSource().set("v.isLoading", false);
            component.set("v.enableInfiniteLoading", false);
        }
        var totalData = currentData.concat(component.get("v.remainingRec"));
        console.log('totalData: '+totalData.length);
        component.set("v.mydata",totalData);
        component.set("v.totalNumberOfRows",totalData.length);
        
        //event.getSource().set("v.isLoading", false);
    },
    
    getSalesReps : function(component, event, helper) {
		var action2 = component.get("c.getACHUsers");
           
            action2.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var options=[];
                    options.push({id: 'All Assigned Accounts', label: 'All Accounts', selected: true});
                    options.push({id: 'All UnAssigned Accounts', label: 'All UnAssigned Accounts'});
                    
                    if(response.getReturnValue() != null) {
                        var retVal = response.getReturnValue();
                        
                        for(var i=0; i<retVal.length; i++) {
                            options.push({id: retVal[i].Id, label: retVal[i].FirstName+' '+retVal[i].LastName});
                        }
                    }
                    component.set("v.srOptions", options);
                }
            });
        $A.enqueueAction(action2);        
    },
    
    
    
    reAssignSalesRep : function(component, event) {
        console.log('asrlength: '+component.get("v.reAssignUnAssignIds").length+'---'+component.get("v.selectedRep"));
        if((component.get("v.reAssignUnAssignIds").length > 0 || component.find("selectallrec").get("v.checked") == true) && component.get("v.selectedRep") != 'All UnAssigned Accounts' && component.get("v.selectedRep") != 'All Assigned Accounts') {
            component.set("v.showModal", true);
            $A.createComponent("c:Vgtna_ACHUsersModal", {
                
                'openModal' : true,
                'selectedRecs' : component.get("v.reAssignUnAssignIds"),
                'newASR' : false,
                'selectAllRecs':component.find("selectallrec").get("v.checked"),           
                'salesRepFilter':component.get("v.selectedRep"),
                'cityFilter':component.find("cityname").get("v.value"),
                'countyFilter':component.find("countyname").get("v.value"),
                'zipcodeFilter':component.find("zipcodename").get("v.value"),
                'AccFilter':component.find("AccFilter").get("v.value")
                
            },
            function(modalComponent) {
                                   
                if (component.isValid()) {
                    //Appending the newly created component in div
                    var body = component.find( 'showSalesRepList' ).get("v.body");
                    body.push(modalComponent);
                    component.find( 'showSalesRepList' ).set("v.body", body);
                }
            });
           // helper.showNotification(component, 'Success!', 'Selected ASR\'s are assigned to the selected Sales Rep', 'success');
        } else if(component.get("v.selectedRep") == 'None' || component.get("v.selectedRep") == 'Unassigned Accounts'){
            console.log('entered else if: '+component.get("v.selectedRep"));
            this.showNotification(component, 'Info!', 'Please select valid sales rep to reassign the ASR', 'info');
        } else if(component.get("v.reAssignUnAssignIds").length == 0){
            console.log('entered else if: '+component.get("v.reAssignUnAssignIds").length);
            this.showNotification(component, 'Info!', 'Please select at least 1 ASR', 'info');
        }
    },
    
    
    unAssignSalesRep : function(component, event) {
        var action = component.get('c.UnAssignSalesReps');
        action.setParams({"asrIds" : component.get("v.selectedASRs"),
                          "selectAllRecs" : component.find("selectallrec").get("v.checked"),
                          "salesRepFilter" : component.get("v.selectedRep")
                          });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state: '+state);
            if (state === "SUCCESS") {
                console.log('entered state if: ');
                if(response.getReturnValue() != null) {
                    console.log('entered deleted');
                    this.showNotification(component, 'Success!', 'Removed the selected assignment', 'success');
                    window.location.reload();
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    selectAllRecs : function(component, event) {
        var recs = [];
        if(component.find("selectallrec").get("v.checked") == true) {
            var totalRec = component.get("v.totalNumberOfRows");
            component.set("v.recSelected", totalRec);
            var data = component.get("v.mydata");
            console.log('data; '+data);
            console.log('selectedrep: '+component.get("v.selectedRep"));
            //var totalRec = component.get("v.totalNumberOfRows");
            //component.set("v.recSelected", totalRec);
            if(component.get("v.selectedRep") == 'All Assigned Accounts') {
                for(var i = 0; i<data.length; i++) {
                    recs.push(data[i].uniqfield);
                }
            } else if(component.get("v.selectedRep") == 'All UnAssigned Accounts') {
                component.set("v.keyfield", "accId");
                for(var i = 0; i<data.length; i++) {
                    recs.push(data[i].accId);
                }
            } else {
                component.set("v.keyfield", "asrId");
                for(var i = 0; i<data.length; i++) {
                    recs.push(data[i].asrId);
                    
                }
            }
        }
        component.set("v.selRows", recs);
    },
    
    convertArrayOfObjectsToCSV : function(component,objectRecords){
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        console.log('objrec: '+objectRecords.length);
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
 
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        keys = ['accountName','assignedReps','PartyId','street','city','county','state','country','postalCode' ];
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
        console.log('orlenght:'+objectRecords.length);
        var z;
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
           
             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
 
              // add , [comma] after every String value,. [except first]
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
               
               csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
               
               counter++;
 
            } // inner for loop close 
             csvStringResult += lineDivider;
            z = i;
            //counter++;
          }// outer main for loop close 
        console.log('counter: '+counter+'----'+z);
       // return the CSV formate String 
        return csvStringResult;        
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