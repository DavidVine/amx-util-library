PROGRAM_NAME='hash'

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

#IF_NOT_DEFINED __HASH__
#DEFINE __HASH__

#include 'md5'
#include 'sha1'
#include 'sha256'

define_function char[2048] hash(char scheme[], char data[]) {

	switch(lower_string(scheme)) {
	
		case 'md5': {
			return md5(data);
		}

		case 'sha1': {
			return sha1(data);
		}

		case 'sha256': {
			return sha256(data);
		}
	}
}

#END_IF
