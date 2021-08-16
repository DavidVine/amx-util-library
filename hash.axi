program_name='hash'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: hash
// 
// Description:
//
//    - This include file provides a generic hash function which can be used to create various types of message digests
//
// Implementation:
//
//    - Any NetLinx program utilising the hash include file must use either the INCLUDE or #INCLUDE keywords to include 
//      the hash include file within the program. While the INCLUDE and #INCLUDE keywords are both functionally 
//      equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE keyword is 
//      from the earlier Axcess programming language and is included within the NetLinx programming language for 
//      backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'Hash Demo'
//
//          #include 'hash'
//
// Usage:
//
//    - To create a message digest simply call the hash function and pass through an ASCII string indicating what
//      hashing scheme is to be used followed by the data to be hashed. The hash function will return the message
//      digest in a char array.
//
//      E.g:
//
//          hashedPassword = hash('md5','p@55w0rd');
//          // returns "$39,$F1,$3D,$60,$B3,$F6,$FB,$E0,$BA,$16,$36,$B0,$A9,$28,$3C,$50"
//
//          hashedPassword = hash('sha1','p@55w0rd');
//          // returns "$CE,$0B,$2B,$77,$1F,$7D,$46,$8C,$01,$41,$91,$8D,$AE,$A7,$04,$E0,$E5,$AD,$45,$DB"
//
//          hashedPassword = hash('sha256','p@55w0rd');
//          // returns "$59,$F4,$6B,$B9,$0C,$FF,$B0,$ED,$7C,$7E,$5D,$B5,$8B,$B3,$00,$F3,$BC,$D7,$14,$F5,$1A,$E7,$23,$ED,$91,$B0,$6A,$3E,$13,$D4,$D5,$B6"
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __HASH__
#define __HASH__


#include 'md5'
#include 'sha1'
#include 'sha256'


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: hash
//
// Parameters:
//    char scheme[]   -   String representing the hash function to use.
//    char data[]     -   Data to use in hash function.
//
// Returns:
//    char[2048]   -   The result of the hash function.
//
// Description:
//    Produces a hashed value using the hash function specified. An empty string is returned if specified hash function
//    is unsupported.
//    Supported Hash Functions:
//	- md5
//	- sha1 | sha-1
//	- sha256 | sha-256
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[2048] hash(char scheme[], char data[]) {

	switch(lower_string(scheme)) {
	
		case 'md5': {
			return md5(data);
		}

		case 'sha1':
		case 'sha-1': {
			return sha1(data);
		}

		case 'sha256':
		case 'sha-256': {
			return sha256(data);
		}
	}
	
	return '';
}


#end_if
