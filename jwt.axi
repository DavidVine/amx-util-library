program_name='jwt'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: jwt
// 
// Description:
//
//    - This include file provides a NetLinx implementation of JSON Web Tokens (JWT).
//          - see RFC-7515 JSON Web Signature (JWS)                          [https://tools.ietf.org/html/rfc7515]
//          - see RFC-7519 JSON Web Tokens (JWT)                             [https://tools.ietf.org/html/rfc7519]
//          - see RFC-7797 JSON Web Signature (JWS) Unencoded Payload Option [https://tools.ietf.org/html/rfc7797]
//          - see RFC-7516 JSON Web Encryption (JWE)                         [https://tools.ietf.org/html/rfc7516]
//
//    - Note that this implementation is far from complete.
//
// Implementation:
//
//    - Any NetLinx program utilising the jwt include file must use either the INCLUDE or #INCLUDE keywords to 
//      include the jwt include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//      functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE
//      keyword is from the earlier Axcess programming language and is included within the NetLinx programming language 
//      for backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'JWT Demo'
//
//          #include 'jwt'
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __JWT__
#define __JWT__


#include 'json'
#include 'base64'
#include 'hmac'


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: jwt
//
// Parameters:
//    char header[]                -   A JSON formatted header
//    char payload[]               -   A JSON formatted payload
//    char secret[]                -   A secret
//    integer base64EncodeSecret   -   A boolean value to indicate whether or not to base64 encode the secret
//
// Returns:
//    char[64] - SHA-256 message digest in ASCII format
//
// Description:
//    Returns a JSON Web Token (JWT) - see RFC7519 / RFC7797
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[1024] jwt(char header[], char payload[], char secret[], integer base64EncodeSecret, integer ignoreWhiteSpace) {
    char signature[1024];
	char alg[20];
	char tempHeader[1024];
	
	if(ignoreWhiteSpace) {
		header = jsonRemoveWhiteSpace(header);
		payload = jsonRemoveWhiteSpace(payload);
		secret = jsonRemoveWhiteSpace(secret);
	}
	
	tempHeader = header;
	if(!find_string(tempHeader,"'"alg"'",1)) {
		//send_string 0, "'Unable to build JWT. Algorithm not specified.'"
		return '';
	}
	remove_string(tempHeader,"'"alg"'",1);
	remove_string(tempHeader,"'"'",1);
	alg = remove_string(tempHeader,"'"'",1);
	alg = left_string(alg,length_string(alg)-1);
	
	switch(upper_string(alg)) {
		case 'HS256': {
			signature = hmac('sha256',"base64UrlEncode(header,false), '.', base64UrlEncode(payload,false)", secret);
			
			return "base64UrlEncode(header,false), '.', base64UrlEncode(payload,false), '.', base64UrlEncode(signature,false)";
		}
		default: {
			send_string 0, "'Unable to build JWT. Unsupported algorithm: ',alg"
			return '';
		}
	}
}


#end_if
