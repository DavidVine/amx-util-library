program_name='debug'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: debug
// 
// Description:
//
//    - This include file provides useful fuctions for debugging a NetLinx program.
//
// Implementation:
//
//    - Any NetLinx program utilising the debug include file must use either the INCLUDE or #INCLUDE keywords to 
//      include the debug include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//      functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE
//      keyword is from the earlier Axcess programming language and is included within the NetLinx programming language 
//      for backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'Debugging Demo'
//
//          #include 'debug'
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __DEBUG__
#define __DEBUG__


define_variable

volatile debug = false;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: print
//
// Parameters:
//    char data[]         -   A character array of undetermined size containing data to print.
//    integer multiLine   -   An integer containing a true/false value indicating whether the data should be printed
//                            over multiple lines (if it contains carriage returns or line feeds).
//
// Returns:
//    nothing
//
// Description:
//    Sends data to the master for debugging purposes. Data can be viewed in the Diagnostics tab of the NetLinx Studio
//    application or by opening a telnet session to the master and typing "msg on".
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function print(char data[], integer multiLine) {
	stack_var char temp[20000]

	if(debug) {
		if(!multiLine) {
			send_string 0, "'DEBUG: ',data"
		} else {
			temp = data;
			while(find_string(temp,"$0D",1) || find_string(temp,"$0A",1)) {
				stack_var integer crIdx, lfIdx, crLfIdx;

				crIdx = find_string(temp,"$0D",1);
				lfIdx = find_string(temp,"$0A",1);
				crLfIdx = find_string(temp,"$0D,$0A",1);

				if((lfIdx) && ((!crIdx) || (lfIdx < crIdx)) && ((!crLfIdx) || (lfIdx < crLfIdx))) {
					send_string 0, "'DEBUG: ',remove_string(temp,"$0A",1)"
				} else if(crIdx) {
					if((crIdx && crLfIdx) && (crIdx == crLfIdx)) {
						send_string 0, "'DEBUG: ',remove_string(temp,"$0D,$0A",1)"
					} else{
						send_string 0, "'DEBUG: ',remove_string(temp,"$0D",1)"
					}
				}
			}
			send_string 0, "'DEBUG: ',remove_string(temp,temp,1)"
		}
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: printHex
//
// Parameters:
//    char data[]   -   A character array of undetermined size containing data to print.
//
// Returns:
//    nothing
//
// Description:
//    Sends an ASCII Hex representation of the data to the master for debugging purposes. Data can be viewed in the 
//    Diagnostics tab of the NetLinx Studio application or by opening a telnet session to the master and typing 
//    "msg on".
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function printHex(char data[]) {
	char result[5000];
	integer i,count;
	long len;

	len = length_array(data);

	for(i=1,count=1; i<=length_string(data); i++,count++) {
		result = "result,format('%02X',data[i])"
	}
	print("result",false);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: printHexBlock
//
// Parameters:
//    char data[]   -   A character array of undetermined size containing data to print.
//
// Returns:
//    nothing
//
// Description:
//    Sends an ASCII Hex representation of the data to the master for debugging purposes. A space ' ' character is
//    placed between every 4th hex value and a new line is printed after every 16th hex value. Data can be viewed in 
//    the Diagnostics tab of the NetLinx Studio application or by opening a telnet session to the master and typing 
//    "msg on".
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function printHexBlock(char data[]) {
	char result[5000];
	integer i,count;
	long len;

	len = length_array(data);

	for(i=1,count=1; i<=length_string(data); i++,count++) {
		result = "result,format('%02X',data[i])"

		if(count == 16) {
			print("result",false);
			count = 0;
			result = '';
		} else if((count %4) == 0) {
			result = "result,' '"
		}
	}
	if(count <16) {
			print("result",false);
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: devToString
//
// Parameters:
//    dev device   -   A NetLinx device
//
// Returns:
//    char[17]   -   A character array containing a string in the form D:P:S
//
// Description:
//    Takes a NetLinx device and returns a string containing an ASCII representation of the device number, port, and 
//    system in the D:P:S form number:port:system (e.g., '10001:1:0')
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[17] devToString(dev device) {
	return "itoa(device.number),':',itoa(device.port),':',itoa(device.system)"
}


#end_if
