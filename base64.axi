program_name='base64'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: base64
// 
// Description:
//
//    - This include file provides a NetLinx implementation of the base64 encoding scheme as defined in RFC 4648 (see
//      https://tools.ietf.org/html/rfc4648).
//
// Implementation:
//
//   - Any NetLinx program utilising the base64 include file must use either the INCLUDE or #INCLUDE keywords to 
//     include the base64 include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//     functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE
//     keyword is from the earlier Axcess programming language and is included within the NetLinx programming language 
//     for backwards compatibility).
//
//     E.g:
//
//        DEFINE_PROGRAM 'Encoding Demo'
//
//        #INCLUDE 'base64'
//
//   - The base64 function provided within this include file takes a message of unbound length and returns a base64
//     encoding of the message.
//
//     E.g:
//
//         encodedMessage = base64Encode('Hello World'); // returns 'SGVsbG8gV29ybGQ='
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#IF_NOT_DEFINED __BASE64__
#DEFINE __BASE64__

define_constant

char BASE64_ALPHABET[64] = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
char BASE64_PAD = '=';

define_function char base64AlphabetLookup(char val) {
	if(val > 63) return type_cast('');
	return BASE64_ALPHABET[val+1];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: base64Encode
//
// Parameters:
//    char data[]   -   A character array of undetermined size containing data to encode.
//
// Returns:
//    char[1024]   -   A character array (string) containing a base64 encoded ASCII string.
//
// Description:
//    Encodes the data provided using base64 encoding (as defined in RFC 4648).
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[1024] base64Encode(char data[]) {
	char encodedData[1024];
	char val6Bit;
	integer i;

	// 1. Split into 6-bit values
	// 2. Encode 6-bit values into 8-bit ASCII characters using Base-64 Alphabet
	// 3. Pad with '=' to create string length evenly divisible by 4-char blocks

	for(i=1; i<=length_array(data); i++) {
		if((i == 1) || (i%3 == 1)) {
			val6Bit = type_cast((data[i] BAND $FC) >> 2)
			encodedData = "encodedData,base64AlphabetLookup(val6Bit)"
			if(i == length_array(data)) {
				val6Bit = type_cast((data[i] BAND $3) << 4)
			} else {
				val6Bit = type_cast(((data[i] BAND $3) << 4) BOR ((data[i+1] BAND $F0) >> 4))
			}
			encodedData = "encodedData,base64AlphabetLookup(val6Bit)"
		} else if((i == 2) || (i%3 == 2)) {
			if(i == length_array(data)) {
				val6Bit = type_cast((data[i] BAND $F) << 2)
			} else {
				val6Bit = type_cast(((data[i] BAND $F) << 2) BOR ((data[i+1] BAND $C0) >> 6))
			}
			encodedData = "encodedData,base64AlphabetLookup(val6Bit)"
		} else if((i == 3) || (i%3 == 0)) {
			val6Bit = type_cast(data[i] BAND $3F)
			encodedData = "encodedData,base64AlphabetLookup(val6Bit)"
		}
	}

	// pad if required
	while((length_array(encodedData) % 4) != 0) {
		encodedData = "encodedData,BASE64_PAD";
	}

	return encodedData;	
}

/*define_function char[1024] base64Decode(char data[]) {
	char decodedData[1024];

	#warn '@TODO - Implement base64Decode function'

	return decodedData;
}*/


#END_IF
