({
	getURLParameter : function(component, param) {
    var result=decodeURIComponent
        ((new RegExp('[?|&]' + param + '=' + '([^&;]+?)(&|#|;|$)').
            exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null;
        component.set("v.accId",result);
    //alert('Param ' + param + ' from URL = ' + result);
    
}
})