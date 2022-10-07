program_name='http'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: http
// 
// Description:
//
//    - This include file provides structures and functions for working with HTTP/1.1 (Hypertext Transfer Protocol).
//
// Implementation:
//
//    - Any NetLinx program utilising the http include file must use either the INCLUDE or #INCLUDE keywords to 
//      include the http include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//      functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE
//      keyword is from the earlier Axcess programming language and is included within the NetLinx programming language 
//      for backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'HTTP Demo'
//
//          #include 'http'
//
// Usage:
//
//    - A HTTP request can be built be creating a HttpRequest object and updating its version, method, request URI, 
//      headers, and body.
//
//    E.g:
//
//        HttpRequest request;
//
//        request.method = HTTP_METHOD_GET;
//        request.requestUri = '/';
//        request.version = 1.1;
//        httpSetHeader(request.headers, HTTP_HEADER_FIELD_HOST, 'www.someHTTPserver.com');
//        httpSetHeader(request.headers, HTTP_HEADER_FIELD_CONTENT_TYPE, 'text/plain');
//        httpSetHeader(request.headers, HTTP_HEADER_FIELD_CONTENT_LENGTH, '9');
//        request.body = 'Some data';
//
//    - To send the HTTP request (after opening the socket to the webserver) the HttpRequest object needs to be 
//      converted to string format for transport.
//
//    E.g:
//
//        send_string httpServer, httpRequestToString(request);
//
//        This results in the following HTTP request being sent:
//
//           *------------------------*
//           |GET / HTTP/1.1          |
//           |Host: www.someHTTPserver.com    |
//           |Content-Type: text/plain|
//           |Content-Length: 9       |
//           |Some data               |
//           |                        |
//           *------------------------*
//
//    - To parse a HTTP response received from a HTTP server the incoming data needs to be read into a HttpResponse
//      object.
//
//    E.g:
//
//        data_event[httpServer] {
//
//            string: {
//
//                stack_var HttpResponse response;
//
//                httpParseResponse(response, data.text);
//
//                ...
//            }
//        }
//
//    - If a HTTP response is large enough it may need to be processed over multiple data events. For this reason it is
//      recommended to use a global buffer to store the incoming data from the HTTP server and then test the result of
//      calling httpParseResponse eaqch time a new chunk of data is received to confirm receipt of a complete HTTP 
//      request.
//
//    E.g:
//
//        define_device
//
//        httpServer = 0:2:0
//
//
//        define_variable
//
//        char httpResponseBuffer[2048]
//
//
//        define__start
//
//        create_buffer httpServer, httpResponseBuffer
//
//
//        define_event
//
//        data_event[httpServer] {
//
//            string: {
//
//                stack_var HttpResponse response;
//
//                if(httpParseResponse(response, httpResponseBuffer)) {
//
//                    clear_buffer httpResponseBuffer
//
//                    // process the HTTP request object
//                    ...
//                }
//            }
//        }
//
//    - The HttpResponse object can then be processed.
//
//        - response.status contains the HTTP status. The status code in the HTTP response can be checked against the 
//          defined HTTP status code constants.
//
//        E.g:
//
//            switch(response.status.code) {
//
//                case HTTP_STATUS_CODE_OK: {
//                    // continue processing the HTTP request object
//                    ...
//                }
//
//                case HTTP_STATUS_CODE_NOT_FOUND: {
//                    AMX_LOG(AMX_ERROR,"'HTTP Response indicates request URI was not found');
//                }
//
// 
//                case HTTP_STATUS_CODE_METHOD_NOT_ALLOWED: {
//                    AMX_LOG(AMX_ERROR,"'HTTP Response indicates request method was not allowed');
//                }
//
//                case HTTP_STATUS_CODE_UNAUTHORIZED: {
//                    AMX_LOG(AMX_ERROR,"'HTTP Response indicates request was unauthorized');
//                }
// 
//                case HTTP_STATUS_CODE_FORBIDDEN: {
//                    AMX_LOG(AMX_ERROR,"'HTTP Response indicates request was unforbidden');
//                }
//
//                default: {
//
//                    AMX_LOG(AMX_ERROR,"'Unhandled HTTP Response Status Code: ',itoa(response.status.code),', ',response.status.message");
//                }
//            }
//
//
//        - The headers of the HTTP response (stored in response.headers) should be examined. For example, you may need
//          to retrieve a cookie from the HTTP response so that it can be included with subsequent HTTP requests sent 
//          to the HTTP server.          
//
//        E.g:
//
//            if(httpHasHeader(response.headers, HTTP_HEADER_FIELD_SET_COOKIE)) {
//
//                cookie = httpGetHeader(response.headers, HTTP_HEADER_FIELD_SET_COOKIE);
//            }
//
//            ...
//            httpSetHeader(request.headers, HTTP_HEADER_FIELD_COOKIE, cookie);
//            ...
//
//       
//        - response.body contains the body of the HTTP response.
//
//    - A HTTP server may require authentication for access control to some resources. Typically the mechanism to
//      achieve this involves the HTTP server issuing a challenge to the HTTP client which includes information 
//      about the authentication mechanism required.
//
//      There are multiple ways that authentication may be implemented by a HTTP server and it is beyond the scope of 
//      this project to provide example for each one.
//
//      One method of issing a challenge is for the HTTP server to respond with a 401 (Unauthorized) status code if
//      the HTTP request from the client does not meet the authentication requirements. The response from the HTTP
//      server typically provides information about the challenge within the 'WWW-Authenticate' header. For the client
//      to authenticate with the HTTP server future requests sent to the server need to include the challenge response
//      within the 'Authorization' header.
//
//      E.g:
//
//          HTTP Client -> GET / HTTP/1.1                                      -> HTTP Server
//
//          HTTP Client <- HTTP/1.1 401 Unauthorized                           <- HTTP Server
//                         WWW-Authenticate: Basic realm=Access to the site"
//
//          HTTP Client -> GET / HTTP/1.1                                      -> HTTP Server
//                         Authorization: Basic YWRtaW46cGFzc3dvcmQ
//
//          HTTP Client <- HTTP/1.1 200 OK                                     <- HTTP Server
//                             or
//                         HTTP/1.1 401 Unauthorized
//                         WWW-Authenticate: Basic realm=Access to the site"
//
//      Two common types of authentication mechanism are Basic and Digest authentication. If the server issues a Basic
//      authentication challenge the client must include a base64 encoding of the username and password seperated by
//      a colon (:) in the 'Authorization header.
//
//      E.g:
//
//          HttpRequest request;
//          char username[] = 'admin';
//          char password[] = 'password';
//
//          request.method = HTTP_METHOD_GET;
//          request.requestUri = '/';
//          request.version = 1.1;
//          httpSetHeader(request.headers, HTTP_HEADER_FIELD_HOST, 'www.someHTTPserver.com');
//          httpSetHeader(request.headers, HTTP_HEADER_FIELD_AUTHORIZATION, httpBasicAuthentication(username, password));
//
//          send_string httpServer, httpRequestToString(request);
//
//          This results in the following HTTP request being sent:
//
//             *----------------------------------------*
//             |GET / HTTP/1.1                          |
//             |Host: www.someHTTPserver.com            |
//             |Authorization: Basic YWRtaW46cGFzc3dvcmQ|
//             |                                        |
//             *----------------------------------------*
//
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __HTTP__
#define __HTTP__


#include 'base64'
#include 'md5'
#include 'uri'


define_constant

HTTP_MAX_MESSAGE_LENGTH = 65535
HTTP_MAX_BODY_LENGTH    = 65535


define_type

struct HttpHeader {
    char name[100];
    char value[1024];
}

struct HttpRequest {
    float version;
    char method[10];
    char requestUri[200];
    HttpHeader headers[20];
    char body[HTTP_MAX_BODY_LENGTH];
}

struct HttpStatus {
    integer code;
    char message[100];
}

struct HttpResponse {
    float version;
    HttpStatus status;
    HttpHeader headers[20];
    char body[HTTP_MAX_BODY_LENGTH];
}


define_constant

char HTTP_VERSION_1_0[] = 'HTTP/1.0';
char HTTP_VERSION_1_1[] = 'HTTP/1.1';

// Informational Status Codes
integer HTTP_STATUS_CODE_CONTINUE            = 100; // Only a part of the request has been received by the server, but as long as it has not been rejected, the client should continue with the request.
integer HTTP_STATUS_CODE_SWITCHING_PROTOCOLS = 101; // The server switches protocol.
integer HTTP_STATUS_CODE_PROCESSING          = 102; // 
integer HTTP_STATUS_CODE_EARLY_HINTS         = 103; // 

// Successful Status Codes
integer HTTP_STATUS_CODE_OK                            = 200; // The request is OK.
integer HTTP_STATUS_CODE_CREATED                       = 201; // The request is complete, and a new resource is created.
integer HTTP_STATUS_CODE_ACCEPTED                      = 202; // The request is accepted for processing, but the processing is not complete.
integer HTTP_STATUS_CODE_NON_AUTHORITATIVE_INFORMATION = 203; // The information in the entity header is from a local or third-party copy, not from the original server.
integer HTTP_STATUS_CODE_NO_CONTENT                    = 204; // A status code and a header are given in the response, but there is no entity-body in the reply.
integer HTTP_STATUS_CODE_RESET_CONTENT                 = 205; // The browser should clear the form used for this transaction for additional input.
integer HTTP_STATUS_CODE_PARTIAL_CONTENT               = 206; // The server is returning partial data of the size requested. Used in response to a request specifying a Range header. The server must specify the range included in the response with the Content-Range header.
integer HTTP_STATUS_CODE_MULTI_STATUS                  = 207;
integer HTTP_STATUS_CODE_ALREADY_REPORTED              = 208;
integer HTTP_STATUS_CODE_IM_USED                       = 226;

// Redirection Status Codes
integer HTTP_STATUS_CODE_MULTIPLE_CHOICES   = 300; // A link list. The user can select a link and go to that location. Maximum five addresses.
integer HTTP_STATUS_CODE_MOVED_PERMANENTLY  = 301; // The requested page has moved to a new url.
integer HTTP_STATUS_CODE_FOUND              = 302; // The requested page has moved temporarily to a new url.
integer HTTP_STATUS_CODE_SEE_OTHER          = 303; // The requested page can be found under a different url.
integer HTTP_STATUS_CODE_NOT_MODIFIED       = 304; // This is the response code to an If-Modified-Since or If-None-Match header, where the URL has not been modified since the specified date.
integer HTTP_STATUS_CODE_USE_PROXY          = 305; // The requested URL must be accessed through the proxy mentioned in the Location header.
integer HTTP_STATUS_CODE_UNUSED             = 306; // This code was used in a previous version. It is no longer used, but the code is reserved.
integer HTTP_STATUS_CODE_TEMPORARY_REDIRECT = 307; // The requested page has moved temporarily to a new url.
integer HTTP_STATUS_CODE_PERMANENT_REDIRECT = 308; // 

// Client Error Status Codes
integer HTTP_STATUS_CODE_BAD_REQUEST                        = 400; // The server did not understand the request.
integer HTTP_STATUS_CODE_UNAUTHORIZED                       = 401; // The requested page needs a username and a password.
integer HTTP_STATUS_CODE_PAYMENT_REQUIRED                   = 402; // You can not use this code yet.
integer HTTP_STATUS_CODE_FORBIDDEN                          = 403; // Access is forbidden to the requested page.
integer HTTP_STATUS_CODE_NOT_FOUND                          = 404; // The server can not find the requested page.
integer HTTP_STATUS_CODE_METHOD_NOT_ALLOWED                 = 405; // The method specified in the request is not allowed.
integer HTTP_STATUS_CODE_NOT_ACCEPTABLE                     = 406; // The server can only generate a response that is not accepted by the client.
integer HTTP_STATUS_CODE_PROXY_AUTHENTICATION_REQUIRED      = 407; // You must authenticate with a proxy server before this request can be served.
integer HTTP_STATUS_CODE_REQUEST_TIMEOUT                    = 408; // The request took longer than the server was prepared to wait.
integer HTTP_STATUS_CODE_CONFLICT                           = 409; // The request could not be completed because of a conflict.
integer HTTP_STATUS_CODE_GONE                               = 410; // The requested page is no longer available.The "Content-Length" is not defined. The server will not accept the request without it.
integer HTTP_STATUS_CODE_LENGTH_REQUIRED                    = 411; // The "Content-Length" is not defined. The server will not accept the request without it.
integer HTTP_STATUS_CODE_PRECONDITION_FAILED                = 412; // The pre condition given in the request evaluated to false by the server.
integer HTTP_STATUS_CODE_REQUEST_ENTITY_TOO_LARGE           = 413; // The server will not accept the request, because the request entity is too large.
integer HTTP_STATUS_CODE_REQUEST_URL_TOO_LONG               = 414; // The server will not accept the request, because the url is too long. Occurs when you convert a "post" request to a "get" request with a long query information.
integer HTTP_STATUS_CODE_UNSUPPORTED_MEDIA_TYPE             = 415; // The server will not accept the request, because the mediatype is not supported.
integer HTTP_STATUS_CODE_REQUEST_RANGE_NOT_SATISFIED        = 416; // The requested byte range is not available and is out of bounds.
integer HTTP_STATUS_CODE_EXPECTATION_FAILED                 = 417; // The expectation given in an Expect request-header field could not be met by this server.
integer HTTP_STATUS_CODE_IM_A_TEAPOT                        = 418;
integer HTTP_STATUS_CODE_MISDIRECTED_REQUEST                = 421;
integer HTTP_STATUS_CODE_UNPROCESSABLE_ENTITY               = 422;
integer HTTP_STATUS_CODE_LOCKED                             = 423;
integer HTTP_STATUS_CODE_FAILED_DEPENDENCIES                = 424;
integer HTTP_STATUS_CODE_UPGRADE_REQUIRED                   = 426;
integer HTTP_STATUS_CODE_PRECONDITION_REQUIRED              = 428;
integer HTTP_STATUS_CODE_TOO_MANY_REQUESTS                  = 429;
integer HTTP_STATUS_CODE_REQUEST_HEADER_FIELDS_TOO_LARGE    = 431;
integer HTTP_STATUS_CODE_CONNECTION_CLOSED_WITHOUT_RESPONSE = 444;
integer HTTP_STATUS_CODE_UNAVAILABLE_FOR_LEGAL_REASONS      = 451;
integer HTTP_STATUS_CODE_CLIENT_CLOSED_REQUEST              = 499;

// Server Error
integer HTTP_STATUS_CODE_INTERNAL_SERVER_ERROR           = 500; // The request was not completed. The server met an unexpected condition.
integer HTTP_STATUS_CODE_NOT_IMPLEMENTED                 = 501; // The request was not completed. The server did not support the functionality required.
integer HTTP_STATUS_CODE_BAD_GATEWAY                     = 502; // The request was not completed. The server received an invalid response from the upstream server.
integer HTTP_STATUS_CODE_SERVICE_UNAVAILABLE             = 503; // The request was not completed. The server is temporarily overloading or down.
integer HTTP_STATUS_CODE_GATEWAY_TIMEOUT                 = 504; // The gateway has timed out.
integer HTTP_STATUS_CODE_HTTP_VERSION_NOT_SUPPORTED      = 505; // The server does not support the "http protocol" version.
integer HTTP_STATUS_CODE_VARIANT_ALSO_NEGOTIATES         = 506;
integer HTTP_STATUS_CODE_INSUFFICIENT_STORAGE            = 507;
integer HTTP_STATUS_CODE_LOOP_DETECTED                   = 508;
integer HTTP_STATUS_CODE_NOT_EXTENDED                    = 510;
integer HTTP_STATUS_CODE_NETWORK_AUTHENTICATION_REQUIRED = 511;
integer HTTP_STATUS_CODE_NETWORK_CONNECT_TIMEOUT_ERROR   = 599;

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
char HTTP_HEADER_FIELD_USER_AGENT          [] = 'User-Agent';          // User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:12.0) Gecko/20100101 Firefox/21.0
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
char HTTP_HEADER_FIELD_SET_COOKIE                  [] = 'Set-Cookie'; // Set-Cookie: UserID=JohnDoe; Max-Age=3600; Version=1
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

// HTTP Methods
char HTTP_METHOD_PUT[]     = 'PUT';
char HTTP_METHOD_GET[]     = 'GET';
char HTTP_METHOD_POST[]    = 'POST';
char HTTP_METHOD_HEAD[]    = 'HEAD';
char HTTP_METHOD_TRACE[]   = 'TRACE';
char HTTP_METHOD_DELETE[]  = 'DELETE';
char HTTP_METHOD_OPTIONS[] = 'OPTIONS';
char HTTP_METHOD_CONNECT[] = 'CONNECT';
char HTTP_METHOD_PATCH[]   = 'PATCH';


/*
HTTP String Specific Functions
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpParseResponse
//
// Parameters:
//    HttpResponse response   -   HTTP response object which will store the parsed HTTP response
//    char buffer[]           -   buffer containing the HTTP response to parse
//
// Returns:
//    integer   - true or false value indicating whether HTTP response was parsed successfully
//
// Description:
//    Parses a HTTP response from a character buffer. Returns a true or false value indicating success or failure.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function integer httpParseResponse(HttpResponse response, char buffer[]) {
	char workingBuffer[HTTP_MAX_MESSAGE_LENGTH];
	char httpStatusLine[1024];
	char httpHeaderLines[5000];
	HttpResponse tempResponse;
	
	workingBuffer = buffer;
	
	if(!find_string(workingBuffer,'HTTP/',1)) {
		return false;
	}
	
	remove_string(workingBuffer,'HTTP/',1);
	
	if(!find_string(workingBuffer,"$0d,$0a",1)) {
		return false;
	}
	
	httpStatusLine = remove_string(workingBuffer,"$0d,$0a",1);
	httpStatusLine = left_string(httpStatusLine,length_string(httpStatusLine)-2);
	
	tempResponse.version = atof(httpStatusLine);
	
	remove_string(httpStatusLine,' ',1);
	tempResponse.status.code = atoi(httpStatusLine);
	
	remove_string(httpStatusLine,' ',1);
	tempResponse.status.message = httpStatusLine;
	
	if(!find_string(workingBuffer,"$0d,$0a,$0d,$0a",1)) {
		return false;
	}
	
	httpHeaderLines = remove_string(workingBuffer,"$0d,$0a,$0d,$0a",1);
	
	while(httpHeaderLines != "$0d,$0a") {
		char headerLine[2000];
		char headerName[50];
		char headerValue[2000];
		
		headerLine = remove_string(httpHeaderLines,"$0d,$0a",1);
		headerLine = left_string(headerLine,length_string(headerLine)-2);
		headerName = remove_string(headerLine,"':'",1);
		headerName = left_string(headerName,length_string(headerName)-1);
		headerValue = right_string(headerLine,length_string(headerLine)-1);
		httpSetHeader(tempResponse.headers,headerName,headerValue);
	}
	
	if(httpHasHeader(tempResponse.headers,'Transfer-Encoding')) {
		char values[20][1024];
		integer i;
		integer isChunked;
		
		httpGetHeaderValues(tempResponse.headers,'Transfer-Encoding',values);
		
		for(i=1; i<=length_array(values); i++) {
		
			if(find_string(values[i],'chunked',1)) {
				isChunked = true;
				
				if(!find_string(workingBuffer,"$0D,$0A,'0',$0D,$0A,$0D,$0A",1)) {
					return false;
				}
				else {
					tempResponse.body = remove_string(workingBuffer,"$0D,$0A,'0',$0D,$0A,$0D,$0A",1);
					httpCopyResponse(tempResponse,response);
					buffer = right_string(buffer,length_array(workingBuffer));
					return true;
				}
			}
		}
		
		if(!isChunked) {
			return false;
		}
	}
	else if(httpHasHeader(tempResponse.headers,'Content-Length')) {
		long contentLength;
		long bytesRemainingInBuffer;
		char values[20][1024];
		integer i;
		
		httpGetHeaderValues(tempResponse.headers,'Content-Length',values);
		contentLength = atoi(values[1]);
		
		if(length_array(workingBuffer)<contentLength) {
			AMX_LOG(AMX_ERROR,"'http-alt::httpParseResponse...returning(false) - buffer does not contain enough data'");
			return false;
		}
		
		tempResponse.body = get_buffer_string(workingBuffer,contentLength);
		httpCopyResponse(tempResponse,response);
		buffer = right_string(buffer,length_array(workingBuffer));
		return true;
	}
	else {
		httpCopyResponse(tempResponse,response);
		buffer = right_string(buffer,length_array(workingBuffer));
		return true;
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpParseRequest
//
// Parameters:
//    HttpRequest request   -   HTTP request object which will store the parsed HTTP request
//    char buffer[]         -   buffer containing the HTTP request to parse
//
// Returns:
//    integer   - true or false value indicating whether HTTP request was parsed successfully
//
// Description:
//    Parses a HTTP request from a character buffer. Returns a true or false value indicating success or failure.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function integer httpParseRequest(HttpRequest request, char buffer[]) {
	#warn '@todo: implement httpParseRequest method'
	return false;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpRequestToString
//
// Parameters:
//    HttpRequest request   -   HTTP request object
//
// Returns:
//    char[]   - HTTP request in string format
//
// Description:
//    Returns a HTTP request string from the data contained in the HttpRequest object parameter
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[HTTP_MAX_MESSAGE_LENGTH] httpRequestToString(HttpRequest request) {
    char http[1024];
    integer i;
    
    http = "request.method,' ',uriPercentEncodeString(request.requestUri),' HTTP/',format('%.1f',request.version),$0d,$0a"
    
    for(i=1; i<=length_array(request.headers); i++) {
		http = "http,request.headers[i].name,': ',request.headers[i].value,$0d,$0a";
    }
    
    http = "http,$0d,$0a";
    
    http = "http,request.body"
    
    return http;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpRequestToDebug
//
// Parameters:
//    HttpRequest request   -   HTTP request object
//
// Returns:
//    nothing
//
// Description:
//    Prints HTTP request to debug
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpRequestToDebug(HttpRequest request) {
    integer i;
	
	AMX_LOG(AMX_DEBUG,'----- BEGIN HTTP REQUEST -----');
    
    AMX_LOG(AMX_DEBUG,"request.method,' ',uriPercentEncodeString(request.requestUri),' HTTP/',format('%.1f',request.version)");
    
    for(i=1; i<=length_array(request.headers); i++) {
		AMX_LOG(AMX_DEBUG,"request.headers[i].name,': ',request.headers[i].value");
    }
    
    AMX_LOG(AMX_DEBUG,'');
    
	if(length_string(request.body)) {
		AMX_LOG(AMX_DEBUG,"request.body");
	}
    
	AMX_LOG(AMX_DEBUG,'----- END HTTP REQUEST -----');
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpResponseToString
//
// Parameters:
//    HttpResponse response   -   HTTP response object
//
// Returns:
//    char[]   - HTTP response in string format
//
// Description:
//    Returns a HTTP response string from the data contained in the HttpResponse object parameter
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[HTTP_MAX_MESSAGE_LENGTH] httpResponseToString(HttpResponse response) {
    char http[1024];
    integer i;
    
    http = "'HTTP/',format('%.1f',response.version),' ',itoa(response.status.code),' ',response.status.message,$0d,$0a"
    
    for(i=1; i<=length_array(response.headers); i++) {
		http = "http,response.headers[i].name,': ',response.headers[i].value,$0d,$0a";
    }
    
    http = "http,$0d,$0a";
    
    http = "http,response.body"
    
    return http;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpResponseToDebug
//
// Parameters:
//    HttpResponse response   -   HTTP response object
//
// Returns:
//    nothing
//
// Description:
//    Prints HTTP response to debug
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpResponseToDebug(HttpResponse response) {
    integer i;
	
	AMX_LOG(AMX_DEBUG,'----- BEGIN HTTP RESPONSE -----');
    
    AMX_LOG(AMX_DEBUG,"'HTTP/',format('%.1f',response.version),' ',itoa(response.status.code),' ',response.status.message");
    
    for(i=1; i<=length_array(response.headers); i++) {
		AMX_LOG(AMX_DEBUG,"response.headers[i].name,': ',response.headers[i].value");
    }
    
    AMX_LOG(AMX_DEBUG,'');
    
	if(length_string(response.body)) {
		AMX_LOG(AMX_DEBUG,"response.body");
	}
	
	AMX_LOG(AMX_DEBUG,'----- END HTTP RESPONSE -----');
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpSetHeader
//
// Parameters:
//    HttpHeader[] headers   -   array of HTTP header ojects
//    char[] name            -   name of HTTP header
//    char[] value           -   value of HTTP header
//
// Returns:
//    nothing
//
// Description:
//    Adds HTTP header to array of HTTP headers. If HTTP header with matching name already exists in array the value
//    of the existing HTTP header is overwritten.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpSetHeader(HttpHeader headers[], char name[], char value[]) {
	integer i;
	
	for(i=1; i<=length_array(headers); i++) {
		if(lower_string(headers[i].name) == lower_string(name)) {
			headers[i].value = value;
			return;
		}
	}
	
	if(length_array(headers) < max_length_array(headers)) {
		set_length_array(headers,length_array(headers)+1);
		headers[length_array(headers)].name = name;
		headers[length_array(headers)].value = value;
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpGetHeader
//
// Parameters:
//    HttpHeader[] headers   -   HTTP headers array
//    char[] name            -   name of HTTP header
//    char[][] value         -   2-dimensional character array to store HTTP header values
//
// Returns:
//    char[]   -   value of header
//
// Description:
//    Searches for and returns the value of the first instances of a specified header in a HTTP headers array
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[1024] httpGetHeader(HttpHeader headers[], char name[]) {
	integer i;
	
	for(i=1; i<=length_array(headers); i++) {
		if(lower_string(headers[i].name) == lower_string(name)) {
			return headers[i].value;
		}
	}
	
	return "";
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpGetHeaderValues
//
// Parameters:
//    HttpHeader[] headers   -   HTTP headers array
//    char[] name            -   name of HTTP header
//    char[][] value         -   2-dimensional character array to store HTTP header values
//
// Returns:
//    nothing
//
// Description:
//    Searches for any instances of a specified header in a HTTP headers array object and populates the provided values
//    array
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpGetHeaderValues(HttpHeader headers[], char name[], char values[][]) {
	integer i;
	
	for(i=1; i<=length_array(headers); i++) {
		if(lower_string(headers[i].name) == lower_string(name)) {
			if(length_array(values) == max_length_array(values)) {
				return;
			}
			set_length_array(values,length_array(values)+1);
			values[length_array(values)] = headers[i].value;
		}
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpRemoveHeader
//
// Parameters:
//    HttpHeader[] headers       -   HTTP headers array
//    char[] name                -   name of HTTP header
//    integer removeAllMatches   -   boolean value indicating whether all instances of matching HTTP header should be 
//                                   removed
//
// Returns:
//    nothing
//
// Description:
//    Removes either the first instance of a specified HTTP header from a HTTP headers array object or all instances of
//    the specified header, dependent on true / false indicator supplied
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpRemoveHeader(HttpHeader headers[], char name[], integer removeAllMatches) {
	integer i;
	
	for(i=1; i<=length_array(headers); i++) {
		if(lower_string(headers[i].name) == lower_string(name)) {
			if(i==length_array(headers)) {
				headers[i].name = '';
				headers[i].value = '';
				set_length_array(headers,i-1);
				return;
			}
			else {
				integer j;
				for(j=i; j<length_array(headers);j++) {
					headers[j].name = headers[j+1].name
					headers[j].value = headers[j+1].value
				}
				set_length_array(headers,j-1);
			}
			
			if(!removeAllMatches) {
				return;
			} else {
				i--;
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpHasHeader
//
// Parameters:
//    HttpHeader[] headers   -   array of HTTP headers
//    char[] name            -   name of HTTP header
//
// Returns:
//    integer   -   boolean (true/false) value indicating whether specified HTTP header was found
//
// Description:
//    Searches HTTP header array for the existence of the specified HTTP header and returns a true/false value 
//    depending on the result 
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function integer httpHasHeader(HttpHeader headers[], char name[]) {
	integer i;
	
	for(i=1; i<=length_array(headers); i++) {
		if(lower_string(headers[i].name) == lower_string(name)) {
			return true;
		}
	}
	
	return false;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpGetHeaderNames
//
// Parameters:
//    HttpHeader[] headers   -   array of HTTP headers
//
// Returns:
//    char[20][100]   - 2-dimensional character array containing list of HTTP header names
//
// Description:
//    Returns a list containing the names of all HTTP headers contained in the HTTP header array
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[20][100] httpGetHeaderNames(HttpHeader headers[]) {
	#warn '@todo: implement httpGetHeaderNames method'
}

/*
HTTP Authentication Header Functions
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpBasicAuthentication
//
// Parameters:
//    char[] username   -   user name
//    char[] password   -   password
//
// Returns:
//    char[]   -   HTTP authentication header value
//
// Description:
//    Return the value for a HTTP Authentication header using basic authentication
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[1024] httpBasicAuthentication(char username[], char password[]) {
    stack_var char auth[1024];
    
    auth = "'Basic ',base64Encode("username,':',password")"
    
    return auth;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpDigestAuthentication
//
// Parameters:
//    char[] method       -   digest method
//    char[] requestUrl   -   request URI
//    char[] realm        -   
//    char[] username     -   user name
//    char[] password     -   password
//    char[] nonce        -   
//    char[] cnonce       -   
//    char[] nc           -   
//    char[] qop          -   
//    char[] algorithm    -   
//    char[] opaque       -   
//    char[] entityBody   -  
//
// Returns:
//    char[]   -   HTTP authentication header value
//
// Description:
//    Return the value for a HTTP Authentication header using digest authentication
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[1024] httpDigestAuthentication(char method[], char requestUri[], char realm[],
                                                    char username[], char password[],
                                                    char nonce[], char cnonce[30], char nc[8],
                                                    char qop[], char algorithm[],
                                                    char opaque[], char entityBody[]) {
    stack_var char HA1_hex[16], HA2_hex[16], response_hex[16];
    stack_var char HA1_str[32], HA2_str[32], response_str[32];
    stack_var char auth[1024];
    
    if(cnonce == '') {
		cnonce = "lower_string(hex(ltba(random_number($FFFFFFFF)))),lower_string(hex(ltba(random_number($FFFFFFFF))))";
		nc = '00000001';
    }
    else {
		if(itoa(nc) == 0) {
			nc = '00000001';
		}
		else {
			stack_var long nc_val;
			
			nc_val = hextoi(nc);
			nc_val++;
			nc = itohex(nc_val);
			
			while(length_array(nc)<8) {
			nc = "'0',nc";
			}
		}
    }
    
    if((algorithm == '') || (upper_string(algorithm) == 'MD5')) {
		HA1_hex = md5("username,':',realm,':',password");
		HA1_str = lower_string(hex(HA1_hex));
    }
    else if(upper_string(algorithm) == 'MD5-SESS') {
		HA1_hex = md5("md5("username,':',realm,':',password"),':',nonce,':',cnonce");
		HA1_str = lower_string(hex(HA1_hex));
    }
    
    if(qop == '') {
		HA2_hex = md5("method,':',requestUri");
		HA2_str = lower_string(hex(HA2_hex));
		response_hex = md5("HA1_str,':',nonce,':',HA2_str");
		response_str = lower_string(hex(response_hex));
    }
    else if(qop == 'auth' || find_string(lower_string(qop),'auth,',1)) {
		HA2_hex = md5("method,':',requestUri");
		HA2_str = lower_string(hex(HA2_hex));
		response_hex = md5("HA1_str,':',nonce,':',nc,':',cnonce,':','auth',':',HA2_str");
		response_str = lower_string(hex(response_hex));
    }
    else if(find_string(lower_string(qop),'auth-int',1)) {
		HA2_hex = md5("method,':',requestUri,':',lower_string(hex(md5(entityBody)))");
		HA2_str = lower_string(hex(HA2_hex));
		response_hex = md5("HA1_str,':',nonce,':',nc,':',cnonce,':','auth-int',':',HA2_str");
		response_str = lower_string(hex(response_hex));
    }
    
    auth = "'Digest username="',username,'", realm="',realm,'", nonce="',nonce,'", uri="',requestUri,'"'";
    
    if(upper_string(algorithm) == 'MD5') {
		auth =  "auth,', algorithm=MD5'"
    }
    else if(upper_string(algorithm) == 'MD5-SESS') {
		auth =  "auth,', algorithm=MD5-sess'"
    }
    
    auth =  "auth,', response="',response_str,'"'"
    
    if(opaque != '') {
		auth =  "auth,', opaque="',opaque,'"'"
    }
    
    if(qop == 'auth' || find_string(lower_string(qop),'auth,',1)) {
		auth =  "auth,', qop=auth'"
    }
    else if(find_string(lower_string(qop),'auth-int',1)) {
		auth =  "auth,', qop=auth-int'"
    }
    
    if(qop != '') {
		auth =  "auth,', nc=',nc"
		auth =  "auth,', cnonce="',cnonce,'"'"
    }
    
    return auth;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpCopyRequest
//
// Parameters:
//    HttpRequest copyFrom   -   HTTP request object
//    HttpRequest copyTo     -   HTTP request object
//
// Returns:
//    nothing
//
// Description:
//    Makes a direct copy of a HTTP request object
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpCopyRequest(HttpRequest copyFrom, HttpRequest copyTo) {
	integer i;
	
	copyTo.method = copyFrom.method;
	copyTo.requestUri = copyFrom.requestUri;
	copyTo.version = copyFrom.version;
	
	for(i=1; i<=length_array(copyFrom.headers); i++) {
		copyTo.headers[i].name = copyFrom.headers[i].name;
		copyTo.headers[i].value = copyFrom.headers[i].value;
	}
	set_length_array(copyTo.headers, length_array(copyFrom.headers));
	
	copyTo.body   = copyFrom.body;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpCopyResponse
//
// Parameters:
//    HttpResponse copyFrom   -   HTTP response object
//    HttpResponse copyTo     -   HTTP response object
//
// Returns:
//    nothing
//
// Description:
//    Makes a direct copy of a HTTP response object
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpCopyResponse(HttpResponse copyFrom, HttpResponse copyTo) {
	integer i;
	
	copyTo.version = copyFrom.version;
	copyTo.status.code = copyFrom.status.code;
	copyTo.status.message = copyFrom.status.message;
	
	for(i=1; i<=length_array(copyFrom.headers); i++) {
		copyTo.headers[i].name = copyFrom.headers[i].name;
		copyTo.headers[i].value = copyFrom.headers[i].value;
	}
	set_length_array(copyTo.headers, length_array(copyFrom.headers));
	
	copyTo.body   = copyFrom.body;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpInitRequest
//
// Parameters:
//    HttpRequest request   -   HTTP request object
//
// Returns:
//    nothing
//
// Description:
//    Initializes a HTTP request and clears all stored values
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpInitRequest(HttpRequest request) {
	integer i;
	
	request.method = '';
	request.requestUri = '';
	request.version = 0;
	
	for(i=1; i<=length_array(request.headers); i++) {
		request.headers[i].name = '';
		request.headers[i].value = '';
	}
	set_length_array(request.headers,0);
	
	request.body = '';
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpInitResponse
//
// Parameters:
//    HttpResponse response   -   HTTP response object
//
// Returns:
//    nothing
//
// Description:
//    Initializes a HTTP response and clears all stored values
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpInitResponse(HttpResponse response) {
	integer i;
	
	response.version = 0;
	response.status.code = 0;
	response.status.message = '';
	
	for(i=1; i<=length_array(response.headers); i++) {
		response.headers[i].name = '';
		response.headers[i].value = '';
	}
	set_length_array(response.headers,0);
	
	response.body = '';
}


#end_if
