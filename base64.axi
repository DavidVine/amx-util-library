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
//    - Any NetLinx program utilising the base64 include file must use either the INCLUDE or #INCLUDE keywords to 
//      include the base64 include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//      functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE
//      keyword is from the earlier Axcess programming language and is included within the NetLinx programming language 
//      for backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'Encoding Demo'
//
//          #include 'base64'
//
// Usage:
//
//    - The base64Encode function provided within this include file takes a message of unbound length and returns a base64
//      encoding of the message.
//
//      E.g:
//
//          encodedMessage = base64Encode('Hello World');
//          // returns 'SGVsbG8gV29ybGQ='
//
//
//    - The base64Decode function provided within this include file takes a message of unbound length and returns a base64
//      decoding of the message.

//      E.g:
//
//          decodedMessage = base64Decode('SGVsbG8gV29ybGQ');
//          // returns 'Hello World'
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __BASE64__
#define __BASE64__


define_constant

char BASE64_ALPHABET[64]    = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
char BASE64URL_ALPHABET[64] = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
char BASE64_PAD = '=';


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: base64ReverseAlphabetLookup
//
// Parameters:
//    char encodedVal   -   An 8-bit base64 encoded ASCII value.
//
// Returns:
//    char   -   An 8-bit byte containing a 6-bit value.
//
// Description:
//    Converts an 8-bit base64 encoded ASCII value back to the original 6-bit data value.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char base64ReverseAlphabetLookup(char encodedVal)
{
	char c;
	
	for(c=1; c<=64; c++)
	{
		
		if(encodedVal == BASE64_ALPHABET[c])
		{
			
			return c-1;
		}
	}
	
	return 0;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: base64AlphabetLookup
//
// Parameters:
//    char val   -   An 8-bit byte containing a 6-bit value.
//
// Returns:
//    char   -   A base-64 encoded ASCII value.
//
// Description:
//    Converts a 6-bit data value to an 8-bit base64 encoded ASCII value.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char base64AlphabetLookup(char val) {
	if(val > 63) return type_cast('');
	return BASE64_ALPHABET[val+1];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: base64UrlAlphabetLookup
//
// Parameters:
//    char val   -   An 8-bit byte containing a 6-bit value.
//
// Returns:
//    char   -   A base-64 URL encoded ASCII value.
//
// Description:
//    Converts a 6-bit data value to an 8-bit base64 URL encoded ASCII value.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char base64UrlAlphabetLookup(char val) {
	if(val > 63) return type_cast('');
	return BASE64URL_ALPHABET[val+1];
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

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: base64UrlEncode
//
// Parameters:
//    char data[]   -   A character array of undetermined size containing data to encode.
//
// Returns:
//    char[1024]   -   A character array (string) containing a base64 URL encoded ASCII string.
//
// Description:
//    Encodes the data provided using base64 URL encoding (as defined in RFC 4648).
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[1024] base64UrlEncode(char data[], integer pad) {
	char encodedData[1024];
	char val6Bit;
	integer i;

	// 1. Split into 6-bit values
	// 2. Encode 6-bit values into 8-bit ASCII characters using Base-64 URL Alphabet
	// 3. Pad with '=' to create string length evenly divisible by 4-char blocks

	for(i=1; i<=length_array(data); i++) {
		if((i == 1) || (i%3 == 1)) {
			val6Bit = type_cast((data[i] BAND $FC) >> 2)
			encodedData = "encodedData,base64UrlAlphabetLookup(val6Bit)"
			if(i == length_array(data)) {
				val6Bit = type_cast((data[i] BAND $3) << 4)
			} else {
				val6Bit = type_cast(((data[i] BAND $3) << 4) BOR ((data[i+1] BAND $F0) >> 4))
			}
			encodedData = "encodedData,base64UrlAlphabetLookup(val6Bit)"
		} else if((i == 2) || (i%3 == 2)) {
			if(i == length_array(data)) {
				val6Bit = type_cast((data[i] BAND $F) << 2)
			} else {
				val6Bit = type_cast(((data[i] BAND $F) << 2) BOR ((data[i+1] BAND $C0) >> 6))
			}
			encodedData = "encodedData,base64UrlAlphabetLookup(val6Bit)"
		} else if((i == 3) || (i%3 == 0)) {
			val6Bit = type_cast(data[i] BAND $3F)
			encodedData = "encodedData,base64UrlAlphabetLookup(val6Bit)"
		}
	}

	// pad if required
	if(pad) {
		while((length_array(encodedData) % 4) != 0) {
			encodedData = "encodedData,BASE64_PAD";
		}
	}

	return encodedData;	
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: base64Decode
//
// Parameters:
//    char encodedData[]   -   A string of base-64 encoded data.
//
// Returns:
//    char[1024]   -   A string containing the unencoded (raw) data.
//
// Description:
//    Decodes the data provided using base64 URL decoding (as defined in RFC 4648).
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[1024] base64Decode(char encodedData[]) {
	char decodedData[1024];
	char vals6Bit[4];
	integer i;
	char bytes[3];
	
	
	// base64 encoded data consists of 8-bit (byte) ASCII characters
	// each of these character represents a 6-bit value
	// we need to translate each encoded byte into a 6-bit value
	// and "stich" all the 6-bit values together and then "chop" the result
	// into 8-bit (byte) values to get the decoded data.
	
	//send_string 0, "'base64Decode()..start the decode process'";
	for(i=1; i<=length_array(encodedData); i=i+4)
	{
		
		if((encodedData[i+2] == '=') && (encodedData[i+3] == '=')) {
			vals6Bit[1] = base64ReverseAlphabetLookup(encodedData[i]);
			vals6Bit[2] = base64ReverseAlphabetLookup(encodedData[i+1]);
			bytes[1] = type_cast(((vals6Bit[1] BAND $3F) << 2) BOR ((vals6Bit[2] BAND $30) >> 4));
			set_length_array(bytes,1);
			decodedData = "decodedData,bytes"
			break;
		}
		else if(encodedData[i+3] == '=') {
			vals6Bit[1] = base64ReverseAlphabetLookup(encodedData[i]);
			vals6Bit[2] = base64ReverseAlphabetLookup(encodedData[i+1]);
			vals6Bit[3] = base64ReverseAlphabetLookup(encodedData[i+2]);
			bytes[1] = type_cast(((vals6Bit[1] BAND $3F) << 2) BOR ((vals6Bit[2] BAND $30) >> 4));
			bytes[2] = type_cast(((vals6Bit[2] BAND $F) << 4) BOR ((vals6Bit[3] BAND $3C) >> 2));
			set_length_array(bytes,2);
			decodedData = "decodedData,bytes"
			break;
		}
		else {
			vals6Bit[1] = base64ReverseAlphabetLookup(encodedData[i]);
			vals6Bit[2] = base64ReverseAlphabetLookup(encodedData[i+1]);
			vals6Bit[3] = base64ReverseAlphabetLookup(encodedData[i+2]);
			vals6Bit[4] = base64ReverseAlphabetLookup(encodedData[i+3]);
			bytes[1] = type_cast(((vals6Bit[1] BAND $3F) << 2) BOR ((vals6Bit[2] BAND $30) >> 4));
			bytes[2] = type_cast(((vals6Bit[2] BAND $F) << 4) BOR ((vals6Bit[3] BAND $3C) >> 2));
			bytes[3] = type_cast(((vals6Bit[3] BAND $3) << 6) BOR (vals6Bit[4] BAND $3F));
			set_length_array(bytes,3);
			decodedData = "decodedData,bytes"
		}
	}
	
	return decodedData;
}


#end_if
