program_name='json-rpc'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: json-rpc
// 
// Description:
//
//    - This include file provides a NetLinx implementation of JSON RPC's (JSON Remote Procedure Calls).
//
// Implementation:
//
//    - Any NetLinx program utilising the jspn-rpc include file must use either the INCLUDE or #INCLUDE keywords to 
//      include the json-rpc include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//      functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE
//      keyword is from the earlier Axcess programming language and is included within the NetLinx programming language 
//      for backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'JSON RPC Demo'
//
//          #include 'json-rpc'
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __JSON_RPC__
#define __JSON_RPC__


#include 'json'


/*
These functions support JSON-RPC v2.0 only and do not support JSON-RPC 1.0/1.1
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonRpcRequestObjParams
//
// Parameters:
//    char method[]   -   A string with the name of the method to be invoked.
//    JsonObj jObj    -   A JSON Object to be passed as a parameter to the define method.
//    char id[]       -   A string used to match the response with the JSON-RPC request when it is replied to.
//
// Returns:
//    char[JSON_MAX_VALUE_DATA_LENGTH]   -   A JSON-RPC formatted request.
//
// Description:
//    Builds a JSON-RPC (JSON encoded remote procedure call).
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[JSON_MAX_VALUE_DATA_LENGTH] jsonRpcRequestObjParams(char method[], JsonObj jObj, char id[]) {
	char tempMethod[JSON_MAX_VALUE_DATA_LENGTH];
	char tempId[JSON_MAX_VALUE_DATA_LENGTH];
	integer i;
	
	for(i=1; i<=length_string(method); i++) {
		if(method[i] == '"' && (i==1)) {
			tempMethod = "tempMethod,'\"'";
		}
		else if(method[i] == '"' && method[i-1] != '\') {
			tempMethod = "tempMethod,'\"'";
		}
		else {
			tempMethod = "tempMethod,method[i]";
		}
	}
	
	
	for(i=1; i<=length_string(id); i++) {
		if(id[i] == '"' && (i==1)) {
			tempId = "tempId,'\"'";
		}
		else if(id[i] == '"' && id[i-1] != '\') {
			tempId = "tempId,'\"'";
		}
		else {
			tempId = "tempId,id[i]";
		}
	}
	
	if(id == '') {
		return "'{"jsonrpc":"2.0","method":',tempMethod,',"params":',jsonStringifyObject(jObj),'}'";
	}
	else {
		return "'{"jsonrpc":"2.0","method":',tempMethod,',"params":',jsonStringifyObject(jObj),',"id":"',tempId,'"}'";
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonRpcRequestArrayParams
//
// Parameters:
//    char method[]    -    A string with the name of the method to be invoked.
//    JsonArray jArr   -   A JSON Array to be passed as a parameter to the define method.
//    char id[]        -   A string used to match the response with the JSON-RPC request when it is replied to.
//
// Returns:
//    char[JSON_MAX_VALUE_DATA_LENGTH]   -   A JSON-RPC formatted request.
//
// Description:
//   Builds a JSON-RPC (JSON encoded remote procedure call).
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[JSON_MAX_VALUE_DATA_LENGTH] jsonRpcRequestArrayParams(char method[], JsonArray jArr, char id[]) {
	char tempMethod[JSON_MAX_VALUE_DATA_LENGTH];
	char tempId[JSON_MAX_VALUE_DATA_LENGTH];
	integer i;
	
	for(i=1; i<=length_string(method); i++) {
		if(method[i] == '"' && (i==1)) {
			tempMethod = "tempMethod,'\"'";
		}
		else if(method[i] == '"' && method[i-1] != '\') {
			tempMethod = "tempMethod,'\"'";
		}
		else {
			tempMethod = "tempMethod,method[i]";
		}
	}
	
	
	for(i=1; i<=length_string(id); i++) {
		if(id[i] == '"' && (i==1)) {
			tempId = "tempId,'\"'";
		}
		else if(id[i] == '"' && id[i-1] != '\') {
			tempId = "tempId,'\"'";
		}
		else {
			tempId = "tempId,id[i]";
		}
	}
	
	if(id == '') {
		return "'{"jsonrpc":"2.0","method":',tempMethod,',"params":',jsonStringifyArray(jArr),'}'";
	}
	else {
		return "'{"jsonrpc":"2.0","method":',tempMethod,',"params":',jsonStringifyArray(jArr),',"id":"',tempId,'"}'";
	}
}


#end_if
