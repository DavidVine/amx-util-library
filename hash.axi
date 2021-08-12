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
//   - Any NetLinx program utilising the hash include file must use either the INCLUDE or #INCLUDE keywords to include 
//     the hash include file within the program. While the INCLUDE and #INCLUDE keywords are both functionally 
//     equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE keyword is 
//     from the earlier Axcess programming language and is included within the NetLinx programming language for 
//     backwards compatibility).
//
//     E.g:
//
//        DEFINE_PROGRAM 'Hash Demo'
//
//        #INCLUDE 'hash'
//
//   - To create a message digest simply call the hash function and pass through an ASCII string indicating what
//     hashing scheme is to be used followed by the data to be hashed. The hash function will return the message digest
//     in a char array.
//
//     E.g:
//
//        hashedPassword = hash('sha1','p@55w0rd');
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
