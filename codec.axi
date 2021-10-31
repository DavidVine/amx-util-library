program_name='codec'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: codec
// 
// Description:
//
//    - This include file provides generic encode/decode functions which can be used to encode/decode data using
//      various methods.
//
// Implementation:
//
//    - Any NetLinx program utilising the codec include file must use either the INCLUDE or #INCLUDE keywords to include 
//      the codec include file within the program. While the INCLUDE and #INCLUDE keywords are both functionally 
//      equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE keyword is 
//      from the earlier Axcess programming language and is included within the NetLinx programming language for 
//      backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'Encoding Demo'
//
//          #include 'codec'
//
// Usage:
//
//    - To encode a message simply call the encode function and pass through an ASCII string indicating what encoding
//      scheme is to be used followed by the data to be encoded. The encode function will return an encoded version of
//      the message.
//
//      E.g:
//
//          encodedMessage = encode('base64','Hello world');
//          // returns 'SGVsbG8gd29ybGQ='
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __CODEC__
#define __CODEC__


#include 'base64'


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: encode
//
// Parameters:
//    char scheme[]   -   A string representing an encoding scheme.
//    char data[]     -   The data to encode.
//
// Returns:
//    char[1024]   -   The encoded data.
//
// Description:
//    Encodes data according to the encoding scheme provided. An empty string is returned if specified encoding scheme
//    is unsupported.
//    Supported Encoding Schemes:
//	- base64
//	- base64Url
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[1024] encode(char scheme[], char data[]) {
	switch(scheme) {
		case 'base64': return base64Encode(data);
		
		case 'base64Url': return base64UrlEncode(data, true);
	}
	return '';
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: decode
//
// Parameters:
//    char scheme[]   -   A string representing an encoding scheme ('base64').
//    char data[]     -   The data to decode.
//
// Returns:
//    char[1024]   -   The decoded data.
//
// Description:
//    Decodes data according to the encoding scheme provided. An empty string is returned if specified encoding scheme
//    is unsupported.
//    Supported Encoding Schemes:
//	- base64
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[1024] decode(char scheme[], char data[]) {
	switch(scheme) {
		case 'base64': return base64Decode(data);
	}
	return '';
}


#end_if
