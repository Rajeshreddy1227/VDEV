({
	doInit : function(component, event, helper) {
	var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
               // set current user information on userInfo attribute
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action);
    },
    fruitsTab: function(component, event, helper) {
        var tab1 = component.find('fruitId');
        var TabOnedata = component.find('fruTabDataId');
 
        var tab2 = component.find('VegeId');
        var TabTwoData = component.find('vegeTabDataId');
 
        var tab3 = component.find('ColorId');
        var TabThreeData = component.find('ColorTabDataId');
        //show and Active fruits tab
        $A.util.addClass(tab1, 'slds-active');
        $A.util.addClass(TabOnedata, 'slds-show');
        $A.util.removeClass(TabOnedata, 'slds-hide');
        // Hide and deactivate others tab
        $A.util.removeClass(tab2, 'slds-active');
        $A.util.removeClass(TabTwoData, 'slds-show');
        $A.util.addClass(TabTwoData, 'slds-hide');
 
        $A.util.removeClass(tab3, 'slds-active');
        $A.util.removeClass(TabThreeData, 'slds-show');
        $A.util.addClass(TabThreeData, 'slds-hide');
    },
    vegeTab: function(component, event, helper) {
 
        var tab1 = component.find('fruitId');
        var TabOnedata = component.find('fruTabDataId');
 
        var tab2 = component.find('VegeId');
        var TabTwoData = component.find('vegeTabDataId');
 
        var tab3 = component.find('ColorId');
        var TabThreeData = component.find('ColorTabDataId');
 
        //show and Active vegetables Tab
        $A.util.addClass(tab2, 'slds-active');
        $A.util.removeClass(TabTwoData, 'slds-hide');
        $A.util.addClass(TabTwoData, 'slds-show');
        // Hide and deactivate others tab
        $A.util.removeClass(tab1, 'slds-active');
        $A.util.removeClass(TabOnedata, 'slds-show');
        $A.util.addClass(TabOnedata, 'slds-hide');
 
        $A.util.removeClass(tab3, 'slds-active');
        $A.util.removeClass(TabThreeData, 'slds-show');
        $A.util.addClass(TabThreeData, 'slds-hide');
 
    },
    
})