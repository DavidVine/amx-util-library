program_name='dictionary'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: dictionary
// 
// Description:
//
//    - This include file provides structures and functions for keeping data in key/value pairs (i.e., a dictionary).
//
// Implementation:
//
//    - Any NetLinx program utilising the dictionary include file must use either the INCLUDE or #INCLUDE keywords to 
//      include the dictionary include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//      functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE 
//      keyword is from the earlier Axcess programming language and is included within the NetLinx programming language 
//      for backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'KeyVal Pair Demo'
//
//          #include 'dictionary'
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __DICTIONARY__
#define __DICTIONARY__


define_constant

integer DICTIONARY_MAX_KEY_LENGTH = 100;
integer DICTIONARY_MAX_VAL_LENGTH = 500;
integer DICTIONARY_MAX_KEY_VAL_PAIRS = 256;


define_type

struct DictionaryEntry {
	char key[DICTIONARY_MAX_KEY_LENGTH];
	char val[DICTIONARY_MAX_VAL_LENGTH];
}

struct Dictionary {
	DictionaryEntry keyVals[DICTIONARY_MAX_KEY_VAL_PAIRS];
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: dictionaryAdd
//
// Parameters:
//    Dictionary dict   -   A dictionary used to store key/val pairs.
//    char key[]        -   A character array of undefined length containing a key to add to the dictionary.
//
// Returns:
//    integer   -   An integer containing either true (1) or false(0) indicating successful addition of the key/val 
//                  pair.
//
// Description:
//    Adds the key/val pair to the dictionary if the key does not already exist and returns a true (1) result. If the
//    key already exists the associated value is simply updated and a true (1) result is returned. Neither the key nor
//    value can be empty or the process will be aborted and a false (0) result will be returned. A false (0) result
//    will also be returned if the dictionary is already full or the key/val pair already exists within the dictionary.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function integer dictionaryAdd (Dictionary dict, char key[], char val[]) {
	stack_var integer idx;

	if((key == '') || // empty key
	   (val == '') || // empty value
	   (dictionaryGetValue(dict,key) == val)) // same key/val already stored in dictionary
		return false;
	
	idx = dictionaryGetIndex(dict, key);

	if(idx) { // the key exists in the dictionary and since we already know it doesn't have the value we want to add we need to replace it
		dict.keyVals[idx].val = val;
	} else if(length_array(dict.keyVals) == max_length_array(dict.keyVals)) { // dictionary full
		return false;
	}	else {
		set_length_array(dict.keyVals,length_array(dict.keyVals)+1);
		dict.keyVals[length_array(dict.keyvals)].key = key;
		dict.keyVals[length_array(dict.keyvals)].val = val;
	}

	return true;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: dictionaryRemove
//
// Parameters:
//    Dictionary dict   -   A dictionary used to store key/val pairs.
//    char key[]        -   A character array of undefined length containing a key to search with.
//
// Returns:
//    integer   -   An integer containing either true (1) or false(0) indicating successful removal of the key/val 
//                  pair.
//
// Description:
//    Searches the dictionary for a matching key and if found deletes the key and associated value from the dictionary
//    and returns a true (1) result otherwise returns a false (0) result.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function integer dictionaryRemove (Dictionary dict, char key[]) {
	stack_var integer idx;

	idx = dictionaryGetIndex(dict, key);

	if((key == '') ||             // key empty
	   (!idx)) // key does not exist in dictionary
		return false;

	if(idx < length_array(dict.keyVals)) {
		dict.keyVals[idx].key = dict.keyVals[length_array(dict.keyVals)].key;
		dict.keyVals[idx].val = dict.keyVals[length_array(dict.keyVals)].val;
		dict.keyVals[length_array(dict.keyVals)].key = '';
		dict.keyVals[length_array(dict.keyVals)].val = '';
	}
	else {
		dict.keyVals[idx].key = '';
		dict.keyVals[idx].val = '';
	}
	set_length_array(dict.keyVals,length_array(dict.keyVals)-1);

	return true;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: dictionaryGetValue
//
// Parameters:
//    Dictionary dict   -   A dictionary used to store key/val pairs.
//    char key[]        -   A character array of undefined length containing a key to search with.
//
// Returns:
//    char[DICTIONARY_MAX_VAL_LENGTH]   -   A character array containing the value.
//
// Description:
//    Searches the dictionary for a matching key and if found returns the associated value otherwise returns an empty 
//    string ('').
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[DICTIONARY_MAX_VAL_LENGTH] dictionaryGetValue(Dictionary dict, char key[]) {
	stack_var integer i;
	i = 1;
	while(i <= length_array(dict.keyVals)) {
		if(dict.keyVals[i].key == key)
			return dict.keyVals[i].val;
		i++;
	}
	return '';
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: dictionaryGetValueIgnoreKeyCase
//
// Parameters:
//    Dictionary dict   -   A dictionary used to store key/val pairs.
//    char key[]        -   A character array of undefined length containing a key to search with
//
// Returns:
//    char[DICTIONARY_MAX_VAL_LENGTH]   -   A character array containing the value.
//
// Description:
//    Searches the dictionary for a matching key (case insensitive) and if found returns the associated value otherwise
//    returns an empty string ('').
//    Note: Because search is for a case-insensitive match and there may be multiple keys with the same spelling (but
//          different case (e.g: 'KEYA', 'KeYa') the result will be the first key with matching spelling, regardless of
//          case.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[DICTIONARY_MAX_VAL_LENGTH] dictionaryGetValueIgnoreKeyCase(Dictionary dict, char key[]) {
	stack_var integer i;
	i = 1;
	while(i <= length_array(dict.keyVals)) {
		if(upper_string(dict.keyVals[i].key) == upper_string(key))
			return dict.keyVals[i].val;
		i++;
	}
	return '';
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: dictionaryGetIndex
//
// Parameters:
//    Dictionary dict   -   A dictionary used to store key/val pairs.
//    char key[]        -   A character array of undefined length containing a key to search with.
//
// Returns:
//    integer   -   An integer containing the index within the dictionary where the key is stored.
//
// Description:
//    Searches the dictionary for a matching key and if found returns the index it is stored at otherwise returns 0.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function integer dictionaryGetIndex(Dictionary dict, char key[]) {
	stack_var integer i;
	i = 1;
	while(i <= length_array(dict.keyVals)) {
		if(dict.keyVals[i].key == key)
			return i;
		i++;
	}
	return 0;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: dictionaryClear
//
// Parameters:
//    Dictionary dict   -   A dictionary used to store key/val pairs.
//
// Returns:
//    nothing
//
// Description:
//    Clears the dictionary of all key/val pairs
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function dictionaryClear(Dictionary dict) {
	stack_var integer i;

	for(i = 1; i <= max_length_array(dict.keyVals); i++) {
		dict.keyVals[i].key = '';
		dict.keyVals[i].val = '';
	}
	set_length_array(dict.keyVals,0);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: dictionaryCopy
//
// Parameters:
//    Dictionary dictCopyFrom   -   A dictionary used to store key/val pairs.
//    Dictionary dictCopyTo     -   A dictionary used to store key/val pairs.
//
// Returns:
//    nothing
//
// Description:
//    Copies one dictionary to another
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function dictionaryCopy(Dictionary dictCopyFrom,Dictionary dictCopyTo) {
	stack_var integer i;

	dictionaryClear(dictCopyTo);

	for(i = 1; i <= length_array(dictCopyFrom.keyVals); i++) {
		dictCopyTo.keyVals[i].key = dictCopyFrom.keyVals[i].key;
		dictCopyTo.keyVals[i].val = dictCopyFrom.keyVals[i].val;
	}
	set_length_array(dictCopyTo.keyVals,length_array(dictCopyFrom.keyVals));
}


#end_if
