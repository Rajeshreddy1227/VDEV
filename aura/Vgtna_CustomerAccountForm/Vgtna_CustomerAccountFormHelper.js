({
	// this helper function makes the apex web service callout
    getTempResponse: function(component,valueName,valueStreet,valueCity,valueState,valueZip,valueCountry) {
        
        // check if ignore errors
        var isIgnoreErrorCheck = component.get("v.isIgnoreErrors");
       // alert("isIgnoreErrorCheck: "+isIgnoreErrorCheck);
       // start spinner
         $A.enqueueAction(component.get('c.showSpinner'));
        // create a server side action.       
        var action = component.get("c.getCalloutResponseContents");
       
        // set the  parameters for getCalloutResponseContents method  
        action.setParams({
            "accName": valueName,
            "accStreet": valueStreet,
            "accCity": valueCity,
            "accState": valueState,
            "accZip": valueZip,
            "accCountry": valueCountry,
            "ignoreCleanse": isIgnoreErrorCheck,
            "ignoreMatch": false
        });
        action.setCallback(this, function(response) {
            // stop spinner
            $A.enqueueAction(component.get('c.hideSpinner'));
            var state = response.getState();
          //  alert("Webservice Callout Status: "+state);
            
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue()!=null) {
                               
               // component.set("v.CallOutState", state);
               // alert(response.getReturnValue());
                var respcode = response.getReturnValue();               
               // component.set("v.isCallOutMade", true);
                
                if(respcode == '300')
                {
                     		var action300 = component.get("c.getList");
                            action300.setParams({
                            "accName": valueName,
                            "accStreet": valueStreet,
                            "accCity": valueCity,
                            "accState": valueState,
                            "accZip": valueZip,
                            "accCountry": valueCountry,
                            "ignoreCleanse": isIgnoreErrorCheck,
                            "ignoreMatch": false
                        });
                    action300.setCallback(this, function(response) {
                    		var state300 = response.getState();
                     
                            component.set("v.ListOfResponse", response.getReturnValue());
                               var r2 =[];
                               r2 = component.get("v.ListOfResponse"); 
                               
                                
                                r2.push({
                                    name: valueName,
                                              FMVName: '',
                                              stateProv: valueState,
                                              zipCode: valueZip,
                                              country: valueCountry,
                                              address: valueStreet,
                                              FMVID: '',
                                              city: valueCity,                     
                                              alias: '',
                                              partyID: '',
                                              usDotId: ''
                                  });
                                
                                component.set("v.ListOfResponse", r2); 
                                component.set("v.CallOutState", state);
                                component.set("v.isCallOutMade", true);
                        		var duplicateWarningLabel = $A.get("$Label.c.Vgtna_CDB_Duplicate_Message");	                                
                                component.set("v.duplicateWarning", duplicateWarningLabel);
                          });
                    
                    $A.enqueueAction(action300);
                }
                
                if(respcode == '200')
                {
                     		var action200 = component.get("c.getMap");
                            action200.setParams({
                            "accName": valueName,
                            "accStreet": valueStreet,
                            "accCity": valueCity,
                            "accState": valueState,
                            "accZip": valueZip,
                            "accCountry": valueCountry,
                            "ignoreCleanse": isIgnoreErrorCheck,
                            "ignoreMatch": false
                        });
                    action200.setCallback(this, function(response) {
                    		var state200 = response.getState();
                     
                            component.set("v.ListOfResponse", response.getReturnValue());
                            component.set("v.CallOutState", state);
                            component.set("v.isCallOutMade", true);
                          });
                    
                    $A.enqueueAction(action200);
                }
                
                if(respcode == '400')
                {
                     		var action400 = component.get("c.getList");
                            action400.setParams({
                            "accName": valueName,
                            "accStreet": valueStreet,
                            "accCity": valueCity,
                            "accState": valueState,
                            "accZip": valueZip,
                            "accCountry": valueCountry,
                            "ignoreCleanse": isIgnoreErrorCheck,
                            "ignoreMatch": false
                        });
                    action400.setCallback(this, function(response) {
                    		var state400 = response.getState();
                     		component.set("v.Response400", response.getReturnValue());                        	
                            var resp400 = response.getReturnValue();
                            //alert("Response for 400:"+JSON.stringify(resp400));
                            var r400 =[];
                            r400 = component.get("v.Response400");
                            var i;
                        	for(i=0;i<r400.length;i++)
                                {
                                    if(r400[i].Code =="1")
                                    {
                                       var code1ErrorLabel = $A.get("$Label.c.Vgtna_Response_400_Code_1");			
            						   component.set("v.Response400Code1", code1ErrorLabel); 
                                    }
                                    if(r400[i].Code =="2")
                                    {
                                       var code2ErrorLabel = $A.get("$Label.c.Vgtna_Response_400_Code_2");			
            						   component.set("v.Response400Code2", code2ErrorLabel);  
                                    }
                                    if(r400[i].Code =="3")
                                    {
                                       var code3ErrorLabel = $A.get("$Label.c.Vgtna_Response_400_Code_3");			
            						   component.set("v.Response400Code3", code3ErrorLabel);  
                                    }
                                    if(r400[i].Code =="4")
                                    {
                                       var code4ErrorLabel = $A.get("$Label.c.Vgtna_Response_400_Code_4");			
            						   component.set("v.Response400Code4", code4ErrorLabel);  
                                    }
                                    if(r400[i].Code =="5")
                                    {
                                       var code5ErrorLabel = $A.get("$Label.c.Vgtna_Response_400_Code_5");			
            						   component.set("v.Response400Code5", code5ErrorLabel);  
                                    }
                                    if(r400[i].Code =="6")
                                    {
                                       var code6ErrorLabel = $A.get("$Label.c.Vgtna_Response_400_Code_6");			
            						   component.set("v.Response400Code6", code6ErrorLabel);  
                                    }
                                    if(r400[i].Code !="1" && r400[i].Code !="2" && r400[i].Code !="3" && r400[i].Code !="4" && r400[i].Code !="5" && r400[i].Code !="6")
                                    {
                                        var unhandledErrorLabel = $A.get("$Label.c.Vgtna_Unhandled_Error_Response");	
                                        var concat = unhandledErrorLabel + ' Response Code 400 Match Code: '+r400[i].Code;
                                        component.set("v.unhandledResponse", concat);  
                                    }
                                }                        		
                                component.set("v.isCallOutMade", false);
                        		component.set("v.isResponse400", true);
                          });
                    
                    $A.enqueueAction(action400);
                }  
                
                if(respcode.length > 3)
                {
                    // it is 201 returning created party id.
                    this.insertNewAccount(component,valueName,valueStreet,valueCity,valueState,valueZip,valueCountry,respcode);
                }
                
                if(respcode == '500')
                {
                    // None of the above codes
                    
                    var resp500ErrorLabel = $A.get("$Label.c.Vgtna_CDB_Code_500");	                    
            		component.set("v.unhandledResponse", resp500ErrorLabel);
                    component.set("v.isCallOutMade", false);
                    
                }
                
                if(respcode.length == 3 && respcode != '200'&& respcode != '300'&& respcode != '400'&& respcode != '500')
                {
                    // None of the above codes
                    
                    var unhandledErrorLabel = $A.get("$Label.c.Vgtna_Unhandled_Error_Response");	
                    var concat = unhandledErrorLabel + respcode;
            		component.set("v.unhandledResponse", concat);
                    component.set("v.isCallOutMade", false);
                    
                }
                
                
            }
            else
            {
               // stop spinner
                $A.enqueueAction(component.get('c.hideSpinner'));
                 var respcode = response.getReturnValue();
                 var unhandledErrorLabel = $A.get("$Label.c.Vgtna_Unhandled_Error_Response");	
                 var concat = unhandledErrorLabel + state;
            	 component.set("v.unhandledResponse", concat);
                 component.set("v.isCallOutMade", false); 
                 component.set("v.CallOutState", state);
            }
            
            
       
        });
 
         $A.enqueueAction(action);
    },
    
    // when the user wants to ignore all suggestions and save his choice this helper function ignores cleanse and match and calls apex webservice
    generatePartyID: function(component,valueName,valueStreet,valueCity,valueState,valueZip,valueCountry) {
        
        // start spinner
         $A.enqueueAction(component.get('c.showSpinner'));
        // create a server side action.       
        var action = component.get("c.getCalloutResponseContents");
       
        // set the  parameters for getCalloutResponseContents method  
        action.setParams({
            "accName": valueName,
            "accStreet": valueStreet,
            "accCity": valueCity,
            "accState": valueState,
            "accZip": valueZip,
            "accCountry": valueCountry,
             "ignoreCleanse": true,
             "ignoreMatch": true
        });
        action.setCallback(this, function(response) {
            // stop spinner
           	$A.enqueueAction(component.get('c.hideSpinner'));
            var state = response.getState();
          //  alert("Webservice Callout Status: "+state);
            
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue()!=null) {
                
              //component.set("v.CallOutState", state);
               // alert(response.getReturnValue());
                var respcode = response.getReturnValue();               
               // component.set("v.isCallOutMade", true);
                if(respcode.length > 3)
                {
                    // it is 201 returning created party id.
                    this.insertNewAccount(component,valueName,valueStreet,valueCity,valueState,valueZip,valueCountry,respcode);
                }
                if(respcode.length == 3)
                {
                    // 201 should be sending party id so this must be other error.
                    
                    var unhandledErrorLabel = $A.get("$Label.c.Vgtna_Unhandled_Error_Response");	
                    var concat = unhandledErrorLabel + respcode;
            		component.set("v.unhandledResponse", concat); 
                   
                    
                }
            }
        });
 
        $A.enqueueAction(action);
    },
    
    // this is a generic helper function to call apex code to perform DML operation to upsert account to salesforce database.
    insertNewAccount : function(component,valueName,valueStreet,valueCity,valueState,valueZip,valueCountry,valuePartyid)
    {
        //alert('I AM HERE'+ valuePartyid);
        var createdAccountId;
        //var val = Math.floor(1000 + Math.random() * 9000);
        //alert(valuePartyid + val);
        var action2 = component.get("c.upsertAccount");
       
                          action2.setParams({                              
                              "name": valueName,
                              "rtid": component.get("v.recType"),
                              "state": valueState,
                              "zip": valueZip,
                              "code": valueCountry,
                              "city": valueCity,
                              "street": valueStreet,
                              "partyid": valuePartyid                                   
                          });
        
                        action2.setCallback(this, function(response){
                             createdAccountId = response.getReturnValue();
                           // alert("createdAccountId: "+createdAccountId);
                            if(createdAccountId == 'No Access rights to create or update Accounts')
                            {
                                var insufficientPrivilegeLabel1 = $A.get("$Label.c.Vgtna_CDB_Insufficient_Privilege_Error");			            					
                               //alert(insufficientPrivilegeLabel);
                                component.set("v.error",insufficientPrivilegeLabel1);
                               // var lab = component.get("v.error");
                               // alert(lab);
                                component.find("outputRadioTextId").set("v.class", "textClass");
                            }
                            if(createdAccountId.substring(0,3) == "001")
                            {
                                   // alert("createdAccountId-->"+createdAccountId);
                                var navEvt1 = $A.get("e.force:navigateToSObject");
                              // alert("createdAccountId-->"+createdAccountId);
                                navEvt1.setParams({                    
                                  "recordId": createdAccountId//,
                                 // "slideDevName": "related"
                                });
                                navEvt1.fire();
                            }
                            else
                            {
                                 component.set("v.error", createdAccountId);
                                component.find("outputRadioTextId").set("v.class", "textClass");
                            }
                            
                           
                           
                        });
                
                 $A.enqueueAction(action2);
    }
    
})