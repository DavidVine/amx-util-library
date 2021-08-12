program_name='json-rpc'


#if_not_defined __JSON_RPC__
#define __JSON_RPC__


#include 'json.axi'


/*
These functions support JSON-RPC v2.0 only and do not support JSON-RPC 1.0/1.1
*/

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
