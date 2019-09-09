/**********************************************************************
 Name:  Vgtna_Test_HttpCalloutMockCDB
 Copyright © 2018  Salesforce
 ======================================================
======================================================
Purpose: Test Class for Vgtna_RecordTypeSelectorController to test out mock response for the webservice callout (Error scenario).                                                          
-------                                                            
======================================================
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL            Description
   1.0    Subho        10/09/2018      INITIAL DEVELOPMENT          US218 
***********************************************************************/
@isTest
global class Vgtna_Test_HttpCalloutMockCDBError implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"FMVName": "FedEx","stateProv": "TN","zipCode": "38120","country": "US","address": "942 S Shady Grove Rd","FMVID": "","city": "Memphis","name": "Brad James","alias": "Brad James","partyID": "","usDotId": "","DataSource":"CRM","AssistNames": []}');
        response.setStatusCode(201);
        return response; 
    }

}