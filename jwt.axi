program_name='jwt'


/*
This NetLinx include contains an implementation of JSON Web Tokens (JWT).
	- see RFC-7515 JSON Web Signature (JWS)                          [https://tools.ietf.org/html/rfc7515]
	- see RFC-7519 JSON Web Tokens (JWT)                             [https://tools.ietf.org/html/rfc7519]
	- see RFC-7797 JSON Web Signature (JWS) Unencoded Payload Option [https://tools.ietf.org/html/rfc7797]
	- see RFC-7516 JSON Web Encryption (JWE)                         [https://tools.ietf.org/html/rfc7516]

Note that this implementation is far from complete.
*/


#if_not_defined __JWT__
#define __JWT__


#include 'json.axi'
#include 'base64.axi'
#include 'hmac.axi'


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
