PROGRAM_NAME='cipher'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: cipher (*NOT IMPLEMENTED AT THIS TIME*)
// 
// Description:
//
//    - This include file provides generic encrypt/decrypt functions which can be used to encrypt/decrypt data using
//      various encryption techniques.
//
// Implementation:
//
//   - Any NetLinx program utilising the cipher include file must use either the INCLUDE or #INCLUDE keywords to 
//     include the cipher include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//     functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE 
//     keyword is from the earlier Axcess programming language and is included within the NetLinx programming language 
//     for backwards compatibility).
//
//     E.g:
//
//        DEFINE_PROGRAM 'Encryption Demo'
//
//        #INCLUDE 'cipher'
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#IF_NOT_DEFINED __CIPHER__
#DEFINE __CIPHER__

/*#INCLUDE 'rsa'
#INCLUDE 'aes'
#INCLUDE '3des'
#INCLUDE 'blowfish'
#INCLUDE 'twofish'*/

/*define_function char[5000] encrypt(char cipher[], char data[]) {

	switch(cipher) {

		case '3DES': {
		}

		case 'AES': {
		}

		case 'RSA': {
		}

		case 'Blowfish': {
		}

		case 'Twofish': {
		}
	}
}*/



/*define_function char[5000] decrypt(char cipher[], char data[]) {

	switch(cipher) {

		case '3DES': {
		}

		case 'AES': {
		}

		case 'RSA': {
		}

		case 'Blowfish': {
		}

		case 'Twofish': {
		}
	}
}*/

#END_IF
