program_name='websockets'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: websockets
// 
// Description:
//
//    - This include file provides NetLinx management of client-side websockets as defined in RFC 6455 (see 
//      https://tools.ietf.org/html/rfc6455).
//
//    - It provides functions to open/close websockets as well as send/receive data on websockets.
//
//    - Multiple websockets can be managed simultaneously with minimal programming outside of this include.
//
//    - Callback functions are provided to be implemented outside the include file by the "main" program. These
//      callback functions will be triggered by this include file whenever an "event" occurs on a websocket.
//
//    - The websockets include file performs session tracking through cooking storage which may be useful in situations 
//      where multiple WebSockets may need to be opened to a web server (i.e., one to authenticate and another to 
//      communicate).
//
//    - The websockets include file manages the WebSockets ping/pong automatically to avoid connections going stale.
//
// Implementation:
//
//    - Any NetLinx program utilising the websockets include file must use either the INCLUDE or #INCLUDE keywords to 
//      include the websockets include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//      functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE
//      keyword is from the earlier Axcess programming language and is included within the NetLinx programming language 
//      for backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'Web Sockets Demo'
//
//          #include 'websockets'
//
// Usage:
//
//    - The following functions are provided to manage the websockets:
//
//          webSocketOpen(dev socket, char url[], char subprotocols[], char sessionId[])
//
//              socket:                  NetLinx socket device (e.g., 0:2:0)
//
//              url:                     URL for the WebSocket to connect to (e.g: 'ws://echo.websocket.org')
//
//              subprotocols (optional): Sub-protocol or list of protocols to communicate at an application level (e.g: 
//                                       'chat', 'chat superchat'). Can be empty string ''.
//                                       The full list of registered WebSocket Subprotocols (as at time of writing) is 
//                                       provided within the DEFINE_CONSTANT section of the websockets include file.
//
//              sessionId (optional):    Session ID for tracking a session with a webserver. Can be empty string ''. The
//                                       session ID is stored against the WebSocket and can get obtained at any time by
//                                       calling the webSocketGetSessionId function. The stored session ID will be updated
//                                       if the webserver includes a 'Set-Cookie' header field in the HTTP response during
//                                       the WebSocket Open Handshake.
//
//          E.g:
//
//              webSocketOpen(0:2:0,'ws://echo.websocket.org','','');
//
//          E.g:
//
//              webSocketOpen(0:2:0,'wss://echo.websocket.org','soap','');
//
//          E.g:
//
//              webSocketOpen(0:2:0,'ws://ws.websocketstest.com:8080/service','','');
//
//          E.g:
//
//              webSocketOpen(0:2:0,'ws://192.168.7.118/login','','JSESSIONID=1iamqqta2o6hzbqjzfpdw1piy');
//
//          Note: If url is prefixed with 'ws://' an unsecured websocket will be opened on TCP port 80. If
//          wsResource is prefixed with 'wss://' a secure websocket will be opened on TCP port 443. Alternatively, if
//          the url contains a port this will be used instead (e.g., 'ws://ws.websocketstest.com:8080/service').
//
//          webSocketSend(dev socket, char data[])
//
//              socket:               NetLinx socket device (e.g., 0:2:0)
//
//              data:                 Data to send.
//
//              E.g:
//
//                  webSocketSend(dvSocket,'Rock it with HTML WebSockets!');
//
//          webSocketClose(dev socket, integer code, char reason[])
//
//              socket:               NetLinx socket device (e.g., 0:2:0)
//
//              code:                 Status code indicating why we are closing the connection
//
//              reason:               Human-readable string indicating why we are closing the connection.
//
//              E.g:
//
//                  webSocketClose(dvSocket,0,'');
//
//    - There are 4 x callback functions defined within the websockets include file: webSocketOnOpen, webSocketOnClose,
//      webSocketOnError, and webSocketOnMessage. These callback functions will be called by the websockets include
//      file when corresponding "events" trigger on the websocket.
//
//      The callback functions should not be edited within the websockets include file. Instead, the callback functions
//      should be copied into the main program and then the code statements within the functions can be customised for 
//      the program. In this way, multiple NetLinx modules within the same program (or even different programs) can each
//      make use of the websocket include file without having to make multiple versions of the websockets include file
//      each with different code within the callback functions.
//
//      Note that each of the callback functions are surrounded by #IF_NOT_DEFINED and #END_IF statements within the
//      websockets include file. These statements MUST NOT be copied into the main program, just the function itself.
//      The code within the open and closing braces of the function can then be completely customised.
//
//      Finally, for each of the callback functions implemented within the main program a corresponding #DEFINE
//      statement MUST be placed in the main program ABOVE the #INCLUDE statement which includes the websocket include
//      file. The #DEFINE statement should use a symbol matching the symbol used by the #IF_NOT_DEFINED statement above
//      the definition of the callback function within the websockets include file.
//
//      E.g: The webSocketsOnClose callback function is defined within the websockets include file like so:
//
//          #if_not_defined WEBSOCKET_EVENT_CLOSE
//          define_function webSocketOnClose(dev webSocket) {
//              send_string 0, "'webSocketOnClose(',itoa(webSocket.number),':',itoa(webSocket.port),':',itoa(webSocket.system),')'"
//          }
//          #end_if
// 
//      This callback function SHOULD be implemented in the outside program as follows:
//
//          At the top of the program, make sure to place the #DEFINE compiler directive above the #include compiler directive:
//
//              define_program 'Web Sockets Demo'
//
//              #define WEBSOCKET_EVENT_CLOSE
//              #include 'websockets'
//
//          Then, lower in the code, implement the webSocketOnClose function:
//
//              define_function webSocketOnClose(dev webSocket) {
//                  // code goes here
//              }
//
//          Implementing the callback function as shown above guarantees that the function defined in the outside program
//          file will be called instead of the unimplemented callback function defined within the websockets include file.
//
//    - Some webservers may require authentication via one websocket before another websocket can be opened for 
//      communication. In these scenarios the "comm" websocket will need to maintain the same session with the webserver
//      that was created for the "auth" websocket. When the "auth" websocket is initially establishing itself with the
//      webserver a HTTP handshake (known as the WebSocket Open Handshake) is performed and the webserver will send
//      a session ID to the "auth" websocket within the 'Set-Cookie' header field. When the "comm" websocket establishes
//      a connection to the webserver it will need to send the same session ID to the webserver during the intial HTTP
//      handshake within the 'Cookie' header field.
//
//      The websockets include file maintains a record of session ID's for each websocket created. If the sessionId
//      parameter contained the empty string ('') when the WebSocketOpen function was called the HTTP GET request sent
//      to the webserver will not contain a 'Cookie' header field.
//
//      E.g:
//
//          webSocketOpen(dvSocketAuth,'ws://test.server.org','','');
//
//      If the sessionId parameter was not empty when the WebSocketOpen function was called this value will be cached
//      against the websocket in the websockets include file and sent to the webserver in the 'Cookie' header field of 
//      the HTTP GET request.
//
//      E.g:
//
//          webSocketOpen(dvSocketAuth,'ws://test.server.org','','JSESSIONID=xnjgi1kj1jd7kfbjwvmqyg5m');
//
//      If the servers' HTTP response during the WebSocket Open Handshake contains a 'Set-Cookie' header field and the
//      value contains a session ID this session ID will replace the cached session ID for the WebSocket in the
//      websockets include file. At anytime, the cached session ID for a WebSocket can be read by calling the
//      WebSocketGetSessionId function.
//
//      E.g:
//
//          webSocketGetSessionId(dvSocketAuth);
//
//      To implement session ID tracking across multiple WebSockets it is recommended to first open an "auth" WebSocket
//      and pass an empty string ('') to the sessionId parameter of the WebSocketOpen function - the server will send
//      a session ID when the WebSocket is being established and this will be cached against the "auth" WebSocket.
//
//      E.g:
//
//          webSocketOpen(dvSocketAuth,'ws://test.server.org/login','','');
//
//      Next, capture the open event for the "auth" webserver in the webSocketOpen function and send the login data
//      to the webserver to login.
//
//      E.g:
//
//          define_function webSocketOnOpen(dev socket) {
//              if(socket == dvSocketAuth) {
//                  webSocketSend(dvSocketAuth,'{"login":{"username":"administrator","password":"p@55w0rd"}}');
//              }
//          }
//
//      Next, listen for login confirmation from the webserver in the webSocketOnMessage function and then open a new
//      WebSocket. Call the webSocketGetSessionId function to read the cached session ID from the "auth" webserver and
//      pass this to the sessionId parameter of the webSocketOpen function when creating the new WebSocket.
//
//      E.g:
//
//          define_function webSocketOnMessage(dev socket, char data[]) {
//              if(socket == dvSocketAuth) {
//                  if(data == '{"login":"success"}') {
//                      webSocketOpen(dvSocketComm,'ws://test.server.org/main','',webSocketGetCookie(dvSocketAuth));
//                  }
//              }
//          }
//
//      Next, using the webSocketOnOpen function listen for the "auth" websocket being opened:
//
//          define_function webSocketOnOpen(dev socket) {
//              if(socket == dvSocketAuth) {
//                  webSocketSend(dvSocketAuth,'{"login":{"username":"administrator","password":"p@55w0rd"}}');
//              } else if(socket == dvSocketComm) {
//                  // insert code here
//              }
//          }
//
//      At this point, the "auth" websocket will not only be open but also authenticated with the webserver.
//
//      NOTE: If the HTTP response during the WebSocket Open Handshake contains multiple 'Set-Cookie' header fields
//      the session tracking in the websockets include file may not work (UNTESTED).
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __WEB_SOCKET__
#define __WEB_SOCKET__


//#include 'uri'
#include 'convert'
#include 'crypto'
#include 'http'
#include 'string'
#include 'debug'


define_type

struct WebSocket {
	dev socket;
	Uri url;
	integer tcpPort;
	integer readyState;          // CLOSED | OPEN | OPENING | CLOSING
	char subprotocols[50];       // Sub-protocols
	char clientHandshakeKey[24]; // Sec-WebSocket-Key value for HTTP Opening Handshake
	char sessionId[200];
	char receiveBuffer[20000];
}

struct WebSocketFrame {
	char fin;
	char rsv1;
	char rsv2;
	char rsv3;
	char opCode;
	char mask;
	char maskingKey[4];
	char payloadData[20000]; // payload length can be determined from calling length_array or lenth_string for payloadData
}


define_constant

MAX_WEB_SOCKETS = 20;	// Edit this value if you want to manage more web sockets

// WebSocket Opcodes (see http://www.iana.org/assignments/websocket/websocket.xhtml)
WEBSOCKET_OPCODE_CONT  = 0;
WEBSOCKET_OPCODE_TEXT  = 1;
WEBSOcKET_OPCODE_BIN   = 2;
WEBSOCKET_OPCODE_CLOSE = 8;
WEBSOCKET_OPCODE_PING  = 9;
WEBSOCKET_OPCODE_PONG  = 10;

// WebSocket Close Codes (see http://www.iana.org/assignments/websocket/websocket.xhtml)
WEBSOCKET_CLOSE_STATUS_NORMAL_CLOSURE                        = 1000;
WEBSOCKET_CLOSE_STATUS_GOING_AWAY                            = 1001;
WEBSOCKET_CLOSE_STATUS_PROTOCOL_ERROR                        = 1002;
WEBSOCKET_CLOSE_STATUS_UNSUPPORTED_DATA                      = 1003;
WEBSOCKET_CLOSE_STATUS_NO_STATUS_RECEIVED                    = 1005;
WEBSOCKET_CLOSE_STATUS_ABNORMAL_CLOSURE                      = 1006;
WEBSOCKET_CLOSE_STATUS_INVALID_FRAME_PAYLOAD_DATA            = 1007;
WEBSOCKET_CLOSE_STATUS_POLICY_VIOLATION                      = 1008;
WEBSOCKET_CLOSE_STATUS_MESSAGE_TOO_BIG                       = 1009;
WEBSOCKET_CLOSE_STATUS_MANDATORY_EXT                         = 1010;
WEBSOCKET_CLOSE_STATUS_INTERNAL_SERVER_ERROR                 = 1011;
WEBSOCKET_CLOSE_STATUS_SERVICE_RESTART                       = 1012;
WEBSOCKET_CLOSE_STATUS_TRY_AGAIN_LATER                       = 1013;
WEBSOCKET_CLOSE_STATUS_INVALID_RESPONSE_FROM_UPSTREAM_SERVER = 1014;
WEBSOCKET_CLOSE_STATUS_TLS_HANDSHAKE                         = 1015;

// WebSocket Subprotocols (see http://www.iana.org/assignments/websocket/websocket.xhtml)
WEBSOCKET_SUBPROTOCOL_MBWS[]                = 'MBWS.huawai.com';
WEBSOCKET_SUBPROTOCOL_MBLWS[]               = 'MBLWS.huawai.com';
WEBSOCKET_SUBPROTOCOL_SOAP[]                = 'soap';
WEBSOCKET_SUBPROTOCOL_WAMP[]                = 'wamp';
WEBSOCKET_SUBPROTOCOL_STOMP_10[]            = 'v10.stomp';
WEBSOCKET_SUBPROTOCOL_STOMP_11[]            = 'v11.stomp';
WEBSOCKET_SUBPROTOCOL_STOMP_12[]            = 'v12.stomp';
WEBSOCKET_SUBPROTOCOL_OCPP_1_2[]            = 'ocpp1.2';
WEBSOCKET_SUBPROTOCOL_OCPP_1_5[]            = 'ocpp1.5';
WEBSOCKET_SUBPROTOCOL_OCPP_1_8[]            = 'ocpp1.8';
WEBSOCKET_SUBPROTOCOL_OCPP_2_0[]            = 'ocpp2.0';
WEBSOCKET_SUBPROTOCOL_RFB[]                 = 'rfb';
WEBSOCKET_SUBPROTOCOL_SIP[]                 = 'sip';
WEBSOCKET_SUBPROTOCOL_OMA_REST[]            = 'notificationchannel-netapi-rest.openmobilealliance.org';
WEBSOCKET_SUBPROTOCOL_WPCP[]                = 'wpcp';
WEBSOCKET_SUBPROTOCOL_AMQP[]                = 'amqp';
WEBSOCKET_SUBPROTOCOL_MQTT[]                = 'mqtt';
WEBSOCKET_SUBPROTOCOL_JSFLOW[]              = 'jsflow';
WEBSOCKET_SUBPROTOCOL_RWPCP[]               = 'rwpcp';
WEBSOCKET_SUBPROTOCOL_XMPP[]                = 'xmpp';
WEBSOCKET_SUBPROTOCOL_SHIP[]                = 'ship';
WEBSOCKET_SUBPROTOCOL_MIELE_CLOUD_CONNECT[] = 'mielecloudconnect';
WEBSOCKET_SUBPROTOCOL_PUSH_CHANNEL[]        = 'v10.pcp.sap.com';
WEBSOCKET_SUBPROTOCOL_MSRP[]                = 'msrp';
WEBSOCKET_SUBPROTOCOL_SALTY_RTC_1_0[]       = 'v1.saltyrtc.org';

CLOSED = 0;
CONNECTING = 1;
OPEN = 2;
CLOSING = 3;


define_variable

// WebSocket objects
volatile WebSocket webSockets[MAX_WEB_SOCKETS];

// Socket device array (for data_event)
volatile dev wsSockets[MAX_WEB_SOCKETS];



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Callback functions to be implemented in the main program file
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#if_not_defined WEBSOCKET_EVENT_CLOSE
define_function webSocketOnClose(dev socket) {
	send_string 0, "'webSocketOnClose(',devToString(socket),')'"
}
#end_if

#if_not_defined WEBSOCKET_EVENT_ERROR
define_function webSocketOnError(dev socket, long errorCode, char errorReason[]) {
	send_string 0, "'webSocketOnError(',devToString(socket),',',itoa(errorCode),',',errorReason,')'"
}
#end_if

#if_not_defined WEBSOCKET_EVENT_MESSAGE
define_function webSocketOnMessage(dev socket, char data[]) {
	send_string 0, "'webSocketOnMessage(',devToString(socket),',',data,')'"
}
#end_if

#if_not_defined WEBSOCKET_EVENT_OPEN
define_function webSocketOnOpen(dev socket) {
	send_string 0, "'webSocketOnOpen(',devToString(socket),')'"
}
#end_if


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: webSocketOpen
//
// Parameters:
//    dev socket             -   A NetLinx socket device
//    char url[]             -   A character array (string) of undertermined length containing the WebSocket URL.
//    char subprotocols[]    -   A character array (string) of undetermined length. Contains one of more subprotocols.
//
// Returns:
//    nothing
//
// Description:
//    Initiates the opening and management of a websocket. The url parameter specifies the address for the websocket
//    to connect to. The subprotocols parameter specifies any subprotocols for the server to use once the websocket
//    connection has been established.
//
//    The url must conform to the syntax for a URI as specified in RFC 3986 (see https://tools.ietf.org/html/rfc3986):
//
//       scheme:[//[user:password@]host[:port]][/]path[?query][#fragment]
//
//    The url must be prefixed with either 'ws://' or 'wss://' (for secure connections). If the url contains a port 
//    then that port will be used to open the TCP/IP socket, otherwise port 80 will be used for unsecure websockets or
//    port 443 for secure websockets.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function webSocketOpen(dev socket, char url[], char subprotocols[], char sessionId[]) {
	stack_var integer idx;

	for(idx = 1; idx <= length_array(webSockets); idx++) {
		if(socket == webSockets[idx].socket)
			break;
	}

	if(idx > length_array(webSockets)) { // did not find matching sockets in managed websockets
		if(idx <= max_length_array(webSockets)) { // socket array not full so add socket
			set_length_array(WebSockets,idx);
			WebSockets[idx].socket = socket;
			set_length_array(wsSockets,idx);
			wsSockets[idx] = socket;
			rebuild_event();
		} else {
			webSocketOnError(socket,1,'WebSockets Management Array Full')
			return;
		}
	}

	WebSockets[idx].subprotocols = subprotocols;

	WebSockets[idx].sessionId = sessionId;

	uriFromString(WebSockets[idx].url,url);

	if(WebSockets[idx].url.scheme == 'ws') {
		if(WebSockets[idx].url.port) {
			ip_client_open(socket.port,WebSockets[idx].url.host,WebSockets[idx].url.port,IP_TCP);
		} else {
			ip_client_open(socket.port,WebSockets[idx].url.host,80,IP_TCP);
		}
	} else if(WebSockets[idx].url.scheme == 'wss') {
		if(WebSockets[idx].url.port) {
			tls_client_open(socket.port,WebSockets[idx].url.host,WebSockets[idx].url.port,TLS_IGNORE_CERTIFICATE_ERRORS);
		} else {
			tls_client_open(socket.port,WebSockets[idx].url.host,443,TLS_IGNORE_CERTIFICATE_ERRORS);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: webSocketSend
//
// Parameters:
//    dev socket    -   A NetLinx socket device
//    char data[]   -   A character array (string) of undertermined length. Contains data to send.
//
// Returns:
//    nothing
//
// Description:
//    Sends a websocket message through a NetLinx socket device. The data is packed into a websocket frame prior to
//    sending. Data is treated as text.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function webSocketSend(dev socket, char data[]) {
	webSocketSendText(socket,data);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: webSocketClose
//
// Parameters:
//    dev socket      -   A NetLinx socket device
//    integer code    -   A character array (string) of undertermined length. Contains status code indicating why
//                        the connection is being closed.
//    char reason[]   -   A character array (string) of undertermined length. Human-readable string explaining why the
//                        connection is closing.
//
// Returns:
//    nothing
//
// Description:
//    Initiates the closing of a WebSocket connection or connection attempt. If the connection is already CLOSED, this 
//    method does nothing. Note that, as per RFC6455, the socket connection for a websocket is ALWAYS closed by the
//    server and never the client. If the client wishes to close the connection it sends the websocket close frame to
//    the server and the server will close the socket.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function webSocketClose(dev socket, integer code, char reason[]) {
	stack_var integer idx;

	for(idx=1; idx<=length_array(wsSockets); idx++) {
		if(socket == wsSockets[idx]) {
			if ((webSockets[idx].readyState != CLOSED) && (webSockets[idx].readyState != CLOSING)) {
				webSockets[idx].readyState = CLOSING;
				webSocketSendClose(socket,'');
			}
			break;
		}
	}	
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: webSocketFrameToString
//
// Parameters:
//    WebSocketFrame wsf   -   A web socket frame structure
//
// Returns:
//    char[1024]   -   A character array (string) containing a websocket frame
//
// Description:
//    Builds a data string conforming to the websocket protocol data frame defined in RFC6455.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char [1024] webSocketFrameToString(WebSocketFrame wsf) {
	char result[1024];
	long payloadLen;

	result = '';
	set_length_array(result,2);	// minimum length for a valid websocket frame

	result[1] = type_cast((wsf.fin BAND $1) << 7);
	result[1] = type_cast(result[1] BOR ((wsf.rsv1 BAND $1) << 6));
	result[1] = type_cast(result[1] BOR ((wsf.rsv2 BAND $1) << 5));
	result[1] = type_cast(result[1] BOR ((wsf.rsv3 BAND $1) << 4));

	result[1] = type_cast(result[1] BOR (wsf.opCode BAND $F));

	result[2] = type_cast((wsf.mask BAND $1) << 7);

	payloadLen = length_array(wsf.payloadData);

	if(payloadLen == 0) {
		if(wsf.mask) {
			result = "result,wsf.maskingKey";
		}
		return result;
	} else if(payloadLen <= 125) {
		result[2] = type_cast(result[2] BOR payloadLen);
		//result[2] = type_cast(result[2] BOR (payloadLen BAND $7F));
		set_length_array(result,2);
	} else if(payloadLen <= 65535) {
		result[2] = type_cast(result[2] BOR 126);
		result[3] = type_cast((payloadLen BAND $FF00) >> 8);
		result[4] = type_cast(payloadLen BAND $FF);
		set_length_array(result,4);
	} else if(payloadLen > 65535) {
		result[2] = type_cast(result[2] BOR 127);
		set_length_array(result,6);
		result = "result,ltba(payloadLen)"
		set_length_array(result,10);
	}

	if(wsf.mask) {
		result = "result,wsf.maskingKey";
		result = "result,webSocketMask(wsf.payloadData,wsf.maskingKey)";
	} else {
		result = "result,wsf.payloadData";
	}

	return result;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: webSocketFrameFromString
//
// Parameters:
//    WebSocketFrame wsf   -   A web socket frame structure
//    char data[]          -   A character array (string) of undetermined length.
//
// Returns:
//    nothing
//
// Description:
//    The data string is assumed to conform to the websocket protocol data frame defined in RFC6455. The data string
//    is parsed and the WebSocketFrame parameter (wsf) is updated to contain the values obtained during the parsing.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function sinteger webSocketFrameFromString(WebSocketFrame wsf, char data[]) {
	long payloadLen;
	integer nByte;
	
	if(length_array(data) < 2) {
	    print("'webSocketFrameFromString exiting, data is less than 2 bytes'",false);
	    return -1;
	}

	wsf.fin = 0;
	wsf.rsv1 = 0;
	wsf.rsv2 = 0;
	wsf.rsv3 = 0;
	wsf.opCode = 0;
	wsf.mask = 0;
	wsf.maskingKey = '';
	wsf.payloadData = '';

	wsf.fin = type_cast((data[1] BAND $80) >> 7)
	wsf.rsv1 = type_cast((data[1] BAND $40) >> 6)
	wsf.rsv2 = type_cast((data[1] BAND $20) >> 5)
	wsf.rsv3 = type_cast((data[1] BAND $10) >> 4)
	wsf.opCode = type_cast(data[1] BAND $F)

	wsf.mask = type_cast((data[2] BAND $80) >> 7)

	if((data[2] BAND $7F) == 0) {
		payloadLen = 0;
		nByte = 3;
	} else if((data[2] BAND $7F) <= 125) {
		payloadLen = (data[2] BAND $7F);
		nByte = 3;
	} else if((data[2] BAND $7F) == 126) {
		payloadLen = ((data[3] << 8) BOR (data[4]))
		nByte = 5;
	} else if((data[2] BAND $7F) == 127) {
		payloadLen = ((data[3] << 56) BOR (data[4] << 48) BOR (data[5] << 40) BOR (data[6] << 32) 
		             BOR (data[7] << 24) BOR (data[8] << 16) BOR (data[9] << 8) BOR (data[10]));
		nByte = 11;
	}
	if(wsf.mask) {
		wsf.maskingKey = "data[nByte],data[nByte+1],data[nByte+2],data[nByte+3]";
		
		if((payloadLen != 0) && (length_array(data) < (nByte+4+payloadLen-1))) {
		    print("'webSocketFrameFromString exiting, payload following masking key not complete'",false);
		    return -1;
		}
	
		wsf.payloadData = webSocketUnmask(mid_string(data,nByte+4,payloadLen),wsf.maskingKey);
	} else {
	
		if((payloadLen != 0) && (length_array(data) < (nByte+payloadLen-1))) {
		    print("'webSocketFrameFromString exiting, payload not complete'",false);
		    return -1;
		}
		
		wsf.payloadData = mid_string(data,nByte,payloadLen);
	}
	
	if(wsf.payloadData == 0) {
		remove_string(data,"data[1],data[2]",1)
	}
	else {
		remove_string(data,wsf.payloadData,1);
	}
	
	print("'webSocketFrameFromString processed complete WebSocket Frame'",false);
	
	return 0;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Functions:
//    webSocketSendContinuation
//    webSocketSendText
//    webSocketSendBinary
//    webSocketSendPing
//    webSocketSendPong
//    webSocketSendClose
//
// Parameters:
//    dev socket    -   A NetLinx socket device
//    char data[]   -   A character array (string) of undertermined length. Contains data to send.
//
// Returns:
//    nothing
//
// Description:
//    Sends a websocket message through a NetLinx socket device. The data is packed into a websocket frame prior to
//    sending.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function webSocketSendContinuation(dev socket, char data[]) {
	print("'Sending websocket continuation frame (',itoa(length_array(webSocketPackFrame(WEBSOCKET_OPCODE_CONT,data))),' bytes) to Socket[',devToString(socket),'].'",false);
	send_string socket, webSocketPackFrame(WEBSOCKET_OPCODE_CONT,data);
}

define_function webSocketSendText(dev socket, char data[]) {
	print("'Sending websocket text data (',itoa(length_array(webSocketPackFrame(WEBSOCKET_OPCODE_TEXT,data))),' bytes) to Socket[',devToString(socket),'].'",false);
	send_string socket, webSocketPackFrame(WEBSOCKET_OPCODE_TEXT,data);
}

define_function webSocketSendBinary(dev socket, char data[]) {
	print("'Sending websocket binary data (',itoa(length_array(webSocketPackFrame(WEBSOCKET_OPCODE_BIN,data))),' bytes) to Socket[',devToString(socket),'].'",false);
	send_string socket, webSocketPackFrame(WEBSOCKET_OPCODE_BIN,data);
}

define_function webSocketSendPing(dev socket, char data[]) {
	print("'Sending websocket ping (',itoa(length_array(webSocketPackFrame(WEBSOCKET_OPCODE_PING,data))),' bytes) to Socket[',devToString(socket),'].'",false);
	send_string socket, webSocketPackFrame(WEBSOCKET_OPCODE_PING,data);
}

define_function webSocketSendPong(dev socket, char data[]) {
	print("'Sending websocket pong (',itoa(length_array(webSocketPackFrame(WEBSOCKET_OPCODE_PONG,data))),' bytes) to Socket[',devToString(socket),'].'",false);
	send_string socket, webSocketPackFrame(WEBSOCKET_OPCODE_PONG,data);
}

define_function webSocketSendClose(dev socket, char data[]) {
	print("'Sending websocket close (',itoa(length_array(webSocketPackFrame(WEBSOCKET_OPCODE_CLOSE,data))),' bytes) to Socket[',devToString(socket),'].'",false);
	send_string socket, webSocketPackFrame(WEBSOCKET_OPCODE_CLOSE,data);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Functions:
//    webSocketMask
//    webSocketUnmask
//
// Parameters:
//    char data[]         -   A character array (string) of undertermined length. Contains data to mask/unmask.
//    char maskingKey[]   -   A character array (string) of undertermined length. Contains masking key.
//
// Returns:
//    char[1024]   -   A character array (string) containing masked/unmasked data
//
// Description:
//    Masks/Unmasks data confirming to the masking/unmasking process defined in RFC6455 (same process for both).
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[1024] webSocketMask(char data[], char maskingKey[4]) {
	char result[1024];
	integer i, j;

	for(i = 1; i<=length_array(data); i++) {
		j = (((i-1) mod 4)+1);
		result[i] = (data[i] BXOR maskingKey[j]);
	}
	set_length_array(result,i-1);
	return result;
}

define_function char[1024] webSocketUnmask(char data[], char maskingKey[4]) {
	return webSocketMask(data,maskingKey);	// the process for masking/unmasking is the same
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: webSocketPackFrame
//
// Parameters:
//    char opCode   -   A single-byte char value. Contains Op Code.
//    char data[]   -   A character array (string) of undertermined length. Contains data.
//
// Returns:
//    char[1024]   -   A character array (string) conforming to the websocket protocol data frame defined in RFC6455
//
// Description:
//    Takes a websocket Op Code and some data and creates and returns a string containing a websocket protocol data
//    frame. The data string may be empty.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[1024] webSocketPackFrame(char opCode, char data[]) {
	char frame[1024];
	long maskingKeyAsLong;
	char maskingKey[4];
	char maskedData[1024];
	char i,j;
	WebSocketFrame wsf;

	wsf.fin = 1;
	wsf.rsv1 = 0;
	wsf.rsv2 = 0;
	wsf.rsv3 = 0;
	wsf.opCode = opCode;
	wsf.mask = 1;
	wsf.maskingKey = ltba(random_number(4294967295));
	wsf.payloadData = data;

	return webSocketFrameToString(wsf);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Functions:
//    webSocketPackTextFrame
//    webSocketPackBinaryFrame
//    webSocketPackPingFrame
//    webSocketPackPongFrame
//    webSocketPackCloseFrame
//
// Parameters:
//    char data[]   -   A character array (string) of undertermined length. Contains data.
//
// Returns:
//    char[1024]   -   A character array (string) conforming to the websocket protocol data frame defined in RFC6455
//
// Description:
//    Takes a some data and creates and returns a string containing a websocket protocol data frame. The data string 
//    may be empty.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[1024] webSocketPackTextFrame(char data[]) {
	return webSocketPackFrame(WEBSOCKET_OPCODE_TEXT,data);
}

define_function char[1024] webSocketPackBinaryFrame(char data[]) {
	return webSocketPackFrame(WEBSOCKET_OPCODE_BIN,data);
}

define_function char[1024] webSocketPackPingFrame(char data[]) {
	return webSocketPackFrame(WEBSOCKET_OPCODE_PING,data);
}

define_function char[1024] webSocketPackPongFrame(char data[]) {
	return webSocketPackFrame(WEBSOCKET_OPCODE_PONG,data);
}

define_function char[1024] webSocketPackCloseFrame(char data[]) {
	return webSocketPackFrame(WEBSOCKET_OPCODE_CLOSE,data);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: webSocketCreateHandshakeKeyClient
//
// Parameters:
//    none
//
// Returns:
//    char[200]   -   A character array (string) containing the client-side key for the WebSocket HTTP Open Handshake
//
// Description:
//    Creates a client-side key to be used in the Sec-WebSocket-Key header of a WebSocket HTTP Open Hansdhake (see 
//    RFC6455).
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[200] webSocketCreateHandshakeKeyClient() {
	char secWebSocketKey[200], byteVal[16];
	integer i;

	for(i=1;i<=max_length_array(byteVal);i++) {
		byteVal[i] = random_number(256)
	}
	set_length_array(byteVal,16);

	secWebSocketKey = encode('base64',byteVal);

	return secWebSocketKey;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: webSocketCreateHandshakeKeyServer
//
// Parameters:
//    char secWebSocketKey[]   -   A character array (string) of undertermined length.
//
// Returns:
//    char[200]   -   A character array (string) containing the server-side key for the WebSocket HTTP Open Handshake
//
// Description:
//    Creates a server-side key to be used in the Sec-WebSocket-Accept header of a WebSocket HTTP Open Hansdhake (see 
//    RFC6455). The secWebSocketKey parameter should contain the client-side key which is used by the server to produce
//    the server-side key.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[200] webSocketCreateHandshakeKeyServer(char secWebSocketKey[]) {
	char secWebSocketAccept[200];

	secWebSocketAccept = encode('base64',hash('sha1',"secWebSocketKey,'258EAFA5-E914-47DA-95CA-C5AB0DC85B11'"));

	return secWebSocketAccept;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: webSocketSendOpenHandshake
//
// Parameters:
//    dev socket   -   A NetLinx socket device
//
// Returns:
//    nothing
//
// Description:
//    Creates and sends a HTTP string containing a WebSocket Open Handshake (See RFC6455).
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function webSocketSendOpenHandshake(dev socket) {
	HttpRequest request;
	char secWebSocketKey[200], host[200];
	integer idx;

	for(idx=1; idx<=length_array(webSockets); idx++) {
		if(socket == webSockets[idx].socket) {
			break;
		}
	}
	if(idx > length_array(wsSockets)) return;

	webSockets[idx].clientHandshakeKey = webSocketCreateHandshakeKeyClient();

	httpInitRequest(request);
	request.method = HTTP_METHOD_GET;
	request.version = 1.1;
	request.requestUri = uriToString(webSockets[idx].url); //'ws://echo.websocket.org');
	httpSetHeader(request.headers, 'Host', webSockets[idx].url.host);
	httpSetHeader(request.headers, 'Connection', 'Upgrade');
	httpSetHeader(request.headers, 'Upgrade', 'websocket');
	httpSetHeader(request.headers, 'Origin', "'http://',webSockets[idx].url.host");
	if(length_string(WebSockets[idx].sessionId)) {
		httpSetHeader(request.headers, 'Cookie', WebSockets[idx].sessionId); //"'JSESSIONID=','6wi46ymy1v9ss6yv289loli2'"); // 5wi46ymy1v9ss6yv289loli2
	}
	httpSetHeader(request.headers, 'Sec-WebSocket-Version', '13'); // version 13 is the standard as defined by RFC6455
	httpSetHeader(request.headers, 'Sec-WebSocket-Key', webSockets[idx].clientHandshakeKey);
	if(length_string(webSockets[idx].subprotocols)) {
		httpSetHeader(request.headers, 'Sec-WebSocket-Protocol', webSockets[idx].subprotocols);
	}
	print("'Sending HTTP WebSocket Open Handshake to Socket[',devToString(socket),']:'",false);

	print(httpRequestToString(request),true);

	webSockets[idx].readyState = CONNECTING;

	send_string socket, httpRequestToString(request);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: webSocketGetSessionId
//
// Parameters:
//    dev socket   -   A NetLinx socket device
//
// Returns:
//    char[500]   -   A character array
//
// Description:
//    Returns the session ID stored for the websocket. May be an empty string (''). Returns empty string if socket not
//    being managed.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function char[500] webSocketGetSessionId(dev socket) {
	stack_var integer idx;

	for(idx = 1; idx <= length_array(webSockets); idx++) {
		if(socket == webSockets[idx].socket)
			return webSockets[idx].sessionId;
	}

	return '';
}


define_event

data_event[wsSockets] {

	online: {
		integer idx;
		dev socket;

		idx = get_last(wsSockets)
		socket = wsSockets[idx];

		print("'Socket (',devToString(socket),') Open on port ',itoa(data.sourceport)",false);
		
		clear_buffer webSockets[idx].receiveBuffer

		webSocketSendOpenHandshake(socket);
	}

	offline: {
		integer idx;
		dev socket;

		idx = get_last(wsSockets)
		socket = wsSockets[idx];

		print("'Socket (',devToString(socket),') Closed'",false);
		
		clear_buffer webSockets[idx].receiveBuffer

		webSockets[idx].readyState = CLOSED;
		webSocketOnClose(socket);
	}

	onerror: {
		integer idx;
		dev socket;

		idx = get_last(wsSockets)
		socket = wsSockets[idx];

		print("'Socket (',devToString(socket),') Error: ',itoa(data.number)",false);

		if(data.number != 14)	{ // did notalready open
			webSockets[idx].readyState = CLOSED;
			webSocketOnError(socket,data.number,data.text);
		}
	}

	string: {
		integer idx;
		dev socket;
		stack_var HttpResponse response; //stack_var HttpMessage httpResponse;
		stack_var WebSocketFrame wsf;

		idx = get_last(wsSockets)
		socket = wsSockets[idx];

		print("'Received data (',itoa(length_array(data.text)),' bytes) on Socket[',devToString(socket),'].'",false);

		webSockets[idx].receiveBuffer = "webSockets[idx].receiveBuffer,data.text"

		if((webSockets[idx].readyState == OPEN) || (webSockets[idx].readyState == CLOSING)) { // assume we received a websocket protocol string

			while(webSocketFrameFromString(wsf,webSockets[idx].receiveBuffer) == 0) {

			    print("'Successfully built WebSocket Frame from string'",false);

			    if(wsf.opCode == WEBSOCKET_OPCODE_TEXT) {
				    print("'Data received on Socket[',devToString(socket),'] is WebSocket text.'",false);
				    if(wsf.mask) {
					    webSocketOnMessage(socket,webSocketUnmask(wsf.payloadData,wsf.maskingKey));
				    } else {
					    webSocketOnMessage(socket,wsf.payloadData);
				    }
			    } else if(wsf.opCode == WEBSOcKET_OPCODE_BIN) {
				    print("'Data received on Socket[',devToString(socket),'] is WebSocket binary.'",false);
				    if(wsf.mask) {
					    webSocketOnMessage(socket,webSocketUnmask(wsf.payloadData,wsf.maskingKey));
				    } else {
					    webSocketOnMessage(socket,wsf.payloadData);
				    }
			    } else if(wsf.opCode == WEBSOCKET_OPCODE_CONT) {
				    print("'Data received on Socket[',devToString(socket),'] is WebSocket continuation.'",false);
				    if(wsf.mask) {
					    webSocketOnMessage(socket,webSocketUnmask(wsf.payloadData,wsf.maskingKey));
				    } else {
					    webSocketOnMessage(socket,wsf.payloadData);
				    }
			    } else if(wsf.opCode == WEBSOCKET_OPCODE_PING) {
				    print("'Data received on Socket[',devToString(socket),'] is WebSocket ping. Sending pong in response.'",false);
				    webSocketSendPong(socket,wsf.payloadData); // pong must contain same "appication data" as received ping
			    } else if(wsf.opCode == WEBSOCKET_OPCODE_PONG) {
				    print("'Data received on Socket[',devToString(socket),'] is WebSocket pong.'",false);
			    } else if(wsf.opCode == WEBSOCKET_OPCODE_CLOSE) {
				    print("'Data received on Socket[',devToString(socket),'] is WebSocket close.'",false);
				    webSockets[idx].readyState = CLOSING;
			    }
			    else {
				    print("'Data received on Socket[',devToString(socket),'] unhandled.'",false);
			    }

			    if(length_string(webSockets[idx].receiveBuffer) == 0) {
				break;
			    }
			}

			print("itoa(length_array(webSockets[idx].receiveBuffer)),' bytes remain in receive buffer unprocessed.'",false);
		} else {	// assume we received a HTTP protocol string
			char expectedWebSocketAcceptValue[1024]
			stack_var char sessionIdHeader[50];
			stack_var char cookie[100];

			print("'Data received on Socket[',devToString(socket),'] is HTTP:'",false);
			httpParseResponse(response, webSockets[idx].receiveBuffer);
			clear_buffer webSockets[idx].receiveBuffer
			print(httpResponseToString(response),true);

			expectedWebSocketAcceptValue = webSocketCreateHandshakeKeyServer(webSockets[idx].clientHandshakeKey);

			cookie = httpGetHeader(response.headers,'Set-Cookie')
			if(cookie != '') {
				if(find_string(cookie,"';'",1)) {
					WebSockets[idx].sessionId = remove_string(cookie,"';'",1);
					trim_string(WebSockets[idx].sessionId,0,1);
				} else {
					WebSockets[idx].sessionId = cookie;
				}
			}

			if(response.status.code != HTTP_STATUS_CODE_SWITCHING_PROTOCOLS) {
				print("'WebSocket open handshake failed on Socket[',devToString(socket),']. Status Code: ',itoa(response.status.code)",false);
				webSocketOnError(socket,0,'');
				webSocketClose(socket,0,'');
			} else if(LOWER_STRING(httpGetHeader(response.headers,'Upgrade')) != 'websocket') {
				print("'WebSocket open handshake failed on Socket[',devToString(socket),']. Upgrade: ',httpGetHeader(response.headers,'Upgrade')",false);
				webSocketOnError(socket,0,'');
				webSocketClose(socket,0,'');
			} else if(UPPER_STRING(httpGetHeader(response.headers,'Connection')) != UPPER_STRING('Upgrade')) {
				print("'WebSocket open handshake failed on Socket[',devToString(socket),']. Connection: ',httpGetHeader(response.headers,'Connection')",false);
				webSocketOnError(socket,0,'');
				webSocketClose(socket,0,'');
			} else if(httpGetHeader(response.headers,'Sec-WebSocket-Accept') != expectedWebSocketAcceptValue) {
				print("'WebSocket open handshake failed on Socket[',devToString(socket),']. Sec-WebSocket-Accept: ',httpGetHeader(response.headers,'Sec-WebSocket-Accept')",false);
				webSocketOnError(socket,0,'');
				webSocketClose(socket,0,'');
			} else {
				// if we reached this point then the web socket opened successfully
				print("'WebSocket open handshake succeeded on Socket[',devToString(socket),']. Switching protocol from HTTP to WebSocket .'",false);
				webSockets[idx].readyState = OPEN;
				webSocketOnOpen(socket);
			}
		}
	}
}


#end_if
