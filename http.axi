program_name='http'


#if_not_defined __HTTP__
#define __HTTP__


#include 'base64.axi'
#include 'md5.axi'
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
    char uri[200];
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
	
	httpResponseSetVersion(tempResponse, atof(httpStatusLine));
	
	remove_string(httpStatusLine,' ',1);
	httpResponseSetStatusCode(tempResponse, atoi(httpStatusLine));
	
	remove_string(httpStatusLine,' ',1);
	httpResponseSetStatusMessage(tempResponse, httpStatusLine);
	
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
		httpResponseSetHeader(tempResponse,headerName,headerValue);
	}
	
	if(httpResponseHasHeader(tempResponse,'Transfer-Encoding')) {
		char values[20][1024];
		integer i;
		integer isChunked;
		
		httpResponseGetHeaderValues(tempResponse,'Transfer-Encoding',values);
		
		for(i=1; i<=length_array(values); i++) {
		
			if(find_string(values[i],'chunked',1)) {
				isChunked = true;
				
				if(!find_string(workingBuffer,"$0D,$0A,'0',$0D,$0A,$0D,$0A",1)) {
					return false;
				}
				else {
					httpResponseSetBody(tempResponse,remove_string(workingBuffer,"$0D,$0A,'0',$0D,$0A,$0D,$0A",1));
					httpResponseCopy(tempResponse,response);
					buffer = right_string(buffer,length_array(workingBuffer));
					return true;
				}
			}
		}
		
		if(!isChunked) {
			return false;
		}
	}
	else if(httpResponseHasHeader(tempResponse,'Content-Length')) {
		long contentLength;
		long bytesRemainingInBuffer;
		char values[20][1024];
		integer i;
		
		httpResponseGetHeaderValues(tempResponse,'Content-Length',values);
		contentLength = atoi(values[1]);
		
		if(length_array(workingBuffer)<contentLength) {
			AMX_LOG(AMX_ERROR,"'http-alt::httpParseResponse...returning(false) - buffer does not contain enough data'");
			return false;
		}
		
		httpResponseSetBody(tempResponse,get_buffer_string(workingBuffer,contentLength));
		httpResponseCopy(tempResponse,response);
		buffer = right_string(buffer,length_array(workingBuffer));
		return true;
	}
	else {
		httpResponseCopy(tempResponse,response);
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
    
    http = "request.method,' ',uriPercentEncodeString(request.uri),' HTTP/',format('%.1f',request.version),$0d,$0a"
    
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
    
    AMX_LOG(AMX_DEBUG,"request.method,' ',uriPercentEncodeString(request.uri),' HTTP/',format('%.1f',request.version)");
    
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

/*
HTTP Header Specific Functions
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpRequestSetHeader
//
// Parameters:
//    HttpRequest request   -   HTTP request object
//    char[] name           -   name of HTTP header
//    char[] value          -   value of HTTP header
//
// Returns:
//    nothing
//
// Description:
//    Assigns a header to a HTTP request object
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpRequestSetHeader(HttpRequest request, char name[], char value[]) {
	httpSetHeader(request.headers, name, value);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpResponseSetHeader
//
// Parameters:
//    HttpResponse response   -   HTTP response object
//    char[] name             -   name of HTTP header
//    char[] value            -   value of HTTP header
//
// Returns:
//    nothing
//
// Description:
//    Assigns a header to a HTTP response object
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpResponseSetHeader(HttpResponse response, char name[], char value[]) {
	httpSetHeader(response.headers, name, value);
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
// Function: httpRequestGetHeaderValues
//
// Parameters:
//    HttpRequest request   -   HTTP request object
//    char[] name           -   name of header
//    char[][] value        -   2-dimensional character array to store HTTP header values
//
// Returns:
//    nothing
//
// Description:
//    Searches for any instances of a specified header in a HTTP request object and populates the provided values array
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpRequestGetHeaderValues(HttpRequest request, char name[], char values[][]) {
	httpGetHeaderValues(request.headers,name,values);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpResponseGetHeaderValues
//
// Parameters:
//    HttpResponse response   -   HTTP response object
//    char[] name             -   name of HTTP header
//    char[][] value          -   2-dimensional character array to store HTTP header values
//
// Returns:
//    nothing
//
// Description:
//    Searches for any instances of a specified header in a HTTP response object and populates the provided values array
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpResponseGetHeaderValues(HttpResponse response, char name[], char values[][]) {
	httpGetHeaderValues(response.headers,name,values);
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
// Function: httpRequestRemoveHeader
//
// Parameters:
//    HttpRequest request        -   HTTP request object
//    char[] name                -   name of HTTP header
//    integer removeAllMatches   -   boolean value indicating whether all instances of matching HTTP header should be 
//                                   removed
//
// Returns:
//    nothing
//
// Description:
//    Removes either the first instance of a specified HTTP header from a HTTP request object or all instances of the
//    specified header, dependent on true / false indicator supplied
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpRequestRemoveHeader(HttpRequest request, char name[], integer removeAllMatches) {
	httpRemoveHeader(request.headers, name, removeAllMatches);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpResponseRemoveHeader
//
// Parameters:
//    HttpResponse response      -   HTTP response object
//    char[] name                -   name of HTTP header
//    integer removeAllMatches   -   boolean value indicating whether all instances of matching HTTP header should be 
//                                   removed
//
// Returns:
//    nothing
//
// Description:
//    Removes either the first instance of a specified HTTP header from a HTTP response object or all instances of the
//    specified header, dependent on true / false indicator supplied
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpResponseRemoveHeader(HttpResponse response, char name[], integer removeAllMatches) {
	httpRemoveHeader(response.headers, name, removeAllMatches);
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
// Function: httpRequestHasHeader
//
// Parameters:
//    HttpRequest request   -   HTTP request object
//    char[] name           -   name of HTTP header
//
// Returns:
//    integer   -   boolean (true/false) value indicating whether specified HTTP header was found
//
// Description:
//    Searches HTTP request object for the existence of the specified HTTP header and returns a true/false value 
//    depending on the result 
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function integer httpRequestHasHeader(HttpRequest request, char name[]) {
	return httpHasHeader(request.headers, name);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpResponseHasHeader
//
// Parameters:
//    HttpResponse response   -   HTTP response object
//    char[] name             -   name of HTTP header
//
// Returns:
//    integer   -   boolean (true/false) value indicating whether specified HTTP header was found
//
// Description:
//    Searches HTTP response object for the existence of the specified HTTP header and returns a true/false value 
//    depending on the result 
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function integer httpResponseHasHeader(HttpResponse response, char name[]) {
	return httpHasHeader(response.headers, name);
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
// Function: httpRequestGetHeaderNames
//
// Parameters:
//    HttpRequest request   -   HTTP request object
//
// Returns:
//    char[20][100]   - 2-dimensional character array containing list of HTTP header names
//
// Description:
//    Returns a list containing the names of all HTTP headers contained in the HTTP request object
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[20][100] httpRequestGetHeaderNames(HttpRequest request) {
	#warn '@todo: implement httpRequestGetHeaderNames method'
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpResponseGetHeaderNames
//
// Parameters:
//    HttpResponse response   -   HTTP response object
//
// Returns:
//    char[20][100]   - 2-dimensional character array containing list of HTTP header names
//
// Description:
//    Returns a list containing the names of all HTTP headers contained in the HTTP response object
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[20][100] httpResponseGetHeaderNames(HttpResponse response) {
	#warn '@todo: implement httpResponseGetHeaderNames method'
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
HTTP Response Status Specific Functions
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpResponseGetStatusCode
//
// Parameters:
//    HttpResponse response   -   HTTP response object
//
// Returns:
//    integer   -   status code
//
// Description:
//    Returns the status code of the HTTP response
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function integer httpResponseGetStatusCode(HttpResponse response) {
    return response.status.code;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpResponseGetStatusMessage
//
// Parameters:
//    HttpResponse response   -   HTTP response object
//
// Returns:
//    char[100]   -   status message
//
// Description:
//    Returns the status message of the HTTP response
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[100] httpResponseGetStatusMessage(HttpResponse response) {
    return response.status.message;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpResponseSetStatusCode
//
// Parameters:
//    HttpResponse response   -   HTTP response object
//    integer code            -   status code
//
// Returns:
//    nothing
//
// Description:
//    Assigns a status code to the HTTP response
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpResponseSetStatusCode(HttpResponse response, integer code) {
    response.status.code = code;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpResponseSetStatusMessage
//
// Parameters:
//    HttpResponse response   -   HTTP response object
//    char[] message          -   status message
//
// Returns:
//    nothing
//
// Description:
//    Assigns a status message to the HTTP response
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpResponseSetStatusMessage(HttpResponse response, char message[]) {
    response.status.message = message;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpResponseSetStatus
//
// Parameters:
//    HttpResponse response   -   HTTP response object
//    integer code            -   status code
//    char[] message          -   status message
//
// Returns:
//    nothing
//
// Description:
//    Assigns a status (code and message) to the HTTP response
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpResponseSetStatus(HttpResponse response, integer code, char message[]) {
    response.status.code = code;
    response.status.message = message;
}

/*
HTTP Version Specific Functions
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpResponseSetVersion
//
// Parameters:
//    HttpResponse response   -   HTTP response object
//    float version           -   HTTP version
//
// Returns:
//    nothing
//
// Description:
//    Assigns a HTTP version to the HTTP response
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpResponseSetVersion(HttpResponse response, float version) {
    response.version = version;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpResponseSetVersion
//
// Parameters:
//    HttpRequest request   -   HTTP request object
//    float version         -   HTTP version
//
// Returns:
//    nothing
//
// Description:
//    Assigns a HTTP version to the HTTP request
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpRequestSetVersion(HttpRequest request, float version) {
    request.version = version;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpResponseGetVersion
//
// Parameters:
//    HttpResponse response   -   HTTP response object
//
// Returns:
//    float   -   HTTP version
//
// Description:
//    Returns the HTTP version of the HTTP response
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function float httpResponseGetVersion(HttpResponse response) {
    return response.version;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpRequestGetVersion
//
// Parameters:
//    HttpRequest request   -   HTTP request object
//
// Returns:
//    float   -   HTTP version
//
// Description:
//    Returns the HTTP version of the HTTP request
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function float httpRequestGetVersion(HttpRequest request) {
    return request.version;
}

/*
HTTP Body Specific Functions
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpResponseSetBody
//
// Parameters:
//    HttpResponse response   -   HTTP response object
//    char[] body             -   body of HTTP message
//
// Returns:
//    nothing
//
// Description:
//    Assigns a string to the body of the HTTP response
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpResponseSetBody(HttpResponse response, char body[]) {
    response.body = body;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpRequestSetBody
//
// Parameters:
//    HttpRequest request   -   HTTP request object
//    char[] body           -   body of HTTP message
//
// Returns:
//    nothing
//
// Description:
//    Assigns a string to the body of the HTTP request
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpRequestSetBody(HttpRequest request, char body[]) {
    request.body = body;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpResponseGetBody
//
// Parameters:
//    HttpResponse response   -   HTTP response object
//
// Returns:
//    char[]   -   body of HTTP response
//
// Description:
//    Returns the body of the HTTP response
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[HTTP_MAX_BODY_LENGTH] httpResponseGetBody(HttpResponse response) {
    return response.body;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpRequestGetBody
//
// Parameters:
//    HttpRequest request   -   HTTP request object
//
// Returns:
//    char[]   -   body of HTTP request
//
// Description:
//    Returns the body of the HTTP request
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[HTTP_MAX_BODY_LENGTH] httpRequestGetBody(HttpRequest request) {
    return request.body;
}

/*
HTTP Request URI Specific Functions
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpRequestSetUri
//
// Parameters:
//    HttpRequest request   -   HTTP request object
//    char[] uri            -   request URI
//
// Returns:
//    nothing
//
// Description:
//    Assigns a URI to the HTTP request
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpRequestSetUri(HttpRequest request, char uri[]) {
    request.uri = uri;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpRequestGetUri
//
// Parameters:
//    HttpRequest request   -   HTTP request object
//
// Returns:
//    char[]   -   request URI
//
// Description:
//    Returns the URI of the HTTP request
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[200] httpRequestGetUri(HttpRequest request) {
    return request.uri;
}

/*
HTTP Request Method Specific Functions
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpRequestGetMethod
//
// Parameters:
//    HttpRequest request   -   HTTP request object
//
// Returns:
//    char[]   -   HTTP method
//
// Description:
//    Returns the method of the HTTP request
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[10] httpRequestGetMethod(HttpRequest request) {
    return request.method;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpRequestSetMethod
//
// Parameters:
//    HttpRequest request   -   HTTP request object
//    char[] method         -   HTTP method
//
// Returns:
//    nothing
//
// Description:
//    Sets the method of the HTTP request
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function httpRequestSetMethod(HttpRequest request, char method[]) {
    request.method = method;
}

/*
HTTP Authentication Header Functions
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpCreateBasicAuthenticationHeader
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
define_function char[1024] httpCreateBasicAuthenticationHeader(char username[], char password[]) {
    stack_var char auth[1024];
    
    auth = "'Basic ',base64Encode("username,':',password")"
    
    return auth;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: httpCreateDigestAuthenticationHeader
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
define_function char[1024] httpCreateDigestAuthenticationHeader(char method[], char requestUri[], char realm[],
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
// Function: httpRequestCopy
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
define_function httpRequestCopy(HttpRequest copyFrom, HttpRequest copyTo) {
	integer i;
	
	copyTo.method = copyFrom.method;
	copyTo.uri = copyFrom.uri;
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
// Function: httpResponseCopy
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
define_function httpResponseCopy(HttpResponse copyFrom, HttpResponse copyTo) {
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
// Function: httpRequestInit
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
define_function httpRequestInit(HttpRequest request) {
	integer i;
	
	request.method = '';
	request.uri = '';
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
// Function: httpResponseInit
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
define_function httpResponseInit(HttpResponse response) {
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
