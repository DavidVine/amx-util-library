PROGRAM_NAME='codec'

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
//   - Any NetLinx program utilising the codec include file must use either the INCLUDE or #INCLUDE keywords to include 
//     the codec include file within the program. While the INCLUDE and #INCLUDE keywords are both functionally 
//     equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE keyword is 
//     from the earlier Axcess programming language and is included within the NetLinx programming language for 
//     backwards compatibility).
//
//     E.g:
//
//        DEFINE_PROGRAM 'Encoding Demo'
//
//        #INCLUDE 'codec'
//
//   - To encode a message simply call the encode function and pass through an ASCII string indicating what encoding
//     scheme is to be used followed by the data to be encoded. The encode function will return an encoded version of
//     the message.
//
//     E.g:
//
//        encodedMessage = encode('base64','Hello world');
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#IF_NOT_DEFINED __CODEC__
#DEFINE __CODEC__

#include 'base64'

define_function char[1024] encode(char scheme[], char data[]) {
	switch(scheme) {
		case 'base64': return base64Encode(data);
	}
}

define_function char[1024] decode(char scheme[], char data[]) {
	switch(scheme) {
		case 'base64': return base64Decode(data);
	}
}

#END_IF
