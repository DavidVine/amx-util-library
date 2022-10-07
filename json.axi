program_name='json'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: json
// 
// Description:
//
//    - This include file provides structures and functions for working with JSON (JavaScript Object Notation).
//
// Implementation:
//
//    - Any NetLinx program utilising the json include file must use either the INCLUDE or #INCLUDE keywords to 
//      include the json include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//      functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE
//      keyword is from the earlier Axcess programming language and is included within the NetLinx programming language 
//      for backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'JSON Demo'
//
//          #include 'json'
//
// Usage:
//
//    - There are 4 x structures defined for working with JSON:
//
//        JsonToken
//
//            - The JsonToken structure is used to store a JSON token using the .type and .value fields.
//
//            - The type of the value can be array,  boolean,  null,  number, object, string. Types are defined in the
//              following string constants:
//
//                JSON_TYPE_ARRAY
//                JSON_TYPE_BOOLEAN
//                JSON_TYPE_NULL
//                JSON_TYPE_NUMBER
//                JSON_TYPE_OBJECT
//                JSON_TYPE_STRING
//
//            - The value is always stored in string (CHAR []) format even though the type may not necessarily be a 
//              string. When working with JsonTokens resulting fom parsing stringified JSON data the .type field should
//              be inspected and then the .value field handled appropriately.
//
//        JsonPair
//
//            - The JsonPair structure is used to store a JSON pair using the .name and .token fields.
//
//            - The name of the pair is a string (CHAR []) value.
//
//            - The token is a JsonToken which will define the type and value of the data.
//
//        JsonObj
//
//            - The JsonObj structure is used to store a JSON object which is essentially a list of pairs (JsonPair) 
//              which can be accessed via the .pairs field. Although the list of pairs is stored in a JsonPair array it
//              is important to understand that this is not the same as a JSON array and should not be treated as such.
//
//        JsonArray
//
//            - The JsonArray structure is used to store an array of tokens (JsonToken) which can be indexed via the 
//              .elements field. The elements of the array are not named but as the elements are tokens they themselves
//              may contain arraya, booleans, nulls, numbers, objects, or strings.
//
//    - A warning on memory usage: 
//
//         NetLinx is a static-memory allocation language meaning that the memory allocation of a variable cannot grow or 
//         shrink dynamically. Because it is unknown how large the stringified JSON may be a large memory value (65535 bytes 
//         or 63.9KB) was chosen for the max size of storing JSON data in the .value field of a JsonToken. A JsonArray 
//         contains an array of JsonToken elements (100 by default) so a single JsonArray will consume a minimum of 6553500 
//         bytes (6399.9KB or 6.25MB). A JsonPair contains a JsonToken and a JsonObj contains an array of JsonPair elements 
//         (100 by default) so a single JsonObj will also consume at least 6.35MB by default.
//
//         Because of this large memory consumption any globally defined JsonObj or JsonArray variables should be explicitly
//         defined in volatile memory which is far more plentiful than non-volatile memory. NX-series processors only have 1MB
//         non-volatile memory but 512MB volatile memory (1GB volatile memory on the NX-4200), e.g:
//
//            define_variable
//
//            volatile JsonObj jObj
//            volatile JsonArr jArr
//
//         Note that the default values can be edited by modifying the following constant values:
//
//            integer JSON_MAX_VALUE_NAME_LENGTH  = 200;
//            integer JSON_MAX_VALUE_DATA_LENGTH = 65535;
//            integer JSON_MAX_OBJECT_VALUES = 100;
//            integer JSON_MAX_ARRAY_VALUES = 100;
//
//    - The jsonParseArray and jsonParseObject functions can be used to parse stringified JSON into JSON-type
//      structures.
//
//    - You can extract a single property from stringified JSON using the jsonGet function.
//
//    - Once JSON data has been stored in JSON-type NetLinx structures it can be interrogated using numerous functions
//      such as:
//
//        jsonObjHasOwnProperty
//        jsonObjGet
//        jsonObjGetType
//        jsonArrayGet
//        jsonObjGetValues
//        jsonObjGetTypes
//        jsonObjGetNames
//        jsonArrayGetValues
//        jsonArrayGetTypes
//        
//    - The jsonStringifyValue, jsonStringifyArray, and jsonStringifyObject functions can be used to stringify 
//      JSON-type NetLinx structures.
//
//    - If you have stringified JSON that you know to be an object you can use the jsonParseObject function to parse 
//      the stringified JSON and store it in a JsonObj structure:
//
//    E.g:
//
//        char stringifiedJson[200];
//        JsonObj jObj;
//
//        stringifiedJson = '{"first":"one","second":2,"third":[1,2,3],"fourth":[{"firstInner":"1stIn","secondInner":22},null,false]}'
//
//        if(jsonParseObject(stringifiedJson, jObj)) {
//            // parse was successful, jObj contains a list of JSON pairs
//        }
//        else {
//            // parse was not successful - check debug messages for reason
//        }
//
//    - If you have stringified JSON that you know to be an array you can use the jsonParseArray function to parse 
//      the stringified JSON and store it in a JsonArray structure:
//
//    E.g:
//
//        char stringifiedJson[200];
//        JsonArray jArr;
//
//        stringifiedJson = '["hello",123,true,null,-5.4,{"first":"1st","second":2}]'
//        
//        if(jsonParseArray(stringifiedJson, jArr)) {
//            // parse was successful, jArr contains list of JSON tokens
//        }
//        else {
//            // parse was not successful - check debug messages for reason
//        }
//
//    - To query if a JSON object for a pair with a matching property name:
//
//  integer jsonObjHasOwnProperty(JsonObj jObj, char name[])
//
//
//
//    - To get the (stringified) value of a named property from a JSON object:
//
// char[JSON_MAX_VALUE_DATA_LENGTH] jsonObjGet(JsonObj jObj, char name[])
//
//
//
//    - To get the type of a named property from a JSON object:
//
// char[7] jsonObjGetType(JsonObj jObj, char name[])
//
//
//
//    - To get an indexed elements' value from a JSON array:
//
// integer jsonArrayGet(JsonArray jArray, integer index, JsonToken jToken)
//
//
//
//    - To get a list of all the (stringified) property values in a JSON obejct:
//
// jsonObjGetValues(JsonObj jObj, char values[JSON_MAX_OBJECT_VALUES][])
//
//
//
//    - To get a list of all the property types in a JSON obect:
//
// jsonObjGetTypes(JsonObj jObj, char types[JSON_MAX_OBJECT_VALUES][])
//
//
//
//    - To get a list of all the property names in a JSON object:
//
// jsonObjGetNames(JsonObj jObj, char names[JSON_MAX_OBJECT_VALUES][])
//
//
//
//    - To get a list of all the (stringified) values in a JSON object
//
// jsonArrayGetValues(JsonArray jArr, char values[JSON_MAX_OBJECT_VALUES][])
//
//
//
//    - To get a list of all the types in a JSON array
//
// jsonArrayGetTypes(JsonArray jArr, char types[JSON_MAX_OBJECT_VALUES][])
//
//
//
//    - To stringify a JSON token of any type:
//
// char[JSON_MAX_VALUE_DATA_LENGTH] jsonStringifyValue(JsonToken jToken)
//
//
//
//    -  To stringify a JSON array:
//
// char[JSON_MAX_VALUE_DATA_LENGTH] jsonStringifyArray(JsonArray jArr)
//
//
//
//    - To stringify a JSON object:
//
// char[JSON_MAX_VALUE_DATA_LENGTH] jsonStringifyObject(JsonObj jObj)
//
//
//
//    - To remove excess whitespace from stringified JSON:
//
// char[JSON_MAX_VALUE_DATA_LENGTH] jsonRemoveWhiteSpace(char jsonStr[])
//
//
//
//    - 
//
// char[50] jsonGet(char jsonSerialized[], char property[], JsonToken jToken)
//
//
//
//    - To escape any data within stringified JSON that needs escaping:
//
// char[2048] jsonEscape(char unescaped[])
//
//
//
//    - To unescape any escaped data with stringified JSON:
//
// char[2048] jsonUnescape(char escaped[])
//
//
//
//
//
//
//
//
//
//
//
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __JSON__
#define __JSON__


#include 'string'


define_constant

integer JSON_MAX_VALUE_NAME_LENGTH  = 200;
integer JSON_MAX_VALUE_DATA_LENGTH = 65535;
integer JSON_MAX_OBJECT_VALUES = 100;
integer JSON_MAX_ARRAY_VALUES = 100;

char JSON_TYPE_ARRAY[]   = 'array';
char JSON_TYPE_BOOLEAN[] = 'boolean';
char JSON_TYPE_NULL[]    = 'null';
char JSON_TYPE_NUMBER[]  = 'number';
char JSON_TYPE_OBJECT[]  = 'object';
char JSON_TYPE_STRING[]  = 'string';

char JSON_PROPERTY_NOT_FOUND[] = 'property not found';
char JSON_INVALID[] = 'invalid';

char JSON_UNESCAPED_BACKSPACE       = $08;
char JSON_UNESCAPED_TAB             = $09;
char JSON_UNESCAPED_NEWLINE         = $0a;
char JSON_UNESCAPED_FORM_FEED       = $0c;
char JSON_UNESCAPED_CARRIAGE_RETURN = $0d;
char JSON_UNESCAPED_DOUBLE_QUOTE    = '"';
char JSON_UNESCAPED_BACKSLASH       = '\';

char JSON_ESCAPED_BACKSPACE[]       = '\b'
char JSON_ESCAPED_TAB[]             = '\t';
char JSON_ESCAPED_NEWLINE[]         = '\n';
char JSON_ESCAPED_FORM_FEED[]       = '\f';
char JSON_ESCAPED_CARRIAGE_RETURN[] = '\r';
char JSON_ESCAPED_DOUBLE_QUOTE[]    = '\"';
char JSON_ESCAPED_BACKSLASH[]       = '\\';
char JSON_ESCAPED_UNICODE[]         = '\u';


define_type

struct JsonToken {
	char type[JSON_MAX_VALUE_NAME_LENGTH];
	char value[JSON_MAX_VALUE_DATA_LENGTH];
}

struct JsonPair {
	char name[JSON_MAX_VALUE_NAME_LENGTH];
	JsonToken token;
}

struct JsonObj {
	JsonPair pairs[JSON_MAX_OBJECT_VALUES];
}

struct JsonArray {
	JsonToken elements[JSON_MAX_ARRAY_VALUES]
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonObjHasOwnProperty
//
// Parameters:
//    JsonObj jObj   -   JSON object.
//    char name[]    -   Name of property to search for.
//
// Returns:
//    integer   -   True (1) or false (0) result indicating whether the named property was found.
//
// Description:
//    Searches a JSON object to see if it contains a named property and returns true if it exists or false if it does
//    not. Note: search is only performed on the first level.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function integer jsonObjHasOwnProperty(JsonObj jObj, char name[]) {
	integer i;
	
	for(i=1; i<=length_array(jObj.pairs); i++) {
		if(jObj.pairs[i].name == name) {
			return true;
		}
	}
	
	return false;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonObjGet
//
// Parameters:
//    JsonObj jObj   -   JSON object.
//    char name[]    -   Name of property to search for.
//
// Returns:
//    char[JSON_MAX_VALUE_DATA_LENGTH]   -   Value of the property.
//
// Description:
//    Searches a JSON object to see if it contains a named property and returns the value of the property if it exists
//    or an empty string ('') if it does not.
//    Note that returned data is always a string but this might contain a JSON object, array, string, number, boolean,
//    or null value so calls to jsonObjGet should be performed in conjunction with the jsonObjGetType function so the
//    returned data can be treated appropriately. E.g, it may need to be parsed back into another JsonObject or 
//    JsonArray, etc...
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[JSON_MAX_VALUE_DATA_LENGTH] jsonObjGet(JsonObj jObj, char name[]) {
	integer i;
	
	for(i=1; i<=length_array(jObj.pairs); i++) {
		if(jObj.pairs[i].name == name) {
			return jObj.pairs[i].token.value;
		}
	}
	
	return '';
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonObjGetType
//
// Parameters:
//    JsonObj jObj   -   JSON object.
//    char name[]    -   Name of property to search for.
//
// Returns:
//    char[7]   -   String indicating the type of the property.
//
// Description:
//    Searches a JSON object to see if it contains a named property and returns a string indicating the type of data 
//    stored in the property ('array' | 'boolean' | 'null' | 'number' | 'object' | 'string')  if it exists or an empty
//    string ('') if it does not.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[7] jsonObjGetType(JsonObj jObj, char name[]) {
	integer i;
	
	for(i=1; i<=length_array(jObj.pairs); i++) {
		if(jObj.pairs[i].name == name) {
			return jObj.pairs[i].token.type;
		}
	}
	
	return '';
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonArrayGet
//
// Parameters:
//    JsonArray jArray   -   JSON Array containing the data.
//    integer index      -   Index of array.
//    JsonToken jToken   -   JSON Token to copy the data to.
//
// Returns:
//    integer   -   Boolean value (1==true | 0 == false) indicating success or failure.
//
// Description:
//    Gets an element from a JSON array at a specified index and assigns a copy of the element to the JSON token 
//    parameter (pass-by-reference). If operation is successful returns true, otherwise returns false.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function integer jsonArrayGet(JsonArray jArray, integer index, JsonToken jToken) {
	integer i;
	
	if((index == 0) || (index > length_array(jArray.elements))) {
		return false;
	}
	
	jToken.type = jArray.elements[index].type;
	jToken.value = jArray.elements[index].value;
	
	return true;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonObjGetValues
//
// Parameters:
//    JsonObj jObj                            -   JSON object.
//    char values[JSON_MAX_OBJECT_VALUES][]   -   2-dimensional array to store the values of the JSON objects'
//                                                properties.
//
// Returns:
//    nothing.
//
// Description:
//    Copies the values from the JSON objects' properties into the 2-dimensional character array provided. 
//    Note that while the returned values are strings they are JSON encoded and might contain a JSON object, array, 
//    string, number, boolean, or null value so calls to jsonObjGetValues should be performed in conjunction with the 
//    jsonObjGetTypes function so the returned data can be treated appropriately. E.g, it may need to be parsed back 
//    into another JsonObject or JsonArray, etc...
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function jsonObjGetValues(JsonObj jObj, char values[JSON_MAX_OBJECT_VALUES][]) {
	integer i;
	
	for(i=1; i<=length_array(jObj.pairs); i++) {
		values[i] = jObj.pairs[i].token.value;
	}
	set_length_array(values,i-1);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonObjGetTypes
//
// Parameters:
//    JsonObj jObj                           -   JSON object.
//    char types[JSON_MAX_OBJECT_VALUES][]   -   2-dimensional array to store the types of the JSON objects'
//                                               properties.
//
// Returns:
//    nothing.
//
// Description:
//    Copies the types from the JSON object into the 2-dimensional character array provided. Types can be 'array', 
//    'boolean', 'null', 'number', 'object', and 'string'.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function jsonObjGetTypes(JsonObj jObj, char types[JSON_MAX_OBJECT_VALUES][]) {
	integer i;
	
	for(i=1; i<=length_array(jObj.pairs); i++) {
		types[i] = jObj.pairs[i].token.value;
	}
	set_length_array(types,i-1);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonObjGetNames
//
// Parameters:
//    JsonObj jObj                           -   JSON object.
//    char names[JSON_MAX_OBJECT_VALUES][]   -   2-dimensional array to store the names of the JSON objects'
//                                               properties.
//
// Returns:
//    nothing.
//
// Description:
//    Copies the names from the JSON objects' properties into the 2-dimensional character array provided.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function jsonObjGetNames(JsonObj jObj, char names[JSON_MAX_OBJECT_VALUES][]) {
	integer i;
	
	for(i=1; i<=length_array(jObj.pairs); i++) {
		names[i] = jObj.pairs[i].name;
	}
	set_length_array(names,i-1);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonArrayGetValues
//
// Parameters:
//    JsonArray jArr                          -   JSON array.
//    char values[JSON_MAX_OBJECT_VALUES][]   -   2-dimensional array to store the values of the JSON arrays' elements.
//
// Returns:
//    nothing.
//
// Description:
//    Copies the values from the JSON arrays' elements into the 2-dimensional character array provided. 
//    Note that while the returned values are strings they are JSON encoded and might contain a JSON object, array, 
//    string, number, boolean, or null value so calls to jsonArrayGetValues should be performed in conjunction with the 
//    jsonArrayGetTypes function so the returned data can be treated appropriately. E.g, it may need to be parsed back 
//    into another JsonObject or JsonArray, etc...
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function jsonArrayGetValues(JsonArray jArr, char values[JSON_MAX_OBJECT_VALUES][]) {
	integer i;
	
	for(i=1; i<=length_array(jArr.elements); i++) {
		values[i] = jArr.elements[i].value;
	}
	set_length_array(values,i-1);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonArrayGetTypes
//
// Parameters:
//    JsonArray jArr                         -   JSON array.
//    char types[JSON_MAX_OBJECT_VALUES][]   -   2-dimensional array to store the types of the JSON arrays' elements.
//
// Returns:
//    nothing.
//
// Description:
//    Copies the types of the JSON array elements into the 2-dimensional character array provided. Types can be 'array', 
//    'boolean', 'null', 'number', 'object', and 'string'.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function jsonArrayGetTypes(JsonArray jArr, char types[JSON_MAX_OBJECT_VALUES][]) {
	integer i;
	
	for(i=1; i<=length_array(jArr.elements); i++) {
		types[i] = jArr.elements[i].type;
	}
	set_length_array(types,i-1);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonStringifyValue
//
// Parameters:
//    JsonToken jToken   -   JSON token.
//
// Returns:
//    char[JSON_MAX_VALUE_DATA_LENGTH]   -   JSON encoded string.
//
// Description:
//    Takes a JSON token and returns a JSON-encoded string.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[JSON_MAX_VALUE_DATA_LENGTH] jsonStringifyValue(JsonToken jToken) {
    switch(jToken.type) {
		case JSON_TYPE_ARRAY: {
			JsonArray jArr;
			if(jsonParseArray(jToken.value, jArr)) {
				return jsonStringifyArray(jArr);
			}
			else {
				return '';
			}
		}
		case JSON_TYPE_BOOLEAN:
		case JSON_TYPE_NULL:
		case JSON_TYPE_NUMBER: {
			return jToken.value;
		}
		case JSON_TYPE_OBJECT: {
			JsonObj jObj;
			if(jsonParseObject(jToken.value, jObj)) {
				return jsonStringifyObject(jObj);
			}
			else {
				return '';
			}
		}
		case JSON_TYPE_STRING: {
			return "'"',jToken.value,'"'";
		}
		default: {
			return '';
		}
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonStringifyArray
//
// Parameters:
//    JsonArray jArr   -   JSON array.
//
// Returns:
//    char[JSON_MAX_VALUE_DATA_LENGTH]   -   JSON encoded string.
//
// Description:
//    Takes a JSON array and returns a JSON-encoded string.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[JSON_MAX_VALUE_DATA_LENGTH] jsonStringifyArray(JsonArray jArr) {
	char arrStr[JSON_MAX_VALUE_DATA_LENGTH];
	integer i;
	
	arrStr = '[';
	
	for(i=1; i<=length_array(jArr.elements); i++) {
		if(i == length_array(jArr.elements)) {
			arrStr = "arrStr,jsonStringifyValue(jArr.elements[i])";
		}
		else {
			arrStr = "arrStr,jsonStringifyValue(jArr.elements[i]),','";
		}
	}
	
	arrStr = "arrStr,']'"
	
	return arrStr;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonStringifyObject
//
// Parameters:
//    JsonObj jObj   -   JSON oject.
//
// Returns:
//    char[JSON_MAX_VALUE_DATA_LENGTH]   -   JSON encoded string.
//
// Description:
//    Takes a JSON object and returns a JSON-encoded string.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[JSON_MAX_VALUE_DATA_LENGTH] jsonStringifyObject(JsonObj jObj) {
	char objStr[JSON_MAX_VALUE_DATA_LENGTH];
	integer i;
	
	objStr = '{';
	
	for(i=1; i<=length_array(jObj.pairs); i++) {
		if(i == length_array(jObj.pairs)) {
			objStr = "objStr,'"',jObj.pairs[i].name,'":',jsonStringifyValue(jObj.pairs[i].token)";
		}
		else {
			objStr = "objStr,'"',jObj.pairs[i].name,'":',jsonStringifyValue(jObj.pairs[i].token),','";
		}
	}
	
	objStr = "objStr,'}'"
	
	return objStr;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonRemoveWhiteSpace
//
// Parameters:
//    char jsonStr[]   -   JSON-encoded string.
//
// Returns:
//    char[JSON_MAX_VALUE_DATA_LENGTH]   -   JSON-encoded string.
//
// Description:
//    Takes a JSON-encoded string that may contain excess whitespace and returns a JSON-encoded string with all excess
//    whitespace removed.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[JSON_MAX_VALUE_DATA_LENGTH] jsonRemoveWhiteSpace(char jsonStr[]) {
	integer insideString;
	integer i;
	char jsonStrNoWhiteSpace[JSON_MAX_VALUE_DATA_LENGTH];
	jsonStrNoWhiteSpace = jsonStr;
	insideString = false;
	for(i=1; i<=length_array(jsonStrNoWhiteSpace); i++) {
		if(insideString) {
			if((jsonStrNoWhiteSpace[i] == '"') && (jsonStrNoWhiteSpace[i-1] != '/')) {
				insideString = false;
			}
		}
		else {
			if(jsonStrNoWhiteSpace[i] == '"')
				insideString = true;
			else if(jsonStrNoWhiteSpace[i] == ' ' || // space
					jsonStrNoWhiteSpace[i] == $09 || // horizontal tab
					jsonStrNoWhiteSpace[i] == $0b || // vertical tab
					jsonStrNoWhiteSpace[i] == $0d || // carriage return
					jsonStrNoWhiteSpace[i] == $0a) { // line feed
				integer j;
				for(j=i; j<length_array(jsonStrNoWhiteSpace); j++) {
					jsonStrNoWhiteSpace[j] = jsonStrNoWhiteSpace[j+1];
				}
				set_length_array(jsonStrNoWhiteSpace,j-1);
				i--;
			}
		}
	}
	return jsonStrNoWhiteSpace;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonValidateNumber
//
// Parameters:
//    char jsonStr[]   -   JSON-encoded string.
//
// Returns:
//    integer   -   Boolean value (1==true | 0 == false) indicating success or failure.
//
// Description:
//    Takes a JSON-encoded string an validates whether it contains a correctly JSON-formatted number
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function integer jsonValidateNumber(char jsonStr[]) {

	stack_var char tempJson[JSON_MAX_VALUE_DATA_LENGTH];
	stack_var integer numberHasSign
	stack_var integer i

	if(length_string(jsonStr) == 0) {
		return false;
	}

	tempJson = jsonStr;

	removeLeadingChars(tempJson,"' ',$0d,$0a")

	if(length_string(tempJson) == 0) {
		return false;
	}

	removeTrailingChars(tempJson,"' ',$0d,$0a")
	
	if(length_string(tempJson) == 0) {
		return false;
	}

	i=1;

	// process number
	if(tempJson[i] == '-') {
		numberHasSign = true
		i++;
	}

	if(i>length_string(tempJson)) {
		return false;
	}

	if(tempJson[i] == '0') {
		i++;
	}
	else if(find_string('123456789',"tempJson[i]",1)) {
		i++;
		while((i<=length_string(tempJson)) && find_string('0123456789',"tempJson[i]",1)) {
			i++;
		}
	}
	else {
		return false;
	}
	
	if(i>length_string(tempJson)) {
		return true;
	}

	// process fraction
	if(tempJson[i] == '.') {
		stack_var integer foundDigit

		i++;
		while((i<=length_string(tempJson)) && find_string('0123456789',"tempJson[i]",1)) {
			foundDigit = true
			i++;
		}

		if(!foundDigit) {
			return false
		}

		if(i>length_string(tempJson)) {
			return true;
		}
	}

	// process exponent
	if(find_string('eE',"tempJson[i]",1)) {
		stack_var integer exponentHasSign
		stack_var integer foundDigit

		i++;

		if(i>length_string(tempJson)) {
			return false;
		}

		if(find_string('-+',"tempJson[i]",1)) {
			i++;

			if(i>length_string(tempJson)) {
				return false;
			}
		}

		while((i<=length_string(tempJson)) && find_string('0123456789',"tempJson[i]",1)) {
			foundDigit = true
			i++;
		}
		
		if(!foundDigit) {
			return false
		}

		if(i>length_string(tempJson)) {
			return true;
		}
		
	}
	else {
		return false;
	}

	return false;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonParse
//
// Parameters:
//    char jsonStr[]     -   JSON-encoded string.
//    JsonToken jToken   -   JSON array.
//
// Returns:
//    integer   -   Boolean value (1==true | 0 == false) indicating success or failure.
//
// Description:
//    Parses stringified JSON and, if successful, assigns the result to the JsonToken parameter 
//   (pass-by-reference). If operation is successful returns true, otherwise returns false.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function integer jsonParse(char jsonStr[], JsonToken jToken) {
	stack_var JsonObj jObj;
	stack_var JsonArray jArr;
	char tempJson[JSON_MAX_VALUE_DATA_LENGTH];

	AMX_LOG(AMX_DEBUG,"'json::jsonParse:jsonStr: ',jsonStr");

	if(length_string(jsonStr) == 0) {
		return false;
	}

	tempJson = jsonStr;

	removeLeadingChars(tempJson,"' ',$0d,$0a")

	if(length_string(tempJson) == 0) {
		return false;
	}

	removeTrailingChars(tempJson,"' ',$0d,$0a")
	
	if(length_string(tempJson) == 0) {
		return false;
	}

	if(tempJson == 'null') {
		jToken.type = JSON_TYPE_NULL
		jToken.value = tempJson
		AMX_LOG(AMX_DEBUG,"'json::jsonParse:type: ',jToken.type,',value: ',jToken.value");
		return true
	}

	else if(tempJson == 'false' || tempJson == 'true') {
		jToken.type = JSON_TYPE_BOOLEAN
		jToken.value = tempJson
		AMX_LOG(AMX_DEBUG,"'json::jsonParse:type: ',jToken.type,',value: ',jToken.value");
		return true
	}

	else if(tempJson[1] == '"') { // string
			stack_var integer foundClosingQuote;
			stack_var integer i;

			i=2;
			while(i<=length_string(tempJson)) {
				if((tempJson[i] == '"') && (tempJson[i-1] != '\')) {
					if(i != length_string(tempJson)) {
						AMX_LOG(AMX_DEBUG,'json::jsonParse:Invalid JSON - closing " followed by more data');
						return false;
					}
					else {
						foundClosingQuote = true;
						jToken.type = JSON_TYPE_STRING;
						jToken.value = mid_string(tempJson,2,i-2);
						AMX_LOG(AMX_DEBUG,"'json::jsonParse:type: ',jToken.type,',value: ',jToken.value");
						return true;
					}
				}
				i++;
			}
			
			if(!foundClosingQuote) {
				AMX_LOG(AMX_DEBUG,'json::jsonParse:Invalid JSON - no closing "');
				return false;
			}
	}

	else if(find_string('-0123456789',"tempJson[1]",1)){ // number

		if(jsonValidateNumber(tempJson)) {
			jToken.type = JSON_TYPE_NUMBER;
			jToken.value = tempJson;
			return true;
		}
		else {
			return false;
		}
	}

	else if(jsonParseObject(tempJson, jObj)) {	// attempt to parse JsonObject
		jToken.type = JSON_TYPE_OBJECT
		jToken.value = tempJson
		AMX_LOG(AMX_DEBUG,"'json::jsonParse:type: ',jToken.type,',value: ',jToken.value");
		return true;
	}

	else if(jsonParseArray(tempJson, jArr)) { // attempt to parse JsonArray
		jToken.type = JSON_TYPE_ARRAY
		jToken.value = tempJson
		AMX_LOG(AMX_DEBUG,"'json::jsonParse:type: ',jToken.type,',value: ',jToken.value");
		return true;
	}

	AMX_LOG(AMX_DEBUG,"'json::jsonParse:Invalid JSON - unknown type'");
	return false;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonParseArray
//
// Parameters:
//    char jsonArrayStr[]   -   JSON-encoded string.
//    JsonArray jArr        -   JSON array.
//
// Returns:
//    integer   -   Boolean value (1==true | 0 == false) indicating success or failure.
//
// Description:
//    Parses a JSON encoded string and, if successful, assigns the result to the JSON array parameter 
//   (pass-by-reference). If operation is successful returns true, otherwise returns false.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function integer jsonParseArray(char jsonArrayStr[], JsonArray jArr) {
	char tempJson[JSON_MAX_VALUE_DATA_LENGTH];
	integer invalidJson;
	integer i, j;
	
	tempJson = jsonRemoveWhiteSpace(jsonArrayStr);
	
	if(length_string(jsonArrayStr) < 2) {
		return false;
	}
	
	if(tempJson[1] == '[' && tempJson[length_string(tempJson)] == ']') {
		if((length_string(tempJson) == 2) && (tempJson[1] == '[') && (tempJson[2] == ']')) { // empty object
			set_length_array(jArr.elements,0);
			//send_string 0, 'json::jsonParseArray:Returning true - empty array';
			return true;
		}
		else {
			tempJson = mid_string(tempJson,2,length_array(tempJson)-2);
		}
	}
	else {
		return false;
	}
	
	for(i=1; i<=max_length_array(jArr.elements); i++) {
		if(find_string(tempJson,'true',1) == 1) { // boolean true
			jArr.elements[i].type = JSON_TYPE_BOOLEAN;
			jArr.elements[i].value = 'true';
			remove_string(tempJson,"'true'",1);
		}
		else if(find_string(tempJson,'false',1) == 1) { // boolean false
			jArr.elements[i].type = JSON_TYPE_BOOLEAN;
			jArr.elements[i].value = 'false';
			remove_string(tempJson,"'false'",1);
		}
		else if(find_string(tempJson,'null',1) == 1) { // null
			jArr.elements[i].type = JSON_TYPE_NULL;
			jArr.elements[i].value = 'null';
			remove_string(tempJson,"'null'",1);
		}
		else if(tempJson[1] == '"') { // string
			integer foundClosingSquareBracket;
			
			j=2;
			while(j<=length_string(tempJson)) {
				if((tempJson[j] == '"') && (tempJson[j-1] != '\')) {
					foundClosingSquareBracket = true;
					jArr.elements[i].type = JSON_TYPE_STRING;
					jArr.elements[i].value = mid_string(tempJson,2,j-2);
					remove_string(tempJson,"'"',jArr.elements[i].value,'"'",1);
					break;
				}
				j++;
			}
			
			if(!foundClosingSquareBracket) {
				AMX_LOG(AMX_DEBUG,'json::jsonParseObj:Invalid JSON - no closing ]');
				invalidJson = true;
				break;
			}
		}
		else if(tempJson[1] == '-' ||
		        tempJson[1] == '0' ||
		        tempJson[1] == '1' ||
		        tempJson[1] == '2' ||
		        tempJson[1] == '3' ||
		        tempJson[1] == '4' ||
		        tempJson[1] == '5' ||
		        tempJson[1] == '6' ||
		        tempJson[1] == '7' ||
		        tempJson[1] == '8' ||
		        tempJson[1] == '9') { // number
			jArr.elements[i].type = JSON_TYPE_NUMBER;
			j = 1;
			while(j<=length_string(tempJson) &&
			      (tempJson[j] == '0' ||
			       tempJson[j] == '1' ||
			       tempJson[j] == '2' ||
			       tempJson[j] == '3' ||
			       tempJson[j] == '4' ||
			       tempJson[j] == '5' ||
			       tempJson[j] == '6' ||
			       tempJson[j] == '7' ||
			       tempJson[j] == '8' ||
			       tempJson[j] == '9' ||
			       tempJson[j] == '.' ||
			       tempJson[j] == 'e' ||
			       tempJson[j] == 'E' ||
			       tempJson[j] == '-' ||
			       tempJson[j] == '+')) {
				
				jArr.elements[i].value = "jArr.elements[i].value,tempJson[j]";
				j++;
			}
			remove_string(tempJson,jArr.elements[i].value,1);
		}
		else if(tempJson[1] == '[') { // array
			// look for matching closing ]
			integer insideString
			integer unmatchedOpenSquareBrackets;
			integer foundClosingSquareBracket;
			
			j = 2;
			while(j<=length_string(tempJson)) {
			
				if(tempJson[j] == '"') {
					if(!insideString) {
						insideString = true;
					}
					else if(insideString && (tempJson[j-1] != '\')) {
						insideString = false;
					}
				}
			
				if(!insideString) {
					if(tempJson[j] == '[') {
						unmatchedOpenSquareBrackets++;
					}
					else if(tempJson[j] == ']') {
					
						if(unmatchedOpenSquareBrackets) {
							unmatchedOpenSquareBrackets--;
						}
						else { // we found our matching closing ]
							foundClosingSquareBracket = true;
							jArr.elements[i].type = JSON_TYPE_ARRAY;
							jArr.elements[i].value = mid_string(tempJson,1,j);   // includes enclosing brackets '[' and ']'
							remove_string(tempJson,mid_string(tempJson,1,j),1);
							break;
						}
					}
				}
				j++;
			}
			
			if(!foundClosingSquareBracket) {
				AMX_LOG(AMX_DEBUG,'json::jsonParseObj:Invalid JSON - no closing ]');
				invalidJson = true;
				break;
			}
		}
		else if(tempJson[1] == '{') { // object
			// look for matching closing }
			integer insideString
			integer unmatchedOpenBraces;
			integer foundClosingCurlyBrace;
			
			j = 2;
			while(j<=length_string(tempJson)) {
			
				if(tempJson[j] == '"') {
					if(!insideString) {
						insideString = true;
					}
					else if(insideString && (tempJson[j-1] != '\')) {
						insideString = false;
					}
				}
			
				if(!insideString) {
					if(tempJson[j] == '{') {
						unmatchedOpenBraces++;
					}
					else if(tempJson[j] == '}') {
					
						if(unmatchedOpenBraces) {
							unmatchedOpenBraces--;
						}
						else { // we found our matching closing }
							foundClosingCurlyBrace = true;
							jArr.elements[i].type = JSON_TYPE_OBJECT;
							jArr.elements[i].value = mid_string(tempJson,1,j);   // includes enclosing brackets '{' and '}'
							remove_string(tempJson,mid_string(tempJson,1,j),1);
							break;
						}
					}
				}
				j++;
			}
			
			if(!foundClosingCurlyBrace) {
				AMX_LOG(AMX_DEBUG,'json::jsonParseObj:Invalid JSON - no closing }');
				invalidJson = true;
				break;
			}

		}
		else { // unexpected character - invalid JSON
			invalidJson = true;
			break;
		}
		
		if(!length_string(tempJson)) { // no more data to process
			break;
		}
		else if(tempJson[1] == ',') {
			remove_string(tempJson,"','",1);
		}
		else { // there's more data but it's invalid as the next character should be a comma (,)
			invalidJson = true;
			break;
		}
	}
	
	if(invalidJson) {
		return false;
	}
	else {
		set_length_array(jArr.elements,i);
		return true;
	}
	
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonParseObject
//
// Parameters:
//    char jsonObjStr[]   -   JSON-encoded string.
//    JsonObj jObj        -   JSON object.
//
// Returns:
//    integer   -   Boolean value (1==true | 0 == false) indicating success or failure.
//
// Description:
//    Parses a JSON encoded string and, if successful, assigns the result to the JSON object parameter 
//   (pass-by-reference). If operation is successful returns true, otherwise returns false.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function integer jsonParseObject(char jsonObjStr[], JsonObj jObj) {
	char tempJson[JSON_MAX_VALUE_DATA_LENGTH];
	char name[JSON_MAX_VALUE_NAME_LENGTH];
	integer i;
	
	integer invalidJson;
	
	AMX_LOG(AMX_DEBUG,'json::jsonParseObj');
	
	AMX_LOG(AMX_DEBUG,"'json::jsonParseObj:Length of JSON string = ',itoa(length_array(jsonObjStr))");
	
	tempJson = jsonRemoveWhiteSpace(jsonObjStr);
	
	if(length_string(jsonObjStr) < 2) {
		return false;
	}

	if(tempJson[1] == '{' && tempJson[length_string(tempJson)] == '}') {
		if((length_string(tempJson) == 2) && (tempJson[1] == '{') && (tempJson[2] == '}')) { // empty object
			set_length_array(jObj.pairs,0);
			AMX_LOG(AMX_DEBUG,'json::jsonParseObj:Returning true - empty object');
			return true;
		}
		else {
			tempJson = mid_string(tempJson,2,length_array(tempJson)-2);
		}
	}
	else {
		AMX_LOG(AMX_DEBUG,'json::jsonParseObj:Returning false - invalid object string');
		return false;
	}
	
	for(i=1; i<=max_length_array(jObj.pairs); i++) {
		integer j;
		
		// get next name
		name = remove_string(tempJson,'":',1);
		name = mid_string(name,2,length_string(name)-3); // remove leading " and trailing ":
		jObj.pairs[i].name = name;
		
		// get corresponding value
		if(find_string(lower_string(tempJson),'true',1) == 1) { // boolean true
			jObj.pairs[i].token.type = JSON_TYPE_BOOLEAN;
			jObj.pairs[i].token.value = 'true';
			AMX_LOG(AMX_DEBUG,"'json::jsonParseObj:[name: ',jObj.pairs[i].name,'][type: ',jObj.pairs[i].token.type,'][value: ',jObj.pairs[i].token.value,']'");
			remove_string(tempJson,"'true'",1);
		}
		else if(find_string(lower_string(tempJson),'false',1) == 1) { // boolean false
			jObj.pairs[i].token.type = JSON_TYPE_BOOLEAN;
			jObj.pairs[i].token.value = 'false';
			AMX_LOG(AMX_DEBUG,"'json::jsonParseObj:[name: ',jObj.pairs[i].name,'][type: ',jObj.pairs[i].token.type,'][value: ',jObj.pairs[i].token.value,']'");
			remove_string(tempJson,"'false'",1);
		}
		else if(find_string(lower_string(tempJson),'null',1) == 1) { // null
			jObj.pairs[i].token.type = JSON_TYPE_NULL;
			jObj.pairs[i].token.value = 'null';
			AMX_LOG(AMX_DEBUG,"'json::jsonParseObj:[name: ',jObj.pairs[i].name,'][type: ',jObj.pairs[i].token.type,'][value: ',jObj.pairs[i].token.value,']'");
			remove_string(tempJson,"'null'",1);
		}
		else if(tempJson[1] == '"') { // string
			integer foundClosingQuote;
			
			j=2;
			while(j<=length_string(tempJson)) {
				if((tempJson[j] == '"') && (tempJson[j-1] != '\')) {
					foundClosingQuote = true;
					jObj.pairs[i].token.type = JSON_TYPE_STRING;
					jObj.pairs[i].token.value = mid_string(tempJson,2,j-2);
					AMX_LOG(AMX_DEBUG,"'json::jsonParseObj:[name: ',jObj.pairs[i].name,'][type: ',jObj.pairs[i].token.type,'][value: ',jObj.pairs[i].token.value,']'");
					remove_string(tempJson,"'"',jObj.pairs[i].token.value,'"'",1);
					break;
				}
				j++;
			}
			
			if(!foundClosingQuote) {
				AMX_LOG(AMX_DEBUG,'json::jsonParseObj:Invalid JSON - no closing "');
				invalidJson = true;
				break;
			}
		}
		else if(tempJson[1] == '-' ||
		        tempJson[1] == '0' ||
		        tempJson[1] == '1' ||
		        tempJson[1] == '2' ||
		        tempJson[1] == '3' ||
		        tempJson[1] == '4' ||
		        tempJson[1] == '5' ||
		        tempJson[1] == '6' ||
		        tempJson[1] == '7' ||
		        tempJson[1] == '8' ||
		        tempJson[1] == '9') { // number
			jObj.pairs[i].token.type = JSON_TYPE_NUMBER;
			j = 1;
			while(j<=length_string(tempJson) &&
			      (tempJson[j] == '0' ||
			      tempJson[j] == '1' ||
			      tempJson[j] == '2' ||
			      tempJson[j] == '3' ||
			      tempJson[j] == '4' ||
			      tempJson[j] == '5' ||
			      tempJson[j] == '6' ||
			      tempJson[j] == '7' ||
			      tempJson[j] == '8' ||
			      tempJson[j] == '9' ||
			      tempJson[j] == '.' ||
			      tempJson[j] == 'e' ||
			      tempJson[j] == 'E' ||
			      tempJson[j] == '-' ||
			      tempJson[j] == '+')) {
				
				jObj.pairs[i].token.value = "jObj.pairs[i].token.value,tempJson[j]";
				j++;
			}
			AMX_LOG(AMX_DEBUG,"'json::jsonParseObj:[name: ',jObj.pairs[i].name,'][type: ',jObj.pairs[i].token.type,'][value: ',jObj.pairs[i].token.value,']'");
			remove_string(tempJson,jObj.pairs[i].token.value,1);
		}
		else if(tempJson[1] == '[') { // array
			// look for matching closing ]
			integer insideString
			integer unmatchedOpenSquareBrackets;
			integer foundClosingSquareBracket;
			
			j = 2;
			while(j<=length_string(tempJson)) {
			
				if(tempJson[j] == '"') {
					if(!insideString) {
						insideString = true;
					}
					else if(insideString && (tempJson[j-1] != '\')) {
						insideString = false;
					}
				}
			
				if(!insideString) {
					if(tempJson[j] == '[') {
						unmatchedOpenSquareBrackets++;
					}
					else if(tempJson[j] == ']') {
					
						if(unmatchedOpenSquareBrackets) {
							unmatchedOpenSquareBrackets--;
						}
						else { // we found our matching closing ]
							foundClosingSquareBracket = true;
							jObj.pairs[i].token.type = JSON_TYPE_ARRAY;
							jObj.pairs[i].token.value = mid_string(tempJson,1,j);   // includes enclosing brackets '[' and ']'
							AMX_LOG(AMX_DEBUG,"'json::jsonParseObj:[name: ',jObj.pairs[i].name,'][type: ',jObj.pairs[i].token.type,'][value: ',jObj.pairs[i].token.value,']'");
							remove_string(tempJson,mid_string(tempJson,1,j),1);
							break;
						}
					}
				}
				j++;
			}
			
			if(!foundClosingSquareBracket) {
				AMX_LOG(AMX_DEBUG,'json::jsonParseObj:Invalid JSON - no closing ]');
				invalidJson = true;
				break;
			}
		}
		else if(tempJson[1] == '{') { // object
			// look for matching closing }
			integer insideString
			integer unmatchedOpenBraces;
			integer foundClosingCurlyBrace;
			
			j = 2;
			while(j<=length_string(tempJson)) {
				if(tempJson[j] == '"') {
					if(!insideString) {
						insideString = true;
					}
					else if(insideString && (tempJson[j-1] != '\')) {
						insideString = false;
					}
				}
				
				if(!insideString) {
					if(tempJson[j] == '{') {
						unmatchedOpenBraces++;
					}
					else if(tempJson[j] == '}') {
					
						if(unmatchedOpenBraces) {
							unmatchedOpenBraces--;
						}
						else { // we found our matching closing }
							foundClosingCurlyBrace = true;
							jObj.pairs[i].token.type = JSON_TYPE_OBJECT;
							jObj.pairs[i].token.value = mid_string(tempJson,1,j);   // includes enclosing brackets '{' and '}'
							AMX_LOG(AMX_DEBUG,"'json::jsonParseObj:[name: ',jObj.pairs[i].name,'][type: ',jObj.pairs[i].token.type,'][value: ',jObj.pairs[i].token.value,']'");
							remove_string(tempJson,mid_string(tempJson,1,j),1);
							break;
						}
					}
				}
				j++;
			}
			
			if(!foundClosingCurlyBrace) {
				AMX_LOG(AMX_DEBUG,'json::jsonParseObj:Invalid JSON - no closing }');
				invalidJson = true;
				break;
			}
		}
		else { // unexpected character - invalid JSON
			invalidJson = true;
			break;
		}
		
		if(!length_string(tempJson)) { // no more data to process
			break;
		}
		else if(tempJson[1] == ',') {
			remove_string(tempJson,"','",1);
		}
		else { // there's more data but it's invalid as the next character should be a comma (,)
			invalidJson = true;
			break;
		}
	}
	
	if(invalidJson) {
		AMX_LOG(AMX_ERROR,'json::jsonParseObj:Returning false - invalid JSON');
		return false;
	}
	else {
		set_length_array(jObj.pairs,i);
		AMX_LOG(AMX_DEBUG,"'json::jsonParseObj:Returning true JSON object contains ',itoa(i),' name:value pairs'");
		return true;
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonGet
//
// Parameters:
//    char jsonSerialized[]   -   JSON-encoded string.
//    char property[]         -   Name of property to search for.
//    JsonToken jToken        -   JSON token.
//
// Returns:
//    char[50]   -   Token type of property found.
//
// Description:
//    Searches a JSON-encoded string for a specified property and, if found, updates the JSON token parameter
//    (pass-by-reference). If the search is successful the return string contains the type of the property found 
//    ('array' | 'boolean' | 'null' | 'number' | 'object' | 'string'). If the property is not found the returned
//    string is 'property not found'. If the JSON-encoded string is not formatted correctly the returned string is
//    'invalid'.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[50] jsonGet(char jsonSerialized[], char property[], JsonToken jToken)
{
	char json[5000];
	JsonObj jObj;
	integer i;
	
	json = "jsonSerialized";
	
	if(!jsonParseObject(json, jObj))
	{
		return JSON_INVALID;
	}
	
	for(i=1; i<=length_array(jObj.pairs); i++)
	{
		if(jObj.pairs[i].name == property)
		{
			jToken.type = jObj.pairs[i].token.type;
			jToken.value = jObj.pairs[i].token.value;
			return jToken.type;
		}
	}
	
	return JSON_PROPERTY_NOT_FOUND;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonEscape
//
// Parameters:
//    char unescaped[]   -   Unescaped JSON-encoded string.
//
// Returns:
//    char[2048]   -   Escaped JSON-encoded string.
//
// Description:
//    Escapes any characters that need escaping in the provided JSON-encoded string. Note that this function does not
//    test that the JSON-encoded string provided is valid JSON.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[2048] jsonEscape(char unescaped[])
{
    char escaped[2048];
    integer c;

    for(c=1; c<=length_string(unescaped); c++)
    {
        switch(unescaped[c])
        {
            case JSON_UNESCAPED_BACKSPACE:       {escaped = "escaped,JSON_ESCAPED_BACKSPACE";}
            case JSON_UNESCAPED_TAB:             {escaped = "escaped,JSON_ESCAPED_TAB";}
            case JSON_UNESCAPED_NEWLINE:         {escaped = "escaped,JSON_ESCAPED_NEWLINE";}
            case JSON_UNESCAPED_FORM_FEED:       {escaped = "escaped,JSON_ESCAPED_FORM_FEED";}
            case JSON_UNESCAPED_CARRIAGE_RETURN: {escaped = "escaped,JSON_ESCAPED_CARRIAGE_RETURN";}
            case JSON_UNESCAPED_DOUBLE_QUOTE:    {escaped = "escaped,JSON_ESCAPED_BACKSLASH";}
            case JSON_UNESCAPED_BACKSLASH:       {escaped = "escaped,JSON_ESCAPED_DOUBLE_QUOTE";}
            default:
			{
				if((unescaped[c] < $20) || (unescaped[c] > $7E)) // unprintable ASCII character
				{
					escaped = "escaped,JSON_ESCAPED_UNICODE,format('%04x',unescaped[c])";
				}
				else // printable ASCII character
				{
					{escaped = "escaped,unescaped[c]";}
				}
			}
        }
    }
    return escaped;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jsonUnescape
//
// Parameters:
//    char escaped[]   -    Escaped JSON-encoded string.
//
// Returns:
//    char[2048]   -   Unescaped JSON-encoded string.
//
// Description:
//    Unescapes any escaped characters in the provided JSON-encoded string. Note that this function does not test that
//    the JSON-encoded string provided is valid JSON.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[2048] jsonUnescape(char escaped[])
{
    char unescaped[2048];
    integer c;

    for(c=1; c<=length_string(escaped); c++)
    {
        if(c==length_string(escaped))
            unescaped = "unescaped,escaped[c]";
        else
        {
            switch("escaped[c],escaped[c+1]")
            {
                case JSON_ESCAPED_BACKSLASH:       {unescaped = "unescaped,JSON_UNESCAPED_BACKSLASH"; c++;} // need to check for escaped backslashes first
                case JSON_ESCAPED_BACKSPACE:       {unescaped = "unescaped,JSON_UNESCAPED_BACKSPACE"; c++;}
                case JSON_ESCAPED_TAB:             {unescaped = "unescaped,JSON_UNESCAPED_TAB"; c++;}
                case JSON_ESCAPED_NEWLINE:         {unescaped = "unescaped,JSON_UNESCAPED_NEWLINE"; c++;}
                case JSON_ESCAPED_FORM_FEED:       {unescaped = "unescaped,JSON_UNESCAPED_FORM_FEED"; c++;}
                case JSON_ESCAPED_CARRIAGE_RETURN: {unescaped = "unescaped,JSON_UNESCAPED_CARRIAGE_RETURN"; c++;}
                case JSON_ESCAPED_DOUBLE_QUOTE:    {unescaped = "unescaped,JSON_UNESCAPED_DOUBLE_QUOTE"; c++;}
				case JSON_ESCAPED_UNICODE:
				{
					unescaped = "unescaped,hextoi("/*escaped[c+2],escaped[c+3],*/escaped[c+4],escaped[c+5]")";
					c=c+5;
				}
                default:                           {unescaped = "unescaped,escaped[c]";}
            }
        }
    }
    return unescaped;
}


#end_if