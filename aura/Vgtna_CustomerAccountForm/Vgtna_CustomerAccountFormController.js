({
	doInit : function(component, event, helper) {       
       var action = component.get("c.getPickListValuesIntoList");
        action.setParams({
            objectType: "Account",
            selectedField: "BillingCountryCode"
        });
        
        action.setCallback(this, function(response) {
            var list = response.getReturnValue();             
            component.set("v.picklistValues", list);
        })
        $A.enqueueAction(action);
        
        var stateaction = component.get("c.getPickListValuesIntoList");
        stateaction.setParams({
            objectType: "Account",
            selectedField: "BillingStateCode"
        });
        stateaction.setCallback(this, function(response) {
            var statelist = response.getReturnValue();
            component.set("v.statepicklistValues", statelist);
        })
        $A.enqueueAction(stateaction);
        
        
	},
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    },
   
 // this function is used to close the modal window and redirect to object or community home on cancel
    hideModal : function(component,event, helper){
        var src= component.get("v.source");
        console.log('hide modal');
        if(src != 'Community')
        {
            document.getElementById("newClientSectionId").style.display = "none" ;
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": "/001/o"
             });
           
        }
        else
        {
           
            console.log('back to Community URL ->'+ window.location.href);
            var staticLabelCommURL = $A.get("$Label.c.Vgtna_Dealer_Community_URL");
            var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
              "url": window.location.href
             });
        }
        
        
        urlEvent.fire();
    },   
    
    // this function is used to redirect to the creation form and resets basically all flags and errors invoked on "Previous" button click
    goPrevious: function (component, event, helper){
        component.set("v.isCallOutMade", false);
        component.set("v.error", "");
        component.set("v.Response400Code1", "");
        component.set("v.Response400Code2", "");
        component.set("v.Response400Code3", "");
        component.set("v.Response400Code4", "");
        component.set("v.Response400Code5", "");
        component.set("v.Response400Code6", "");
        component.set("v.unhandledResponse", "");
        component.set("v.isIgnoreErrors", false);
        component.set("v.isResponse400", false);
        component.set("v.disableTryAgain", false);
        component.set("v.duplicateWarning", "");
    },
    
    // this function checks if atleast one field in the create form is changed to enable "Try Again" button
    checkInput : function (component, event, helper){
        var is400 = component.get("v.isResponse400");
        if(is400 == true)
        {
            component.set("v.disableTryAgain", false);
        }
        
    },
    
    // this function sets ignore cleanse value to true for callout and is invoked by "Ignore Errors" button
    ignoreErrors : function (component, event, helper){
        component.set("v.isIgnoreErrors", true);       
        $A.enqueueAction(component.get('c.makeTempCallOut'));
    },
  
    // this function is invoked on Next" to make the webservice callout
    makeTempCallOut : function (component, event, helper){
        	
        // Resetting all flags and messages
        
        component.set("v.isCallOutMade", false);
        component.set("v.error", "");
        component.set("v.Response400Code1", "");
        component.set("v.Response400Code2", "");
        component.set("v.Response400Code3", "");
        component.set("v.Response400Code4", "");
        component.set("v.Response400Code5", "");
        component.set("v.Response400Code6", "");
        component.set("v.unhandledResponse", "");
        component.set("v.duplicateWarning", "");
       // component.set("v.isIgnoreErrors", false);
      //  component.set("v.isResponse400", false);
       // component.set("v.disableTryAgain", false);
        
        var valueName=component.get("v.newAcc.Name");
        var valueCity=component.get("v.newAcc.BillingCity");
        
        var valueStreet=component.get("v.newAcc.BillingStreet");
        var valueZip=component.get("v.newAcc.BillingPostalCode");
       // var valueCountry=component.find("AccountCountry1").get("v.value");
        var valueCountry = component.get("v.newAcc.BillingCountry");
        
        //var valueState=component.find("AccountState").get("v.value"); 
        var valueState = component.get("v.newAcc.BillingState");
        
       
        if(valueName == ''|| valueCity == '' || valueCity == null ||valueStreet == ''||valueZip == ''||valueStreet == null||valueZip == null || valueCountry == ''||valueState == '')
        {
            var formErrorLabel = $A.get("$Label.c.Vgtna_CDB_Form_Mandatory_Check");			
            component.set("v.error", formErrorLabel);
           // component.set("v.error", "Error: Please fill all mandatory fields.");         
        	//component.find("outputErrorTextId").set("v.class", "textClass");
        }
        else
        {
            
             // making the webservice Callout
            helper.getTempResponse(component,valueName,valueStreet,valueCity,valueState,valueZip,valueCountry);
        }
    },
   
    // this function is invoked by "Save" button to perform DML operation within salesforce
   saveAccount : function (component, event, helper){
        var createdAccountId;
        component.set("v.error", "");
        var accDet;
        if(component.get("v.CallOutState") == 'SUCCESS')
        {
            accDet = document.querySelector('input[name="accRealRecordRadio"]:checked');
        }
        else
        {
            accDet = document.querySelector('input[name="accRecordRadio"]:checked');
        }
         
       // alert("accDet: "+accDet);
        if(accDet != null)
        {
             var recValue = accDet.value;
                    var recName = accDet.id;
                    var fullData;
                    var selectedState;
                    var selectedZip;
                    var selectedCountry;
                    var selectedStreet;
                    var selectedCity;
                    var selectedCountryCode;
                        if(component.get("v.CallOutState") == 'SUCCESS')
                        {
                            fullData= component.get("v.ListOfResponse");
                            
                            // Get data from selected response
                            
                            for (var i = 0; i < fullData.length; i++)
                               {
                                   if(recName == fullData[i].name && recValue == fullData[i].partyID)
                                   {
                                       
                                       selectedState = fullData[i].stateProv;
                                       selectedZip = fullData[i].zipCode;
                                      
                                       
                                       if(fullData[i].country == 'USA' || fullData[i].country == 'US' || fullData[i].country == 'United States'|| fullData[i].country == 'UNITED STATES')
                                       {
                                           //selectedCountry = 'United States';
                                           selectedCountryCode = 'US';
                                       }
                                       if(fullData[i].country == 'Canada' || fullData[i].country == 'CA' || fullData[i].country == 'CANADA' )
                                       {
                                          // selectedCountry = 'Canada';
                                           selectedCountryCode = 'CA';
                                           
                                       }
                                       else
                                       {
                                         // selectedCountry = fullData[i].country;
                                       }
                                       
                                       selectedStreet = fullData[i].address;
                                       selectedCity = fullData[i].city;
                                       break;
                                   }
                               } 
                        }
                        else
                        {
                            fullData= component.get("v.mydata");
                            
                            // Get Data from User Input
                            
                             for (var i = 0; i < fullData.length; i++)
                               {
                                   if(recName == fullData[i].Name && recValue == fullData[i].partyID)
                                   {
                                      
                                       selectedState = fullData[i].BillingState;
                                       selectedZip = fullData[i].BillingPostalCode;
                                       	//alert("fullData[i].BillingCountry->"+fullData[i].BillingCountry);
                                       
                                          if(fullData[i].BillingCountry == 'USA' || fullData[i].BillingCountry == 'US' || fullData[i].BillingCountry == 'United States')
                                           {
                                              // selectedCountry = "United States";
                                               selectedCountryCode = "US";
                                           }
                                           if(fullData[i].BillingCountry == 'Canada' || fullData[i].BillingCountry == 'CA' )
                                           {
                                               //selectedCountry = 'Canada';
                                               selectedCountryCode = 'CA';
                                               
                                           }
                                           else
                                           {
                                              //selectedCountry = fullData[i].BillingCountry;
                                           }
                                      
                                       selectedStreet = fullData[i].BillingStreet;
                                       selectedCity = fullData[i].BillingCity;
                                       break;
                                   }
                               }  
                        }
                    
                  // upsert based on party id
                  
                    if(recValue != '' && recValue !=null)
                    {
                         //alert(recName+selectedState+selectedZip+selectedCity+selectedStreet+recValue+selectedCountryCode);
                       // start spinner
        					 $A.enqueueAction(component.get('c.showSpinner'));
                        var action1 = component.get("c.upsertAccount");
                          action1.setParams({ 
                              "name": recName,
                              "rtid": component.get("v.recType"),
                              "state": selectedState,
                              "zip": selectedZip,
                              "code": selectedCountryCode,
                              "city": selectedCity,
                              "street": selectedStreet,
                              "partyid": recValue                                    
                          });
                        action1.setCallback(this, function(response){
                            // stop spinner
           					 $A.enqueueAction(component.get('c.hideSpinner'));
                             createdAccountId = response.getReturnValue();
                            //alert("createdAccountId: "+createdAccountId);
                            if(createdAccountId == 'No Access rights to create or update Accounts')
                            {
                                var insufficientPrivilegeLabel = $A.get("$Label.c.Vgtna_CDB_Insufficient_Privilege_Error");			            					
                              // alert(insufficientPrivilegeLabel);
                                component.set("v.error",insufficientPrivilegeLabel);
                                var lab = component.get("v.error");
                                //alert(lab);
                                component.find("outputRadioTextId").set("v.class", "textClass");
                            }
                            if(createdAccountId.substring(0,3) == "001")
                            {
                                    //alert("createdAccountId-->"+createdAccountId);
                                var navEvt = $A.get("e.force:navigateToSObject");
                              // alert("createdAccountId-->"+createdAccountId);
                                navEvt.setParams({                    
                                  "recordId": createdAccountId//,
                                  //"slideDevName": "Detail"
                                });
                                navEvt.fire();
                            }
                            else
                            {
                                 component.set("v.error", createdAccountId);
                                component.find("outputRadioTextId").set("v.class", "textClass");
                            }
                           
                        });
                          
                          $A.enqueueAction(action1);
                    }
                    else
                    {
                        // Integration logic to call back the service and stamp party id
                       // alert("Work in Progress");
                       var confirmLabel = $A.get("$Label.c.Vgtna_CDB_Confirm_Box_Message");	
                        var isProceed = confirm(confirmLabel);
                        if(isProceed == true)
                        {
                            helper.generatePartyID(component,recName,selectedStreet,selectedCity,selectedState,selectedZip,selectedCountryCode);
                        }
                        
                    }
            
   
        }
       else
        {
            var selectionErrorLabel = $A.get("$Label.c.Vgtna_CDB_force_record_selection");			
            component.set("v.error", selectionErrorLabel);
            //component.set("v.error", "Error: Please make one selection.");
        	component.find("outputRadioTextId").set("v.class", "textClass");
        }
                   
                   
   }          
  
})