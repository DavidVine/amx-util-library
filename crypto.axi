program_name='crypto'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: crypto
// 
// Description:
//
//    - This include file includes all high-level cryptography libraries:
//
//          codec  - for encoding/decoding
//          cipher - for encypting/decrypting
//          hash   - for hashing
//
// Implementation:
//
//    - Any NetLinx program utilising the crypto include file must use either the INCLUDE or #INCLUDE keywords to 
//      include the crypto include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//      functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE 
//      keyword is from the earlier Axcess programming language and is included within the NetLinx programming language 
//      for backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'Cryptography Demo'
//
//          #include 'crypto'
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __CRYPTO__
#define __CRYPTO__


#include 'codec'  // encoding / decoding
#include 'cipher' // encypting / decypting
#include 'hash'   // hashing (message digest)


#end_if
