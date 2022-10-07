program_name='string'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: string
// 
// Description:
//
//    - This include file provides extra string operation functions not natively provided in NetLinx.
//
// Implementation:
//
//    - Any NetLinx program utilising the string include file must use either the INCLUDE or #INCLUDE keywords to 
//      include the string include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//      functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE 
//      keyword is from the earlier Axcess programming language and is included within the NetLinx programming language 
//      for backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'String Demo'
//
//          #include 'string'
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __STRING__
#define __STRING__


define_constant

char CR = $0D;
char LF = $0A;
char CRLF[] = {CR,LF};
char SPACE = ' ';
char TABH = $09;
char TABV = $11;
char ESC = $27;
char NULL = $00;
char SOH = $01;
char STX = $02;
char ETX = $03;
char EOT = $04;
char ACK = $06;
char BS = $08;
char NAK = $21;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: removeLeadingChars
//
// Parameters:
//  	char str[]  - String to remove leading characters from
//  	char mask[] - Character mask
//
// Returns:
//    nothing
//
// Description:
//    Removes any leading characters listed in the character mask from the string. Order of characters in character mask
//    is not important.
//    E.g:
//      sAlphabet = 'abcdefghijlkmnopqrstuvwxyz'
//      removeTrailingChars(sAlphabet,'abc')	// alphabet is now 'defghijlkmnopqrstuvwxyz'
//    E.g:
//      sAlphabet = 'abcdefghijlkmnopqrstuvwxyz'
//      removeTrailingChars(sAlphabet,'bac')	// alphabet is now 'defghijlkmnopqrstuvwxyz'
//    E.g:
//      sAlphabet = 'aaabbbcccdddeeefffggg'
//      removeTrailingChars(sAlphabet,'ba')	// alphabet is now 'cccdddeeefffggg'
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function removeLeadingChars(char str[], char mask[]) {
	while(find_string(mask,"str[1]",1)) {
		str = right_string(str,length_string(str)-1);
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: removeTrailingChars
//
// Parameters:
//  	char str[]  - String to remove trailing characters from
//  	char mask[] - Character mask
//
// Returns:
//    nothing
//
// Description:
//    Removes any trailing characters listed in the character mask from the string. Order of characters in character mask
//    is not important.
//    E.g:
//      sAlphabet = 'abcdefghijlkmnopqrstuvwxyz'
//      removeTrailingChars(sAlphabet,'xyz')	// alphabet is now 'abcdefghijlkmnopqrstuvw'
//    E.g:
//      sAlphabet = 'abcdefghijlkmnopqrstuvwxyz'
//      removeTrailingChars(sAlphabet,'zxy')	// alphabet is now 'abcdefghijlkmnopqrstuvw'
//    E.g:
//      sAlphabet = 'aaabbbcccdddeeefffggg'
//      removeTrailingChars(sAlphabet,'fg')	// alphabet is now 'aaabbbcccdddeee'
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function removeTrailingChars(char str[], char mask[]) {
	while(find_string(mask,"str[length_string(str)]",1)) {
		str = left_string(str,length_string(str)-1);
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: trim_string
//
// Parameters:
//  	char str[]    - String to trim
//  	integer ltrim - Number of characters to trim from the left of the string
//    integer rtrim - Number of characters to trim from the right of the string
//
// Returns:
//    nothing
//
// Description:
//    Trims the string from the left and right.
//    E.g:
//      sAlphabet = 'abcdefghijlkmnopqrstuvwxyz'
//      trim(sAlphabet,3,5)	// alphabet is now 'defghijlkmnopqrstu'
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function trim_string(char str[], integer ltrim, integer rtrim) {
	if((ltrim+rtrim) >= length_string(str))
		str = '';
	else
		str = mid_string(str,ltrim+1,length_string(str)-ltrim-rtrim);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: delete_string
//
// Parameters:
//  	char strSearch[] - String to search
//  	char strParse[]  - String to search for
//
// Returns:
//    nothing
//
// Description:
//    Searches a string for the first occurance of a defined substring and if found removes the first occurance of that
//    substring from the search string and returns a true result. If the substring is not found a false result is 
//    returned.
//    Not to be confused with the REMOVE_STRING function which deletes everything up to and including the substring 
//    from the string being searched and then returns the deleted string.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function integer delete_string(char strSearch[], char strParse[]) {
	stack_var integer indexParse;

	if((strSearch == '') || (strParse == ''))
		return false;

	indexParse = find_string(strSearch,strParse,1);
	
	if(!indexParse)
		return false;

	strSearch = "mid_string(strSearch,
	                        1,
	                        (indexParse-1)),
	             mid_string(strSearch,
	                        (indexParse+length_string(strParse)),
	                        (length_string(strSearch)-(indexParse+length_string(strParse))+1))"

	return true;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: replace_string
//
// Parameters:
//  	char strSearch[]      - String to search
//  	char strToReplace[]   - String to be replaced
//    char strReplacement[] - String to use as the rpelacement
//
// Returns:
//    nothing
//
// Description:
//    Searches a string for a substring and if found removes the substring and inserts a new string in place.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function integer replace_string(char strSearch[], char strToReplace[], char strReplacement[]) {
	stack_var integer indexReplace;

	if((strSearch == '') || (strToReplace == ''))
		return false;

	indexReplace = find_string(strSearch,strToReplace,1);

	if(!indexReplace)
		return false;

	strSearch = "mid_string(strSearch,
	                        1,
	                        (indexReplace-1)),
	             strReplacement,
	             mid_string(strSearch,
	                        (indexReplace+length_string(strToReplace)),
	                        (length_string(strSearch)-(indexReplace+length_string(strToReplace))+1))"

	return true;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: append_string
//
// Parameters:
//  	char str[]      -   String to be appended to
//  	char append[]   -   String to append
//
// Returns:
//    nothing
//
// Description:
//    Appends one string onto another. Equivalent to string concatentation in NetLinx.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function append_string(char str[], char append[]) {
	str = "str,append";
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: insert_string
//
// Parameters:
//  	char str[]      -   String to insert another string into
//  	integer index   -   index where string is to be inserted
//  	char insert[]   -   String to be inserted
//
// Returns:
//    nothing
//
// Description:
//    Inserts one string into another at the designated index.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function insert_string(char str[], integer index, char insert[]) {
	if((index = 0) || (index == 1))
		str = "insert,str";
	else if (index > length_string(str))
		str = "str,insert";
	else if (index <= length_string(str))
		str = "left_string(str,index-1),insert,mid_string(str,index,length_string(str))"
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: hex
//
// Parameters:
//    char msg[]   -   A character array of undertermined length
//
// Returns:
//    char[5000]   -   A character array (string) containing the value in uppercase hexadecimal ASCII formatting
//
// Description:
//    Returns an all uppercase hexidecimal formatted ASCII string representing the value of the data passed through.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[5000] hex(char data[]) {
	char result[5000];
	integer i,count;
	long len;

	len = length_array(data);

	for(i=1,count=1; i<=length_string(data); i++,count++) {
		result = "result,format('%02X',data[i])"
	}
	return result;
}


#end_if
