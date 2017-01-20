PROGRAM_NAME='http'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: http
// 
// Description:
//
//   - This include file provides structures and functions for managing Hypertext Transfer Protocol (HTTP) as
//     defined in RFC 2616 (see https://tools.ietf.org/html/rfc2616).
//
//   - The HttpMessage data type defined within the http include, along with various functions, can be used
//     to simplify the building and parsing of HTTP protocol strings.
//
// Implementation:
//
//   - Any NetLinx program utilising the http include file must use either the INCLUDE or #INCLUDE keywords to 
//     include the http include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//     functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE 
//     keyword is from the earlier Axcess programming language and is included within the NetLinx programming language 
//     for backwards compatibility).
//
//     E.g:
//
//        DEFINE_PROGRAM 'HTTP Client Demo'
//
//        #INCLUDE 'http'
//
//   - To create a HTTP message the main program needs to define a variable of type HttpMessage and then call the
//     'httpSet' functions within the http include to build the message. The HttpMessage variable is always passed
//     to the 'httpSet' functions as the first argument and will be updated within the function (note NetLinx is
//     pass-by-reference).
//
//     E.g:
//
//        HttpMessage http;
//
//        httpSetType_Request(http);
//        httpSetVersion(http,1.1);
//        httpSetMethod_Get(http);
//        httpSetResourcePath(http,'/path/file.html');
//        httpSetHeader(http,'From','someuser@jmarshall.com');
//        httpSetHeader(http,'User-Agent','HTTPTool/1.0');
//
//     When the HTTP message has been built it can easily be converted to string form as required by calling the
//     httpToString function:
//
//     E.g:
//
//        send_string dvSocketWebServer, httpToString(http);
//
//     The generic httpSetHeader function can be used to set the value of any header within the HTTP message:
//
//     E.g:
//
//        httpSetHeader(http,'Connection','close');
//
//     And constants are provided within the http include which can be used to further reduce the likelihood of errors 
//     from typos in the header field string:
//
//     E.g:
//
//        httpSetHeader(http,HTTP_HEADER_FIELD_CONNECTION,'close');
//
//     The HTTP method (PUT|GET|POST, etc...) can be set either by the generic httpSetMethod function:
//
//     E.g.1:
//
//        httpSetMethod(http,'POST');
//
//     E.g.2:
//
//        httpSetMethod(http,HTTP_METHOD_POST);
//
//     Or through the use of specific httpSetMethod_ functions:
//
//     E.g:
//
//        httpSetMethod_Post(http);
//
//
//   - To parse a received HTTP message create a HttpMessage variable and pass it and the data received on the TCP/IP
//     socket to the httpFromString function:
//
//     E.g:
//
//        DATA_EVENT[dvSocketWebServer]
//        {
//           STRING:
//           {
//              HttpMessage http;
//              httpFromString(http,data.text);
//
//     The HttpMessage variable will now contain all the information specified within the HTTP string and can be
//     easily searched using the various httpGet methods defined within the http include.
//
//     E.g:
//
//        httpGetType(http) // returns character string as either 'Request' or 'Response'
//        httpGetStatusCode(http) // returns integer containing status code (e.g., 401)
//        httpGetReasonPhrase(http) // returns character string containing reason phrase (e.g., 'Bad Request')
//
//     HTTP header values can be searched for using the httpGetHeader function:
//
//     E.g.1:
//
//        strStatus = httpGetHeader(http,'Status') // returns character string containing value of Status header field (e.g., '200 OK')
//
//     E.g.2:
//
//        strLocation = httpGetHeader(http,HTTP_HEADER_FIELD_LOCATION) // returns character string containing value of Location header field (e.g., 'http://www.w3.org/pub/WWW/People.html')
//
//     NOTE: HTTP (as defined in RFC 2616) defines seperate header fields for HTTP response and HTTP request messages.
//     All header field constant identifiers within the http include are prefixed with 'HTTP_HEADER_FIELD_' however
//     they are seperated into two-commented groups clearly identifying which values relate to response messages and
//     which relate to request messages.
//
//   - The printHttp function is provided for troubleshooting. Calling this function and passing a HttpMessage variable
//     through will cause the NetLinx master to print the contents of the HttpMessage as a HTTP string in Diagnostics.
//
//     E.g:
//
//        printHttp(http);
//
//
//   - To aid in reusability a HttpMessage variable can be reset at any time by calling the httpClear function:

//     E.g:
//
//        httpClear(http);
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#IF_NOT_DEFINED __HTTP__
#DEFINE __HTTP__


#include 'dictionary'
#include 'string'
#include 'uri'


DEFINE_CONSTANT

long HTTP_MAX_SIZE_MESSAGE_BODY = 65535 //99999999; - takes 20 seconds to compile //1073741824; - 1MB takes extremely long time to compile


DEFINE_TYPE

STRUCT HttpMessage {
	char type[8];            // is this a 'request' or 'response' message?
	// Initial Line
	float version;          // request and response
	char method[10];        // request only
	char resourcePath[200]; // request only
	integer statusCode;     // response only
	char reasonPhrase[100]; // response only
	// Header Lines
	Dictionary headers; // request and response
	// Message Body
	char body[HTTP_MAX_SIZE_MESSAGE_BODY];	// request and response
}


DEFINE_CONSTANT

char HTTP_VERSION_1_0[] = 'HTTP/1.0';
char HTTP_VERSION_1_1[] = 'HTTP/1.1';

// Informational Status Codes
integer HTTP_STATUS_CODE_CONTINUE            = 100; // Only a part of the request has been received by the server, but as long as it has not been rejected, the client should continue with the request.
integer HTTP_STATUS_CODE_SWITCHING_PROTOCOLS = 101; // The server switches protocol.

// Successful Status Codes
integer HTTP_STATUS_CODE_OK                            = 200; // The request is OK.
integer HTTP_STATUS_CODE_CREATED                       = 201; // The request is complete, and a new resource is created.
integer HTTP_STATUS_CODE_ACCEPTED                      = 202; // The request is accepted for processing, but the processing is not complete.
integer HTTP_STATUS_CODE_NON_AUTHORITATIVE_INFORMATION = 203; // The information in the entity header is from a local or third-party copy, not from the original server.
integer HTTP_STATUS_CODE_NO_CONTENT                    = 204; // A status code and a header are given in the response, but there is no entity-body in the reply.
integer HTTP_STATUS_CODE_RESET_CONTENT                 = 205; // The browser should clear the form used for this transaction for additional input.
integer HTTP_STATUS_CODE_PARTIAL_CONTENT               = 206; // The server is returning partial data of the size requested. Used in response to a request specifying a Range header. The server must specify the range included in the response with the Content-Range header.

// Redirection Status Codes
integer HTTP_STATUS_CODE_MULTIPLE_CHOICES   = 300; // A link list. The user can select a link and go to that location. Maximum five addresses.
integer HTTP_STATUS_CODE_MOVED_PERMANENTLY  = 301; // The requested page has moved to a new url.
integer HTTP_STATUS_CODE_FOUND              = 302; // The requested page has moved temporarily to a new url.
integer HTTP_STATUS_CODE_SEE_OTHER          = 303; // The requested page can be found under a different url.
integer HTTP_STATUS_CODE_NOT_MODIFIED       = 304; // This is the response code to an If-Modified-Since or If-None-Match header, where the URL has not been modified since the specified date.
integer HTTP_STATUS_CODE_USE_PROXY          = 305; // The requested URL must be accessed through the proxy mentioned in the Location header.
integer HTTP_STATUS_CODE_UNUSED             = 306; // This code was used in a previous version. It is no longer used, but the code is reserved.
integer HTTP_STATUS_CODE_TEMPORARY_REDIRECT = 307; // The requested page has moved temporarily to a new url.

// Client Error Status Codes
integer HTTP_STATUS_CODE_BAD_REQUEST                   = 400; // The server did not understand the request.
integer HTTP_STATUS_CODE_UNAUTHORIZED                  = 401; // The requested page needs a username and a password.
integer HTTP_STATUS_CODE_PAYMENT_REQUIRED              = 402; // You can not use this code yet.
integer HTTP_STATUS_CODE_FORBIDDEN                     = 403; // Access is forbidden to the requested page.
integer HTTP_STATUS_CODE_NOT_FOUND                     = 404; // The server can not find the requested page.
integer HTTP_STATUS_CODE_METHOD_NOT_ALLOWED            = 405; // The method specified in the request is not allowed.
integer HTTP_STATUS_CODE_NOT_ACCEPTABLE                = 406; // The server can only generate a response that is not accepted by the client.
integer HTTP_STATUS_CODE_PROXY_AUTHENTICATION_REQUIRED = 407; // You must authenticate with a proxy server before this request can be served.
integer HTTP_STATUS_CODE_REQUEST_TIMEOUT               = 408; // The request took longer than the server was prepared to wait.
integer HTTP_STATUS_CODE_CONFLICT                      = 409; // The request could not be completed because of a conflict.
integer HTTP_STATUS_CODE_GONE                          = 410; // The requested page is no longer available.The "Content-Length" is not defined. The server will not accept the request without it.
integer HTTP_STATUS_CODE_LENGTH_REQUIRED               = 411; // The "Content-Length" is not defined. The server will not accept the request without it.
integer HTTP_STATUS_CODE_PRECONDITION_FAILED           = 412; // The pre condition given in the request evaluated to false by the server.
integer HTTP_STATUS_CODE_REQUEST_ENTITY_TOO_LARGE      = 413; // The server will not accept the request, because the request entity is too large.
integer HTTP_STATUS_CODE_REQUEST_URL_TOO_LONG          = 414; // The server will not accept the request, because the url is too long. Occurs when you convert a "post" request to a "get" request with a long query information.
integer HTTP_STATUS_CODE_UNSUPPORTED_MEDIA_TYPE        = 415; // The server will not accept the request, because the mediatype is not supported.
integer HTTP_STATUS_CODE_REQUEST_RANGE_NOT_SATISFIED   = 416; // The requested byte range is not available and is out of bounds.
integer HTTP_STATUS_CODE_EXPECTATION_FAILED            = 417; // The expectation given in an Expect request-header field could not be met by this server.

// Server Error
integer HTTP_STATUS_CODE_INTERNAL_SERVER_ERROR      = 500; // The request was not completed. The server met an unexpected condition.
integer HTTP_STATUS_CODE_NOT_IMPLEMENTED            = 501; // The request was not completed. The server did not support the functionality required.
integer HTTP_STATUS_CODE_BAD_GATEWAY                = 502; // The request was not completed. The server received an invalid response from the upstream server.
integer HTTP_STATUS_CODE_SERVICE_UNAVAILABLE        = 503; // The request was not completed. The server is temporarily overloading or down.
integer HTTP_STATUS_CODE_GATEWAY_TIMEOUT            = 504; // The gateway has timed out.
integer HTTP_STATUS_CODE_HTTP_VERSION_NOT_SUPPORTED = 505; // The server does not support the "http protocol" version.


// HTTP Header Fields(Request fields)
char HTTP_HEADER_FIELD_ACCEPT              [] = 'Accept';	            // Accept: text/plain
char HTTP_HEADER_FIELD_ACCEPT_CHARSET      [] = 'Accept-Charset';      // Accept-Charset: utf-8
char HTTP_HEADER_FIELD_ACCEPT_DATETIME     [] = 'Accept-Datetime';     // Accept-Datetime: Thu, 31 May 2007 20:35:00 GMT
char HTTP_HEADER_FIELD_ACCEPT_ENCODING     [] = 'Accept-Encoding';     // Accept-Encoding: gzip, deflate
char HTTP_HEADER_FIELD_ACCEPT_LANGUAGE     [] = 'Accept-Language';     // Accept-Language: en-US
char HTTP_HEADER_FIELD_AUTHORIZATION       [] = 'Authorization';       // Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==
char HTTP_HEADER_FIELD_CACHE_CONTROL       [] = 'Cache-Control';       // Cache-Control: no-cache
char HTTP_HEADER_FIELD_CONNECTION          [] = 'Connection';          // Connection: keep-alive     |     Connection: Upgrade
char HTTP_HEADER_FIELD_CONTENT_LENGTH      [] = 'Content-Length';      // Content-Length: 348
char HTTP_HEADER_FIELD_CONTENT_MD5         [] = 'Content-MD5';         // Content-MD5: Q2hlY2sgSW50ZWdyaXR5IQ==
char HTTP_HEADER_FIELD_CONTENT_TYPE        [] = 'Content-Type';        // Content-Type: application/x-www-form-urlencoded
char HTTP_HEADER_FIELD_COOKIE              [] = 'Cookie';              // Cookie: $Version=1; Skin=new;
char HTTP_HEADER_FIELD_DATE                [] = 'Date';                // Date: Tue, 15 Nov 1994 08:12:31 GMT
char HTTP_HEADER_FIELD_EXPECT              [] = 'Expect';              // Expect: 100-continue
char HTTP_HEADER_FIELD_FORWARDED           [] = 'Forwarded';           // Forwarded: for=192.0.2.60;proto=http;by=203.0.113.43     |     Forwarded: for=192.0.2.43, for=198.51.100.17
char HTTP_HEADER_FIELD_FROM                [] = 'From';                // From: user@example.com
char HTTP_HEADER_FIELD_HOST                [] = 'Host';                // Host: en.wikipedia.org:80     |     Host: en.wikipedia.org
char HTTP_HEADER_FIELD_IF_MATCH            [] = 'If-Match';            // If-Match: "737060cd8c284d8af7ad3082f209582d"
char HTTP_HEADER_FIELD_IF_MODIFIED_SINCE   [] = 'If-Modified-Since';   // If-Modified-Since: Sat, 29 Oct 1994 19:43:31 GMT
char HTTP_HEADER_FIELD_IF_NONE_MATCH       [] = 'If-None-Match';       // If-None-Match: "737060cd8c284d8af7ad3082f209582d"
char HTTP_HEADER_FIELD_IF_RANGE            [] = 'If-Range';            // If-Range: "737060cd8c284d8af7ad3082f209582d"
char HTTP_HEADER_FIELD_IF_UNMODIFIED_SINCE [] = 'If-Unmodified-Since'; // If-Unmodified-Since: Sat, 29 Oct 1994 19:43:31 GMT
char HTTP_HEADER_FIELD_MAX_FORWARDS        [] = 'Max-Forwards';        // Max-Forwards: 10
char HTTP_HEADER_FIELD_ORIGIN              [] = 'Origin';              // Origin: http://www.example-social-network.com
char HTTP_HEADER_FIELD_PRAGMA              [] = 'Pragma';              // Pragma: no-cache
char HTTP_HEADER_FIELD_PROXY_AUTHORIZATION [] = 'Proxy-Authorization'; // Proxy-Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==
char HTTP_HEADER_FIELD_RANGE               [] = 'Range';               // Range: bytes=500-999
char HTTP_HEADER_FIELD_REFERER             [] = 'Referer';             // Referer: http://en.wikipedia.org/wiki/Main_Page
char HTTP_HEADER_FIELD_TE                  [] = 'TE';                  // TE: trailers, deflate
char HTTP_HEADER_FIELD_UPGRADE             [] = 'Upgrade';             // Upgrade: HTTP/2.0, HTTPS/1.3, IRC/6.9, RTA/x11
char HTTP_HEADER_FIELD_USER_ANGENT         [] = 'User-Agent';          // User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:12.0) Gecko/20100101 Firefox/21.0
char HTTP_HEADER_FIELD_VIA                 [] = 'Via';                 // Via: 1.0 fred, 1.1 example.com (Apache/1.1)
char HTTP_HEADER_FIELD_WARNING             [] = 'Warning';             // Warning: 199 Miscellaneous warning

// HTTP Header Fields(Response fields)
char HTTP_HEADER_FIELD_ACCESS_CONTROL_ALLOW_DEPTHs [] = 'Access-Control-Allow-Origin'; // Access-Control-Allow-Origin: *
char HTTP_HEADER_FIELD_ACCEPT_PATCH                [] = 'Accept-Patch'; // Accept-Patch: text/example;charset=utf-8
char HTTP_HEADER_FIELD_ACCEPT_RANGES               [] = 'Accept-Ranges'; // Accept-Ranges: bytes
char HTTP_HEADER_FIELD_AGE                         [] = 'Age'; // Age: 12
char HTTP_HEADER_FIELD_ALLOW                       [] = 'Allow'; // Allow: GET, HEAD
char HTTP_HEADER_FIELD_ALT_SVC                     [] = 'Alt-Svc'; // Alt-Svc: h2="http2.example.com:443"; ma=7200
//char HTTP_HEADER_FIELD_CACHE_CONTROL             [] = 'Cache-Control'; // Cache-Control: max-age=3600
//char HTTP_HEADER_FIELD_CONNECTION                [] = 'Connection'; // Connection: close
char HTTP_HEADER_FIELD_CONTENT_DISPOSITION         [] = 'Content-Disposition'; // Content-Disposition: attachment; filename="fname.ext"	
char HTTP_HEADER_FIELD_CONTENT_ENCODING            [] = 'Content-Encoding'; // Content-Encoding: gzip
char HTTP_HEADER_FIELD_CONTENT_LANGUAGE            [] = 'Content-Language'; // Content-Language: da
//char HTTP_HEADER_FIELD_CONTENT_LENGTH            [] = 'Content-Length'; // Content-Length: 348
char HTTP_HEADER_FIELD_CONTENT_LOCATION            [] = 'Content-Location'; // Content-Location: /index.htm
//char HTTP_HEADER_FIELD_CONTENT_MD5               [] = 'Content-MD5'; // Content-MD5: Q2hlY2sgSW50ZWdyaXR5IQ==
char HTTP_HEADER_FIELD_CONTENT_RANGE               [] = 'Content-Range'; // Content-Range: bytes 21010-47021/47022
//char HTTP_HEADER_FIELD_CONTENT_TYPE              [] = 'Content-Type'; // Content-Type: text/html; charset=utf-8
//char HTTP_HEADER_FIELD_DATE                      [] = 'Date'; // Date: Tue, 15 Nov 1994 08:12:31 GMT
char HTTP_HEADER_FIELD_ETAG                        [] = 'ETag'; // ETag: "737060cd8c284d8af7ad3082f209582d"
char HTTP_HEADER_FIELD_EXPIRES                     [] = 'Expires'; // Expires: Thu, 01 Dec 1994 16:00:00 GMT
char HTTP_HEADER_FIELD_LAST_MODIFIED               [] = 'Last-Modified'; // Last-Modified: Tue, 15 Nov 1994 12:45:26 GMT
char HTTP_HEADER_FIELD_LINK                        [] = 'Link'; // Link: </feed>; rel="alternate"
char HTTP_HEADER_FIELD_LOCATION                    [] = 'Location'; // Location: http://www.w3.org/pub/WWW/People.html
char HTTP_HEADER_FIELD_P3P                         [] = 'P3P'; // P3P: CP="This is not a P3P policy! See http://www.google.com/support/accounts/bin/answer.py?hl=en&answer=151657 for more info."
//char HTTP_HEADER_FIELD_PRAGMA                    [] = 'Pragma'; // Pragma: no-cache
char HTTP_HEADER_FIELD_PROXY_AUTHENTICATE          [] = 'Proxy-Authenticate'; // Proxy-Authenticate: Basic
char HTTP_HEADER_FIELD_PUBLIC_KEY_PINS             [] = 'Public-Key-Pins'; // Public-Key-Pins: max-age=2592000; pin-sha256="E9CZ9INDbd+2eRQozYqqbQ2yXLVKB9+xcprMF+44U1g=";
char HTTP_HEADER_FIELD_REFRESH                     [] = 'Refresh'; // Refresh: 5; url=http://www.w3.org/pub/WWW/People.html
char HTTP_HEADER_FIELD_RETRY_AFTER                 [] = 'Retry-After'; // Retry-After: 120     |     Retry-After: Fri, 07 Nov 2014 23:59:59 GMT
char HTTP_HEADER_FIELD_SERVER                      [] = 'Server'; // Server: Apache/2.4.1 (Unix)
char HTTP_HEADER_FIELD_SERT_COOKIE                 [] = 'Set-Cookie'; // Set-Cookie: UserID=JohnDoe; Max-Age=3600; Version=1
char HTTP_HEADER_FIELD_STATUS                      [] = 'Status'; // Status: 200 OK
char HTTP_HEADER_FIELD_STRICT_TRANSPORT_SECURITY   [] = 'Strict-Transport-Security'; // Strict-Transport-Security: max-age=16070400; includeSubDomains
char HTTP_HEADER_FIELD_TRAILER                     [] = 'Trailer'; // Trailer: Max-Forwards
char HTTP_HEADER_FIELD_TRANSFER_ENCODING           [] = 'Transfer-Encoding'; // Transfer-Encoding: chunked
char HTTP_HEADER_FIELD_TSV                         [] = 'TSV'; // TSV: ?
//char HTTP_HEADER_FIELD_UPGRADE                   [] = 'Upgrade'; // Upgrade: HTTP/2.0, HTTPS/1.3, IRC/6.9, RTA/x11
char HTTP_HEADER_FIELD_VARY                        [] = 'Vary'; // Vary: *     |     Vary: Accept-Language
//char HTTP_HEADER_FIELD_VIA                       [] = 'Via'; // Via: 1.0 fred, 1.1 example.com (Apache/1.1)
//char HTTP_HEADER_FIELD_WARNING                   [] = 'Warning'; // Warning: 199 Miscellaneous warning
char HTTP_HEADER_FIELD_WWW_AUTHENTICATE            [] = 'WWW-Authenticate'; // WWW-Authenticate: Basic
char HTTP_HEADER_FIELD_X_FRAME_OPTIONS             [] = 'X-Frame-Options'; // X-Frame-Options: deny


char HTTP_METHOD_PUT[]     = 'PUT';
char HTTP_METHOD_GET[]     = 'GET';
char HTTP_METHOD_POST[]    = 'POST';
char HTTP_METHOD_HEAD[]    = 'HEAD';
char HTTP_METHOD_TRACE[]   = 'TRACE';
char HTTP_METHOD_DELETE[]  = 'DELETE';
char HTTP_METHOD_OPTIONS[] = 'OPTIONS';
char HTTP_METHOD_CONNECT[] = 'CONNECT';
char HTTP_METHOD_PATCH[]   = 'PATCH';

DEFINE_VARIABLE


Dictionary httpSafeCharacterDict;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpSetType_Request
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    nothing
//
// Description:
//    Sets the type of the HTTP message object to 'request'. Note that this is not a field in a HTTP string but rather
//    an indication for the program to know where the message came from (Client) and how it is formatted in string form
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpSetType_Request(HttpMessage message) {
	message.type = 'request';
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpSetType_Response
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    nothing
//
// Description:
//    Sets the type of the HTTP message object to 'response'. Note that this is not a field in a HTTP string but rather
//    an indication for the program to know where the message came from (Server) and how it is formatted in string form
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpSetType_Response(HttpMessage message) {
	message.type = 'response';
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpGetType
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    CHAR[8]   -   A character array containing the type of HTTP message ('request' | 'response').
//
// Description:
//    Returns a character array containing the type of HTTP message from the HTTP message object. Note that this is not
//    a field in a HTTP string but rather an indication for the program to know where the message came from. A return
//    value of 'request' will indicate that HTTP message is from a HTTP client while a return value of 'response' will
//    indicate that the HTTP message is from a HTTP Server.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION char[8] httpGetType(HttpMessage message) {
	return message.type;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpSetVersion
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//    float version         -   A float value containing a HTTP version
//
// Returns:
//    nothing
//
// Description:
//    Sets the HTTP version in the HTTP message object.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpSetVersion(HttpMessage message, float version) {
	message.version = version;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpGetVersion
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    float   -   A float containing the HTTP version.
//
// Description:
//    Returns a float containing the HTTP version from the HTTP message object
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION float httpGetVersion(HttpMessage message) {
	return message.version;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpSetStatuscode
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//    integer statusCode    -   An integer value containing a HTTP status code
//
// Returns:
//    nothing
//
// Description:
//    Sets the status code in the HTTP message object.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpSetStatuscode(HttpMessage message, integer statusCode) {
	message.statusCode = statusCode;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpGetStatusCode
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    integer   -   An integer containing the HTTP status code.
//
// Description:
//    Returns an integer containing the HTTP status code from the HTTP message object
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION integer httpGetStatusCode(HttpMessage message) {
	return message.statusCode;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpSetReasonPhrase
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//    char reasonPhrase[]   -   A character array (string) of undetermined length
//
// Returns:
//    nothing
//
// Description:
//    Sets the reason phrase in the HTTP message object.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpSetReasonPhrase(HttpMessage message, char reasonPhrase[]) {
	message.reasonPhrase = reasonPhrase;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpGetReasonPhrase
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    CHAR[100]   -   A character array containing the reason phrase.
//
// Description:
//    Returns a character array containing the reason phrase from the HTTP message object
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION char[100] httpGetReasonPhrase(HttpMessage message) {
	return message.reasonPhrase;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpSetMethod
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//    char method[]         -   A character array (string) of undetermined length
//
// Returns:
//    nothing
//
// Description:
//    Sets the method in the HTTP message object. Only valid HTTP methods are allowed (GET|HEAD|POST|PUT|DELETE|TRACE|
//    OPTIONS|CONNECT|PATCH)
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpSetMethod(HttpMessage message, char method[]) {
	switch(UPPER_STRING(method)) {
		case HTTP_METHOD_GET:
		case HTTP_METHOD_HEAD:
		case HTTP_METHOD_POST:
		case HTTP_METHOD_PUT:
		case HTTP_METHOD_DELETE:
		case HTTP_METHOD_TRACE:
		case HTTP_METHOD_OPTIONS:
		case HTTP_METHOD_CONNECT:
		case HTTP_METHOD_PATCH:
			message.method = UPPER_STRING(method);
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpSetMethod_Get
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    nothing
//
// Description:
//    Sets the method in the HTTP message object to GET.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpSetMethod_Get(HttpMessage message) {
	message.method = HTTP_METHOD_GET;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpSetMethod_Head
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    nothing
//
// Description:
//    Sets the method in the HTTP message object to HEAD.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpSetMethod_Head(HttpMessage message) {
	message.method = HTTP_METHOD_HEAD;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpSetMethod_Post
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    nothing
//
// Description:
//    Sets the method in the HTTP message object to POST.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpSetMethod_Post(HttpMessage message) {
	message.method = HTTP_METHOD_POST;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpSetMethod_Put
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    nothing
//
// Description:
//    Sets the method in the HTTP message object to PUT.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpSetMethod_Put(HttpMessage message) {
	message.method = HTTP_METHOD_PUT;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpSetMethod_Delete
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    nothing
//
// Description:
//    Sets the method in the HTTP message object to DELETE.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpSetMethod_Delete(HttpMessage message) {
	message.method = HTTP_METHOD_DELETE;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpSetMethod_Trace
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    nothing
//
// Description:
//    Sets the method in the HTTP message object to TRACE.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpSetMethod_Trace(HttpMessage message) {
	message.method = HTTP_METHOD_TRACE;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpSetMethod_Options
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    nothing
//
// Description:
//    Sets the method in the HTTP message object to OPTIONS.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpSetMethod_Options(HttpMessage message) {
	message.method = HTTP_METHOD_OPTIONS;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpSetMethod_Connect
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    nothing
//
// Description:
//    Sets the method in the HTTP message object to CONNECT.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpSetMethod_Connect(HttpMessage message) {
	message.method = HTTP_METHOD_CONNECT;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpSetMethod_Patch
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    nothing
//
// Description:
//    Sets the method in the HTTP message object to PATCH.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpSetMethod_Patch(HttpMessage message) {
	message.method = HTTP_METHOD_PATCH;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpGetMethod
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    CHAR[10]   -   A character array containing the HTTP method.
//
// Description:
//    Returns a character array containing the HTTP method from the HTTP message object
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION char[10] httpGetMethod(HttpMessage message) {
	return message.method;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpSetResourcePath
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//    char resourcePath[]   -   A character array (string) of undetermined length
//
// Returns:
//    nothing
//
// Description:
//    Sets the resource path in the HTTP message object.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpSetResourcePath(HttpMessage message, char resourcePath[]) {
	message.resourcePath = resourcePath;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpGetResourcePath
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    CHAR[200]   -   A character array containing the resource path.
//
// Description:
//    Returns a character array containing the resource path from the HTTP message object
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION char[200] httpGetResourcePath(HttpMessage message) {
	return message.resourcePath;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpSetHeader
//
// Parameters:
//    HttpMessage message      -   A HTTP message object
//    char headerField[]    -   A character array (string) of undetermined length
//    char value[]          -   A character array (string) of undetermined length
//
// Returns:
//    nothing
//
// Description:
//    Sets the value of the specified header field in the HTTP message object.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpSetHeader(HttpMessage message, char headerField[], char value[]) {
	dictionaryAdd(message.headers,headerField,value);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpGetHeader
//
// Parameters:
//    HttpMessage message      -   A HTTP message object
//    char headerFieldName[]   -   A character array (string) of undetermined length
//
// Returns:
//    CHAR[100]   -   A character array containing the value of the requested header field.
//
// Description:
//    Returns a character array containing the value of the requested header field from the HTTP message object
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION char[100] httpGetHeader(HttpMessage message, char headerFieldName[]) {
	return dictionaryGetValue(message.headers,headerFieldName);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpSetMessageBody
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//    char body[]           -   A character array (string) of undetermined length
//
// Returns:
//    nothing
//
// Description:
//    Sets the body of the HTTP message object passed to the message parameter with the string value passed to the
//    body parameter.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpSetMessageBody(HttpMessage message, char body[]) {
	message.body = body;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpGetMessageBody
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    CHAR[HTTP_MAX_SIZE_MESSAGE_BODY]   -   A character array containing the body of the HTTP message.
//
// Description:
//    Returns the body of the HTTP message object passed to the message parameter.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION char[HTTP_MAX_SIZE_MESSAGE_BODY] httpGetMessageBody(HttpMessage message) {
	return message.body;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: printHttp
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    nothing
//
// Description:
//    Prints a HTTP protocol formatted string to diagnostics based on the contents of a HTTP message object passed to
//    the message parameter. 
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function printHttp(HttpMessage message) {
	CHAR resourcePathSafelyTyped[600];
	stack_var integer i;

	// Initial Request Line
	if(message.type == 'request') {
		i = 1;
		resourcePathSafelyTyped = uriPercentEncodeString(message.resourcePath);
		send_string 0, "message.method,' ',resourcePathSafelyTyped,' HTTP/',format('%.1f',message.version),$0D,$0A";
	}
	else if(message.type = 'response') {
		send_string 0, "'HTTP/',ftoa(message.version),' ',itoa(message.statusCode),' ',message.reasonPhrase,$0D,$0A";
	}
	else {	// unhandled type
		return;// "'ERROR:Unhandled HTTP message type "',message.type,'"'";
	}
	
	// Header Lines
	i = 1;
	while(i <= length_array(message.headers.keyVals)) {
		send_string 0, "message.headers.keyVals[i].key,': ',message.headers.keyVals[i].val,$0D,$0A";
		i++;
	}
	// Blank Line
	send_string 0, "$0D,$0A";

	// Message Body
	send_string 0, "message.body";
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpToString
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    CHAR[100000]   -   A character array containing a HTTP protocol formatted string.
//
// Description:
//    Returns a character array containing a HTTP protocol formatted string bases on the contents of the HttpMessage
//    object passed to the message parameter.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION CHAR[100000] httpToString(HttpMessage message) {
	CHAR http[100000];
	CHAR resourcePathSafelyTyped[600];
	stack_var integer i;

	// Initial Request Line
	if(message.type == 'request') {
		i = 1;
		resourcePathSafelyTyped = uriPercentEncodeString(message.resourcePath);
		http = "message.method,' ',resourcePathSafelyTyped,' HTTP/',format('%.1f',message.version),$0D,$0A"
	}
	else if(message.type = 'response') {
		append_string(http,"'HTTP/',ftoa(message.version),' ',itoa(message.statusCode),' ',message.reasonPhrase,$0D,$0A");
	}
	else {	// unhandled type
		return "'ERROR:Unhandled HTTP message type "',message.type,'"'";
	}
	
	// Header Lines
	i = 1;
	while(i <= length_array(message.headers.keyVals)) {
		append_string(http,"message.headers.keyVals[i].key,': ',message.headers.keyVals[i].val,$0D,$0A");
		i++;
	}

	append_string(http,"$0D,$0A");

	// Message Body
	append_string(http,"message.body");

	return http;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpFromString
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//    char str[]            -   A character string of undetermined length
//
// Returns:
//    nothing
//
// Description:
//    Takes a HTTP message object and a character array assumed to contain HTTP protocol string and builds the values
//    of the HTTP message object as per the contents of the HTTP string.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpFromString(HttpMessage message, char str[]) {
	stack_var char initialLine[500];
	stack_var char headerLines[2048];

	if(str == '') {
		// string is empty - abort
		return;
	}

	if(!find_string(str,'HTTP/',1)) {
		// string does not contain the required 'HTTP/' to be a HTTP string - abort
		return;
	}

	// Initial Request/Response Line
	initialLine = remove_string(str,"$0D,$0A",1);

	if(find_string(initialLine,'HTTP/',1) == 1) {	// starts with 'HTTP/', must be a response
		httpSetType_Response(message);
		httpSetVersion(message,atof(remove_string(initialLine,' ',1)));
		httpSetStatuscode(message,atoi(remove_string(initialLine,' ',1)));
		delete_string(initialLine,"$0D,$0A");
		httpSetReasonPhrase(message,initialLine);
	}
	else {	// it's a request
		STACK_VAR char method[8];
		STACK_VAR char path[200];

		method = remove_string(initialLine,' ',1);
		trim_string(method,0,1);

		path = remove_string(initialLine,' ',1);
		trim_string(path,0,1);

		httpSetType_Request(message);
		httpSetMethod(message,method);
		httpSetResourcePath(message,path);

		remove_string(initialLine,'HTTP/',1);

		httpSetVersion(message,atof(initialLine));
	}

	if(find_string(str,"$0D,$0A",1) != 1)	// header lines exist
	{
		// Header Lines
		headerLines = remove_string(str,"$0D,$0A,$0D,$0A",1);

		while(find_string(headerLines,':',1)) {
			stack_var char headerFieldName[100];
			stack_var char headerFieldValue[100];

			headerFieldName = remove_string(headerLines,':',1);
			trim_string(headerFieldName,0,1);

			append_string(headerFieldValue,remove_string(headerLines,"$0D,$0A",1));

			delete_string(headerFieldValue,"$0D,$0A");

			// trim leading whitespace
			while((headerFieldValue[1] == ' ') || (headerFieldValue[1] == $09)) {
				trim_string(headerFieldValue,1,0);
			}
			// trim trailing whitespace
			while((headerFieldValue[length_string(headerFieldValue)] == ' ') || (headerFieldValue[length_string(headerFieldValue)] == $09)) {
				trim_string(headerFieldValue,0,1);
			}

			// there could be just one value or there could be multiple values (seperated by commas) and they may be spread 
			// over multiple lines (in which case the line will start with space or tab).
			// To add to the confusion some values may actually contain commas as part of their value
			while((find_string(headerLines,"SPACE",1) == 1) || (find_string(headerLines,"TABH",1) == 1)) {
				stack_var char newVal[100];

				newVal = remove_string(headerLines,"$0D,$0A",1);
				delete_string(newVal,"$0D,$0A");

				// trim leading whitespace
				while((newVal[1] == ' ') || (newVal[1] == $09)) {
					trim_string(newVal,1,0);
				}

				// trim trailing whitespace
				while((newVal[length_string(newVal)] == ' ') || (newVal[length_string(newVal)] == $09)) {
					trim_string(newVal,0,1);
				}

				append_string(headerFieldValue,newVal);
			}

			// now the string may contain just one value or perhaps multiple values seperated by commas

			// should we trim whitespace?
			// we would have to be careful if we do this. We can't just delete all spaces because the values themselves may 
			// contain spaces

			httpSetHeader(message,headerFieldName,headerFieldValue);
		}
	}
	else { // header lines do not exist
		// remove the blank line
		remove_string(str,"$0D,$0A",1);
	}

	// Message Body
	httpSetMessageBody(message,str);
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpClear
//
// Parameters:
//    HttpMessage message   -   A HTTP message object
//
// Returns:
//    nothing
//
// Description:
//    Clears the contents of an HTTP message object
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpClear(HttpMessage message) {
	message.body = '';
	dictionaryClear(message.headers);
	message.method = '';
	message.reasonPhrase = '';
	message.resourcePath = '';
	message.statusCode = 0;
	message.type = '';
	message.version = 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: function_name
//
// Parameters:
//    datatype identifier   - description
//
// Returns:
//    datatype   -   description
//
// Description:
//    description
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DEFINE_FUNCTION httpPopulateSafeCharacterDictionary() {
	stack_var char c;
	c = $00;
	while(c <= $FF) {
		if(uriIsReservedChar(c) || uriIsReservedChar(c))
			dictionaryAdd(httpSafeCharacterDict,"c","c");
		else
			dictionaryAdd(httpSafeCharacterDict,"c",uriPercentEncodeChar(c));
		c++;

		if(c == $00)	// we wrapped around
			break;
	}
}


DEFINE_START

httpPopulateSafeCharacterDictionary();






#END_IF
