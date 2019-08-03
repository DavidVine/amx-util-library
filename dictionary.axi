PROGRAM_NAME='dictionary'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: dictionary
// 
// Description:
//
//   - This include file provides structures and functions for keeping data in key/value pairs (i.e., a dictionary).
//
// Implementation:
//
//   - Any NetLinx program utilising the dictionary include file must use either the INCLUDE or #INCLUDE keywords to 
//     include the dictionary include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//     functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE 
//     keyword is from the earlier Axcess programming language and is included within the NetLinx programming language 
//     for backwards compatibility).
//
//     E.g:
//
//        DEFINE_PROGRAM 'KeyVal Pair Demo'
//
//        #INCLUDE 'dictionary'
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __DICTIONARY__
#define __DICTIONARY__


DEFINE_CONSTANT

integer DICTIONARY_MAX_KEY_LENGTH = 100;
integer DICTIONARY_MAX_VAL_LENGTH = 500;
integer DICTIONARY_MAX_KEY_VAL_PAIRS = 256;


DEFINE_TYPE

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
DEFINE_FUNCTION integer dictionaryAdd (Dictionary dict, char key[], char val[]) {

	if((key == '') || // empty key
	   (val == '') || // empty value
	   (length_array(dict.keyVals) == max_length_array(dict.keyVals)) || // dictionary full
	   (dictionaryGetValue(dict,key) == val)) // same key/val already stored in dictionary
		return false;

	if(dictionaryGetIndex(dict,key)) { // the key exists in the dictionary and since we already know it doesn't have the value we want to add we need to replace it
		dict.keyVals[dictionaryGetIndex(dict,key)].val = val;
	}
	else {
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
DEFINE_FUNCTION integer dictionaryRemove (Dictionary dict, char key[]) {
	stack_var integer idx;

	idx = dictionaryGetIndex(dict, key);

	if((key == '') ||             // key empty
	   (!idx)) // key does not exist in dictionary
		return false;

	while(idx <= length_array(dict.keyVals)) {
		if(idx == length_array(dict.keyVals)) {
			dict.keyVals[idx].key = '';
			dict.keyVals[idx].val = '';
			set_length_array(dict.keyVals,length_array(dict.keyVals)-1);
		}
		else {
			dict.keyVals[idx].key = dict.keyVals[idx+1].key;
			dict.keyVals[idx].val = dict.keyVals[idx+1].val;
		}
		idx++;
	}

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
DEFINE_FUNCTION char[DICTIONARY_MAX_VAL_LENGTH] dictionaryGetValue(Dictionary dict, char key[]) {
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
DEFINE_FUNCTION integer dictionaryGetIndex(Dictionary dict, char key[]) {
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
DEFINE_FUNCTION dictionaryClear(Dictionary dict) {
	stack_var integer i;

	for(i = 1; i <= max_length_array(dict.keyVals); i++) {
		dict.keyVals[i].key = '';
		dict.keyVals[i].val = '';
	}
	set_length_array(dict.keyVals,0);
}

#end_if
