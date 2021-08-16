program_name='binary'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: binary
// 
// Description:
//
//    - This include file provides functions for working with binary values larger than the typical CHAR, INTEGER, or 
//      LONG data types and for converting between smaller data types and binary formatted ASCII strings (e.g., '10011')
//
// Implementation:
//
//    - Any NetLinx program utilising the binary include file must use either the INCLUDE or #INCLUDE keywords to 
//      include the binary include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//      functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE 
//      keyword is from the earlier Axcess programming language and is included within the NetLinx programming language 
//      for backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'Binary Demo'
//
//          #include 'binary'
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __BINARY__
#define __BINARY__


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: charToBinary
//
// Parameters:
//    char c   -   A char value
//
// Returns:
//    char[8]   -   An 8-byte character array containing a binary formatted ASCII string representing a char.
//
// Description:
//    Converts a char value into a binary formatted ASCII string representing a char.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[8] charToBinary(char c) {
	stack_var char b7, b6, b5, b4, b3, b2, b1, b0;

	b7 = type_cast(itoa((c & $80) >> 7));
	b6 = type_cast(itoa((c & $40) >> 6));
	b5 = type_cast(itoa((c & $20) >> 5));
	b4 = type_cast(itoa((c & $10) >> 4));
	b3 = type_cast(itoa((c & $8) >> 3));
	b2 = type_cast(itoa((c & $4) >> 2));
	b1 = type_cast(itoa((c & $2) >> 1));
	b0 = type_cast(itoa((c & $1)));

	return "b7,b6,b5,b4,b3,b2,b1,b0"
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: binaryToChar
//
// Parameters:
//    char binary[8]   -   An 8-byte character array containing a binary formatted ASCII string representing a char.
//
// Returns:
//    char   -   A char value
//
// Description:
//    Converts a binary formatted ASCII string representing a char to a char.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char binaryToChar(char binary[8]) {
	stack_var char result;

	result = type_cast((atoi("binary[1]") << 7) & $80);
	result = (result | type_cast((atoi("binary[2]") << 6) & $40));
	result = (result | type_cast((atoi("binary[3]") << 5) & $20));
	result = (result | type_cast((atoi("binary[4]") << 4) & $10));
	result = (result | type_cast((atoi("binary[5]") << 3) & $8));
	result = (result | type_cast((atoi("binary[6]") << 2) & $4));
	result = (result | type_cast((atoi("binary[7]") << 1) & $2));
	result = (result | type_cast(atoi("binary[8]")));

	return result;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: longToBinary
//
// Parameters:
//    long val   -   A long value
//
// Returns:
//    char[32]   -   A 32-byte character array containing a binary formatted ASCII string representing a long.
//
// Description:
//    Converts a long value into a binary formatted ASCII string representing a long.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[32] longToBinary(long val) {
	stack_var char result[32];

	result = "charToBinary(type_cast((val & $FF000000) >> 24))";
	result = "result,charToBinary(type_cast((val & $FF0000) >> 16))";
	result = "result,charToBinary(type_cast((val & $FF00) >> 8))";
	result = "result,charToBinary(type_cast((val & $FF)))";
	
	return result;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: binaryToLong
//
// Parameters:
//    char binary[32]   -   A 32-byte character array containing a binary formatted ASCII string representing a long.
//
// Returns:
//    long   -   A long value
//
// Description:
//    Converts a binary formatted ASCII string representing a long to a long.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function long binaryToLong(char binary[32]) {
	stack_var long result;
	stack_var integer i, j;

	for(i=1, j = 31; i <= length_array(binary); i++, j--) {
		result = (result | (atoi("binary[i]") << j));
	}

	return result;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: binaryToString
//
// Parameters:
//    char binary[]   -   A character array of undetermined length containing a binary formatted ASCII string.
//
// Returns:
//    char[1048576]   -   A character array containing the raw-values post conversion.
//
// Description:
//    Converts a character array containing a binary formatted ASCII string representing the raw value to a character
//    array containing the raw values.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[1048576] binaryToString(char binary[]) {
	stack_var char result[1048576];
	stack_var integer i;

	for(i=1; i < length_array(binary); i=i+8) {
		result = "result,binaryToChar(mid_string(binary,i,8))"
	}	

	return result;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: stringToBinary
//
// Parameters:
//    char str[]   -   A character array of undetermined length.
//
// Returns:
//    char[1048576]   -   A character array containing a binary formatted ASCII string.
//
// Description:
//    Converts a character array to a binary formatted ASCII string representing the raw value.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[1048576] stringToBinary(char str[]) {
	stack_var char result[1048576];
	stack_var integer i;

	for(i = 1; i <= length_string(str); i++) {
		result = "result,charToBinary(str[i])"
	}
	
	return result;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: leftRotateString
//
// Parameters:
//    char msg[]   - A character array of undetermined length.
//
// Returns:
//    char[1048576]   -   A character array containing the original message bitwise rotated 1 place to the left
//
// Description:
//    Does a bitwise rotation on a character array 1 position to the left. MSB is moved to the LSB and everything else
//    it bit-shifted 1 place to the left.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[1048576] leftRotateString(char msg[]) {
	stack_var char result[1048576];
	stack_var long i;
	stack_var char leftMostBitVal;

	leftMostBitVal = type_cast((msg[1] & 128) >> 7);
	
	for(i = 1; i <= length_array(msg); i++) {
		if(i != length_array(msg)) {
			result[i] =  type_cast((msg[i] << 1) | ((msg[i+1] & 128) >> 7));
		} else {
			result[i] =  type_cast((msg[i] << 1) | leftMostBitVal);
		}
	}

	set_length_string(result,length_string(msg));

	return result;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: rightRotateString
//
// Parameters:
//    char msg[]   - A character array of undetermined length.
//
// Returns:
//    char[1048576]   -   A character array containing the original message bitwise rotated 1 place to the right
//
// Description:
//    Does a bitwise rotation on a character array 1 position to the right. LSB is moved to the MSB and everything else
//    it bit-shifted 1 place to the right.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[1048576] rightRotateString(char msg[]) {
	stack_var char result[1048576];
	stack_var long i;
	stack_var char rightMostBitVal;

	rightMostBitVal = type_cast((msg[length_string(msg)] & 1));
	
	for(i = length_array(msg); i >= 1; i--) {
		if(i != 1) {
			result[i] =  type_cast((msg[i] >> 1) | ((msg[i-1] & 1) << 7));
		} else {
			result[i] =  type_cast((msg[i] >> 1) | (rightMostBitVal << 7));
		}
	}

	set_length_string(result,length_string(msg));

	return result;
}


#end_if
