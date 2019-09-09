({
    
    doInit : function(component, event, helper) {
        //alert("Hello");
        var accountId= component.get("v.recordId");
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                
                
                var storeResponse = response.getReturnValue();
                // set current user information on userInfo attribute
                component.set("v.userInfo", storeResponse);
                
                var isCommunityUser = component.get("v.userInfo.IsPortalEnabled");
                
                if(isCommunityUser == false)
                {
                    // Internal user should not get to this page.
                    var staticLabelInternalUserMsg = $A.get("$Label.c.Customer_Profile_Internal_User_Message");
                    alert(staticLabelInternalUserMsg);
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": accountId
                    });
                    navEvt.fire();
                }
                else
                {
                    // Community user so check if he has a dealer code
                    var userDealerCode = component.get("v.userInfo.Dealer_Code__c");
                    if(userDealerCode == null || userDealerCode == '')
                    {
                        // If User Dealer Code is blank
                        var staticLabelExternalUserMsg = $A.get("$Label.c.Customer_Profile_External_User_Access_denied_Message");
                        alert(staticLabelExternalUserMsg);
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": accountId
                        });
                        navEvt.fire();
                    }
                    else
                    {
                          // Dealer User and has dealer id
                        	var actiondc = component.get("c.getCustomerProfile");
                            actiondc.setParams({
                            "accountId": accountId,
                            "dealerCode": userDealerCode
                            });
                            
                            actiondc.setCallback(this, function(response){
                              
                                var statedc = response.getState();
                                if (statedc === "SUCCESS")
                                {
                                    var customerProfileID = response.getReturnValue();
                                    //alert(customerProfileID);
                                    if(customerProfileID == 'Insufficient privilege')
                                    {
                                          var staticLabelExternalUserMsg = $A.get("$Label.c.Customer_Profile_External_User_Access_denied_Message");
                        					alert(staticLabelExternalUserMsg);
                                            var navEvt = $A.get("e.force:navigateToSObject");
                                            navEvt.setParams({
                                                "recordId": accountId
                                            });
                                            navEvt.fire();
                                    }
                                    else if(customerProfileID.substring(0,3) == "001")
                                    {
                                        // customer profile record not present. Take to create screen
                                         var createRecordEvent = $A.get("e.force:createRecord");
                                            createRecordEvent.setParams({
                                                "entityApiName": "Customer_Profile__c",
                                                "defaultFieldValues"    : {
                                                 'Customer_Account__c' : accountId,
                                                    'Dealer_Account__c': customerProfileID
                                        		}  
                                            });
                                            createRecordEvent.fire();
                                        
                                    }
                                    else
                                    {
                                        // Customer Profile record present for the dealership
                                        var navEvtdc = $A.get("e.force:navigateToSObject");
                                        navEvtdc.setParams({
                                            "recordId": customerProfileID
                                        });
                                        navEvtdc.fire();
                                    }
                                    
                                }
                               
                            });
                                              
                         $A.enqueueAction(actiondc); 
                    }
                                     
                }
                
            }
            // close modal window
                 var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
		            
        });
        $A.enqueueAction(action);
        
        /**  var userId = $A.get("$SObjectType.CurrentUser.IsPortalEnabled");
     //Find the text value of the component with aura:id set to "address"
     //var address = '/s/detail/'+recordId;
     var accountId= component.get("v.recordId");
     var action = component.get("c.getCustomerProfileId");
                action.setParams({
                    "accountId": accountId
                });
     var storeResponse;
     var customerProfileId;
     action.setCallback(this, function(response) {

       var state = response.getState();
       if (state === "SUCCESS") { 
           // Get UserType

              // end
         storeResponse = response.getReturnValue();
       //  var kv = new Map(storeResponse);
         var userType;
         var myId;
         console.log('back from Server, customer profile:' + storeResponse.toString()); 
       //  console.log('here ' + kv);
           for (var key in storeResponse) {
             //let prof = map[key];
             console.log('Key:' + key ); 
             userType = key;
             myId = storeResponse[key];
             console.log('Val:' + myId ); 

           }
          if (myId==null)      
                       window.location.reload(); 

//         component.set("v.customerProfileId", storeResponse.get('PowerPartner'));
         component.set("v.customerProfileId", myId);
 	// customerProfileId = component.get("v.customerProfileId");
 	var address;
    if (userType != 'PowerPartner')
 	// https://dev0-vgtna-dev0.cs50.force.com/s/customer-profile/a043B000005HzQlQAK/cp000013
      address = 'https://vgtna--dev0.lightning.force.com/lightning/r/Customer_Profile__c/' + storeResponse.toString() + '/view'
       //address = 'https://vgtna--dev0.lightning.force.com/lightning/r/Customer_Profile__c/' + myId.toString() + '/view'
    else
       address = 'https://dev0-vgtna-dev0.cs50.force.com/s/customer-profile/' + myId.toString() + '/'
         var urlEvent = $A.get("e.force:navigateToURL");
         urlEvent.setParams({
           "url": address,
           "isredirect" :false
    });
         urlEvent.fire();   
        // close modal window
         var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();


       }
       else if (state === "ERROR") {
         // if no Customer Profile, just refresh the current page
         var errors = response.getError();  
         console.log("error " + errors);
         window.location.reload(); 
       }
                        
         
     });
     $A.enqueueAction(action); 
  **/
   }
})