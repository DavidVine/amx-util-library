program_name='convert'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: convert
// 
// Description:
//
//    - This include file provides functions for manipulating data or converting data from one format to another.
//
// Implementation:
//
//    - Any NetLinx program utilising the convert include file must use either the INCLUDE or #INCLUDE keywords to 
//      include the convert include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//      functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE
//      keyword is from the earlier Axcess programming language and is included within the NetLinx programming language 
//      for backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'Conversion Demo'
//
//          #include 'convert'
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __CONVERT__
#define __CONVERT__


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: ltoa
//
// Parameters:
//    long val   -   32-bit value
//
// Returns:
//    char[10]   -   A character array (string) containing the value in numeric ASCII form ('0' - '4294967295')
//
// Description:
//    Returns a ASCII numeric string representing the long value parameter. Written as a necessity as the in-built
//    itoa function in NetLinx has a bug whereby large long values are returned as negative ASCII numeric strings.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[10] ltoa(long val) {
	if(val <= 100000) {
		return itoa(val);
	} else {
		return "itoa(val/100000),itoa(val%100000)";
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: ltba
//
// Parameters:
//    long val   -   32-bit value
//
// Returns:
//    char[4]   -   A 4-byte character array
//
// Description:
//    Returns a the 4-byte long value as a 4-byte char array.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function CHAR[4] ltba(long val) {
	char result[4];

	result[1] = type_cast((val & $FF000000) >> 24);
	result[2] = type_cast((val & $00FF0000) >> 16);
	result[3] = type_cast((val & $0000FF00) >> 8);
	result[4] = type_cast((val & $000000FF));
	set_length_array(result,4);

	return result;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: ltle
//
// Parameters:
//    long val   -   32-bit value.
//
// Returns:
//    long   -   32-bit value in little-endian format.
//
// Description:
//    Takes a long parameter assumed to be in big-endian format and returns a little-endian long.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function long ltle(long val) {
    return (((val & $FF) << 24) | ((val & $FF00) << 8) | ((val & $FF0000) >> 8) | ((val & $FF000000) >> 24));
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: lcls
//
// Parameters:
//    long val     -   32-bit value.
//    long shift   -   Number of bits to shift left.
//
// Returns:
//    long   -   32-bit value.
//
// Description:
//    Takes a long parameter, val, and a shift value, s, and returns a value which is a circular left shift of the 
//    original value, shifted s bits.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function long lcls(long val, integer s) {
    if(s <= 32)
	return ((val << s) | (val >> (32-s)))
    else
	return 0;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: lcrs
//
// Parameters:
//    long val     -   32-bit value.
//    long shift   -   Number of bits to shift right.
//
// Returns:
//    long   -   32-bit value.
//
// Description:
//    Takes a long parameter, val, and a shift value, s, and returns a value which is a circular right shift of the 
//    original value, shifted s bits.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function long lcrs(long val, integer s) {
    if(s <= 32)
	return ((val << (32-s)) | (val >> (s)))
    else
	return 0;
}


#end_if
