program_name='proto'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: proto
// 
// Description:
//
//    - This include file includes all protocol libraries.
//
// Implementation:
//
//    - Any NetLinx program utilising the proto include file must use either the INCLUDE or #INCLUDE keywords to 
//      include the proto include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//      functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE 
//      keyword is from the earlier Axcess programming language and is included within the NetLinx programming language 
//      for backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'Protocol Demo'
//
//          #include 'proto'
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __PROTO__
#define __PROTO__


#include 'http'         // HTTP
#include 'json'         // JSON
#include 'uri'          // URI / URL
#include 'websockets'   // WebSockets
#include 'xml'          // XML


#end_if
