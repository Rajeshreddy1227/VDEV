({
    fetchData: function (cmp) {
        cmp.set('v.mycolumns', [
                        {label: 'Related To', 
                             fieldName : 'RelatedToLink', 
                             type:'url',
                         	sortable: true,
                             typeAttributes:{
                                 tooltip:{
                                     fieldName:'RelatedTo'
                                 },
                                 target: '_self',
                                 label:{
                                     fieldName:'RelatedTo' }
                                         }
                        },
            			{label: 'Subject', 
                             fieldName : 'ActivityLink',
                         	sortable: true,                         
                             type:'url',
                             typeAttributes:{
                                 tooltip:{
                                     fieldName:'Subject'
                                 },
                                 target: '_self',
                                 label:{
                                     
                                     fieldName:'Subject' }
                                         }
                         
                        
            			
            },
                        //{ label: 'Status', fieldName: 'Status', type: 'text'},
            			{ label: 'Type', fieldName: 'Type', type: 'text',sortable: true,},
                        { label: 'Assigned To', fieldName: 'AssignedTo', type: 'text',sortable: true,},
            { label: 'Created Date', fieldName: 'CreatedDate', type: 'date-local',sortable: true},                      	
                        { label: 'Due Date', fieldName: 'Duedate', type: 'date-local',sortable: true,                      	
                         title: 'Duedate'}
                    ]);
        console.log('shoveiwall: '+cmp.get("v.showViewAll"));
        var action = cmp.get('c.getCustActivities');
        action.setParams({"recId": cmp.get("v.recordId"),
                          "viewAll": cmp.get("v.showViewAll"),
                          "location": cmp.get("v.Location")
                         });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() != null) {
                	cmp.set("v.mydata",response.getReturnValue());
                    this.sortData(cmp, cmp.get("v.sortedBy"), cmp.get("v.sortedDirection"));
                }
               
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
                cmp.set("v.noResults", "An error occurred: No records to display");
            }
        });
        $A.enqueueAction(action);
    },
    fetchLoggedInUser : function(component) {
        var action = component.get("c.getLoggedUser");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.loggedInUser", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    convertArrayOfObjectsToCSV : function(component,objectRecords){
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider;
       
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
        keys = ['RelatedTo','Subject','Type','AssignedTo','Duedate' ];
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
 
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
          }// outer main for loop close 
       
       // return the CSV formate String 
        return csvStringResult;        
    },
    
    sortData: function (cmp, fieldName, sortDirection) {
        console.log('entered: ');
        var data = cmp.get("v.mydata");
        var reverse = sortDirection === 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.mydata", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
})