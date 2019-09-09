/**********************************************************************
 Name:  Vgtna_Test_HttpCalloutMockCDBList
 Copyright © 2018  Salesforce
 ======================================================
======================================================
Purpose: Test Class for Vgtna_RecordTypeSelectorController to test out mock response for the webservice callout in list format.                                                          
-------                                                            
======================================================
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE              DETAIL            Description
   1.0    Subho        11/01/2018      INITIAL DEVELOPMENT          US218 
***********************************************************************/
@isTest
global class Vgtna_Test_HttpCalloutMockCDBList implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        //response.setBody('{"FMVName": "FedEx","stateProv": "TN","zipCode": "38120","country": "US","address": "942 S Shady Grove Rd","FMVID": "","city": "Memphis","name": "Brad James","alias": "Brad James","partyID": "","usDotId": "","AssistNames": []}');
        
        response.setBody('[{"partyID":"1191153908","alias":null,"name":"FEDEX CORPORATION","FMVID":null,"FMVName":null,"AssistNames":[],"address":"942 SHADY GROVE RD S","city":"MEMPHIS","stateProv":"TN","zipCode":"381204117","country":"UNITED STATES","countryCode":"US","usDotId":"86876","loadDate":"2001-05-30T16:59:14"},{"partyID":"1191153908","alias":null,"name":"FEDEX CORPORATION","FMVID":null,"FMVName":null,"AssistNames":[],"address":"942 SHADY GROVE RD S","city":"MEMPHIS","stateProv":"TN","zipCode":"381204117","country":"UNITED STATES","countryCode":"US","usDotId":"86876","loadDate":"2001-05-30T16:59:14"},{"partyID":"1191153908","alias":null,"name":"FEDEX CORPORATION","FMVID":null,"FMVName":null,"AssistNames":[],"address":"942 SHADY GROVE RD S","city":"MEMPHIS","stateProv":"TN","zipCode":"381204117","country":"UNITED STATES","countryCode":"US","usDotId":"86876","loadDate":"2001-05-30T16:59:14"},{"partyID":"1191153908","alias":null,"name":"FEDEX CORPORATION","FMVID":null,"FMVName":null,"AssistNames":[],"address":"942 SHADY GROVE RD S","city":"MEMPHIS","stateProv":"TN","zipCode":"381204117","country":"UNITED STATES","countryCode":"US","usDotId":"86876","loadDate":"2001-05-30T16:59:14"}]') ;
        response.setStatusCode(300);
        return response; 
    }


}