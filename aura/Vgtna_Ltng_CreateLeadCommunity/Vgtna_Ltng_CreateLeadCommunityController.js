({
    doInit : function(component, event, helper){
        component.set("v.test", false);
    },
    navigateLead : function(component, event, helper) {
       component.set("v.test", false);
        component.set("v.test", true);
    }
})