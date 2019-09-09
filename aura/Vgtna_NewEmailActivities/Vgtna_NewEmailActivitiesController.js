({
    init: function(component, event, helper) {
        console.log('openModal: '+component.get("v.openModal"));
    },
    sendMail: function(component, event, helper) {
        // when user click on Send button 
        // First we get all 3 fields values 	
        //var getEmail = component.get("v.email");
        var getEmail = component.get("v.selectedLookUpRecordUser").Email;
        var getSubject = component.get("v.subject");
        var getbody = component.get("v.body");
        var accountId = component.get("v.selectedLookUpRecordAcc").Id;
        console.log('getEmail: '+accountId);
        //console.log('accountId: '+component.get("v.selectedLookUpRecord").Id);
        // check if Email field is Empty or not contains @ so display a alert message 
        // otherwise call call and pass the fields value to helper method    
        console.log('lookuprecordacc: '+component.get("v.selectedLookUpRecordAcc"));
        if ($A.util.isEmpty(getEmail) || !getEmail.includes("@")) {
            alert('Please Enter valid Email Address');
        } else if(component.get("v.selectedLookUpRecordAcc").Id == null) {
        	alert('Please Enter Related To');
        } else {
            helper.sendHelper(component, getEmail, getSubject, getbody, accountId);
        }
    },
 
    // when user click on the close buttton on message popup ,
    // hide the Message box by set the mailStatus attribute to false
    // and clear all values of input fields.   
    closeMessage: function(component, event, helper) {
        component.set("v.mailStatus", false);
        component.set("v.email", null);
        component.set("v.subject", null);
        component.set("v.body", null);
    },
    
    CloseModalPopup: function(component, event, helper) {
        component.destroy();
    }
})