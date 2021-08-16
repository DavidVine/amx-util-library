program_name='uri'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: uri
// 
// Description:
//
//    - This include file provides functions for working with URI's as defined RFC 3986 (see 
//      https://tools.ietf.org/html/rfc3986).
//
// Implementation:
//
//    - Any NetLinx program utilising the uri include file must use either the INCLUDE or #INCLUDE keywords to include 
//      the uri include file within the program. While the INCLUDE and #INCLUDE keywords are both functionally 
//      equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE keyword is 
//      from the earlier Axcess programming language and is included within the NetLinx programming language for 
//      backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'URI Demo'
//
//          #include 'uri'
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __URI__
#define __URI__


#include 'string'


define_type

struct Uri {
	char scheme[30];
	char user[50];
	char password[50];
	char host[200];
	integer port;
	char path[200];
	char query[200];
	char fragment[200];
}


define_constant

char URI_RESERVED_CHARACTERS  [] = {':','/','?','#','[',']','@','!','$','&',$27,'(',')','*','+',',',';','='};
char URI_UNRESERVED_CHARACTERS[] = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~';


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: uriToString
//
// Parameters:
//    Uri u   -   A URI object
//
// Returns:
//    char[1500]   -   A character array containing the URI in string forms
//
// Description:
//    Takes a URI object and returns a URI formatted string.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[1500] uriToString(Uri u) {
	char result[1500];

	if(length_array(u.scheme)) {
		result = "result,u.scheme,':'";
	}

	if(length_array(u.host)) {
		result = "result,'//'";
		if(length_array(u.user) && length_array(u.password)) result = "result,u.user,':',u.password,'@'";
		result = "result,u.host";
		if(u.port) result = "result,':',itoa(u.port)";
		if(find_string(u.path,"'/'",1) == 1) {
			result = "result,u.path";
		} else {
			result = "result,'/',u.path";
		}
	} else {
		result = "result,u.path";
	}

	if(length_array(u.query)) {
		result = "result,'?',u.query"
	}

	if(length_array(u.fragment)) {
		result = "result,'#',u.fragment"
	}

	return result;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: uriFromString
//
// Parameters:
//    Uri u        -   A URI object
//    char str[]   -   A character array of undetermined length
//
// Returns:
//    nothing
//
// Description:
//    Takes a URI object and a character array assumed to be containing a URI string. Parses the URI string and updates
//    the values of the URI object to match the parsed results.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function uriFromString(Uri u, char str[]) {
	stack_var char temp[200]
	stack_var integer idx;
	stack_var char scheme[20], authority[300], path[200], query[200], fragment[200];
	stack_var char user[50], password[50], host[200];
	integer port;

	temp = str;

	scheme = remove_string(temp,"':'",1);
	trim_string(scheme,0,1);

	if(find_string(temp,"'//'",1)) { // contains authority
		remove_string(temp,"'//'",1);

		if(find_string(temp,"'/'",1)) { // contains path
			idx = (find_string(temp,"'/'",1)-1)
		} else if(find_string(temp,"'?'",1)) { // contains query
			idx = (find_string(temp,"'?'",1)-1)
		} else if(find_string(temp,"'#'",1)) { // contains fragment
			idx = (find_string(temp,"'#'",1)-1)
		} else {
			idx = length_string(temp);
		}

		authority = mid_string(temp,1,idx);
		remove_string(temp,authority,1);
	}

	if(find_string(temp,"'/'",1)) { // contains path

		if(find_string(temp,"'?'",1)) { // contains query
			idx = (find_string(temp,"'?'",1)-1)
		} else if(find_string(temp,"'#'",1)) { // contains fragment
			idx = (find_string(temp,"'#'",1)-1)
		} else {
			idx = length_string(temp);
		}

		path = mid_string(temp,1,idx);
		remove_string(temp,path,1);
	} else {
		if(find_string(temp,"'?'",1)) {
			path = mid_string(temp,1,find_string(temp,"'?'",1)-1)
			remove_string(temp,path,1);
		} else if(find_string(temp,"'#'",1)) {
			path = mid_string(temp,1,find_string(temp,"'#'",1)-1)
			remove_string(temp,path,1);
		}
	}

	if(find_string(temp,"'?'",1)) { // contains query
		remove_string(temp,"'?'",1);

		if(find_string(temp,"'#'",1)) { // contains fragment
			idx = (find_string(temp,"'#'",1)-1)
		} else {
			idx = length_string(temp);
		}

		query = mid_string(temp,1,idx);
		remove_string(temp,query,1);
	}

	if(find_string(temp,"'#'",1)) { // contains fragment
		remove_string(temp,"'#'",1);

		idx = length_string(temp);

		fragment = mid_string(temp,1,idx);
		remove_string(temp,fragment,1);
	}

	// break-apart the authority [user:password@]host[:port]
	temp = authority;
	if(find_string(temp,"'@'",1)) {
		user = remove_string(temp,"':'",1)
		trim_string(user,0,1);
		password = remove_string(temp,"'@'",1)
		trim_string(password,0,1);
	}

	if(find_string(temp,"':'",1)) {
		host = remove_string(temp,"':'",1)
		trim_string(host,0,1);
		port = atoi(temp);
	} else {
		host = temp;
	}

	u.scheme = scheme;
	u.user = user
	u.password = password
	u.host = host;
	u.path = path;
	u.port = port
	u.query = query;
	u.fragment = fragment;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: uriPercentEncodeString
//
// Parameters:
//    char u[]   -   A character array of undetermined length
//
// Returns:
//    char[2048]   -   A character array containing a percent-encoded string
//
// Description:
//    Takes a character array (string) and returns a string containing a percent-encoded version of that string.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[2048] uriPercentEncodeString(char u[]) {
	stack_var char i;
	stack_var char c;
	stack_var char encoded[2048];

	for(i = 1; i <= length_string(u); i++) {
		c = u[i];
		if(uriIsReservedChar(c) || uriIsUnreservedChar(c)) {
			append_string(encoded,"c");
		}
		else {
			append_string(encoded,uriPercentEncodeChar(c));
		}
	}

	return encoded;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: uriPercentEncodeChar
//
// Parameters:
//    char c   -   A char value
//
// Returns:
//    char[3]   -   A character array containing a percent-encoded string
//
// Description:
//    Takes a character and returns a string containing a percent-encoded version of that character.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[3] uriPercentEncodeChar(char c) {
	return "'%',format('%02X',"c")";
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: uriIsReservedChar
//
// Parameters:
//    char c   -   A char value
//
// Returns:
//    integer   -   An integer containing either a true (1) or false (0) value
//
// Description:
//    Takes a character and returns a true|false result indicating whether the character would be a reserved character 
//    in a URI.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function integer uriIsReservedChar(char c) {
	return (find_string(URI_RESERVED_CHARACTERS,"c",1))
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: uriIsUnreservedChar
//
// Parameters:
//    char c   -   A char value
//
// Returns:
//    integer   -   An integer containing either a true (1) or false (0) value
//
// Description:
//    Takes a character and returns a true|false result indicating whether the character would not be a reserved 
//    character in a URI (i.e., is it unreserved?)
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function integer uriIsUnreservedChar(char c) {
	return (find_string(URI_UNRESERVED_CHARACTERS,"c",1))
}


#end_if
