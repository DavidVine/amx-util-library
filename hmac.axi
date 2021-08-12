program_name='hmac'


#if_not_defined __HMAC__
#define __HMAC__


#include 'md5.axi'
#include 'sha1.axi'
#include 'sha256.axi'


/*
NetLinx implementation of HMAC (Keyed-Hashing for Message Authentication) - see RFC 2104.
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: hmac
//
// Parameters:
//    char hashFunction[]   -   String representing the hash function to use.
//    char message[]        -   Message to use in hash function.
//    char key[]            -   Key used for message authentication.
//
// Returns:
//    char[1024]   -   Result of the keyed-hashing process.
//
// Description:
//    Produces a keyed-hash conforming to HMAC as defined in RFX 2014. Can be used for message authentication. An empty 
//    string is returned if specified hash function is unsupported.
//    Supported Hash Functions:
//	- md5
//	- sha1 | sha-1
//	- sha256 | sha-256
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[1024] hmac(char hashFunction[], char message[], char key[]) {
    char keyAdjusted[1024];
    char outerKey[1024];
    char innerKey[1024];
    char outerKeyPad;
    char innerKeyPad;
    integer i;
    integer blockSize;
    
    switch(lower_string(hashFunction)) {
		case 'md5':
			blockSize = MD5_BLOCK_SIZE_BYTES;
		
		case 'sha1':
		case 'sha-1':
			blockSize = SHA_1_BLOCK_SIZE_BYTES;
		
		case 'sha256':
		case 'sha-256':
			blockSize = SHA_256_BLOCK_SIZE_BYTES;
		
		default: return '';
    }
    
    if(length_array(key) > blockSize) {
		switch(lower_string(hashFunction)) {
			case 'md5': 
				keyAdjusted = md5(key);
			
			case 'sha1':
			case 'sha-1': 
				keyAdjusted = sha1(key);
			
			case 'sha256':
			case 'sha-256': 
				keyAdjusted = sha256(key);
		}
    }
    else if(length_array(key) < blockSize) {
		keyAdjusted = key;
		while(length_array(keyAdjusted) < blockSize) {
			keyAdjusted = "keyAdjusted,$00";
		}
    } else {
		keyAdjusted = key;
	}
    
    outerKeyPad = $5c;
    innerKeyPad = $36;
    for(i=1;i<=blockSize;i++) {
		outerKey = "outerKey,(keyAdjusted[i] bxor outerKeyPad)";
		innerKey = "innerKey,(keyAdjusted[i] bxor innerKeyPad)";
    }
    
    switch(lower_string(hashFunction)) {
		case 'md5': return md5("outerKey,md5("innerKey,message")");
		
		case 'sha1':
		case 'sha-1': return sha1("outerKey,sha1("innerKey,message")");
		
		case 'sha256':
		case 'sha-256': return sha256("outerKey,sha256("innerKey,message")");
    }
}


#end_if