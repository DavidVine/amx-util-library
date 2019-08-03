program_name='hmac'

#IF_NOT_DEFINED __HMAC__
#DEFINE __HMAC__

#include 'md5.axi'
#include 'sha1.axi'
#include 'sha256.axi'

/*
NetLinx implementation of HMAC (Keyed-Hashing for Message Authentication) - see RFC 2104.
*/

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


#END_IF