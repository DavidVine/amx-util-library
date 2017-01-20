PROGRAM_NAME='sha1'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: sha1
// 
// Description:
//
//   - This include file provides a NetLinx implementation of the SHA-1 (Secure Hash Algorithm 1) cryptographic has
//     function as defined in RFC 3174 (see https://tools.ietf.org/html/rfc3174)
//
// Implementation:
//
//   - Any NetLinx program utilising the sha1 include file must use either the INCLUDE or #INCLUDE keywords to include 
//     the sha1 include file within the program. While the INCLUDE and #INCLUDE keywords are both functionally 
//     equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE keyword is 
//     from the earlier Axcess programming language and is included within the NetLinx programming language for 
//     backwards compatibility).
//
//     E.g:
//
//        DEFINE_PROGRAM 'SHA-1 Demo'
//
//        #INCLUDE 'sha1'
//
//   - The sha1 function provided within this include file takes a message of unbound length and returns a 160-bit
//     (20-byte) message digest in a CHAR array.
//
//     E.g:
//
//         hashedPassword = sha1('p@55w0rd');
//
//   - Some example SHA-1 results to test against are as follows (note the results are hex values, not ASCII strings):
//
//     sha1('') gives da39a3ee5e6b4b0d3255bfef95601890afd80709
//     sha1('The quick brown fox jumps over the lazy dog') gives 2fd4e1c67a2d28fced849ee1bb76e7391b93eb12
//     sha1('The quick brown fox jumps over the lazy cog') gives de9f2c7fd25e1b3afad3e85a0bd17d9b100db4b3
//     sha1('abc') gives a9993e364706816aba3e25717850c26c9cd0d89d
//     sha1('abcdefghijklmnopqrstuvwxyz') gives 32d10c7b8cf96570ca04ce37f2a19d84240d3a89
//     sha1('ABCDEFGHIJKLMNOPQRSTUVWXYZ') gives 80256f39a9d308650ac90d9be9a72a9562454574
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include 'binary'
#include 'convert'
#include 'string'

#IF_NOT_DEFINED __SHA_1__
#DEFINE __SHA_1__


define_constant

BYTE_SIZE_BITS = 8
WORD_SIZE_BITS = 32
WORD_SIZE_BYTES = 4
BLOCK_SIZE_BITS = 512
BLOCK_SIZE_BYTES = 64


/*
	Function: sha1

	Parameters:
		char msg[]

	Returns:
		char[20] - 160-bit SHA-1 message digest

	Description:
		This is a NetLinx implemntation of the SHA-1 message digest algorithm as described in RFC3174 (see
		https://tools.ietf.org/html/rfc3174).

		Takes a message parameter and returns a 160-bit (20-byte) SHA-1 hash of the message.
*/
define_function CHAR[20] sha1(char msg[]) {
	char result[20];
	char binaryResult[1024];
	char msgPadded[1048576];

	long h0, h1, h2, h3, h4;

	integer mIdx;
	integer wIdx;
	integer i;
	integer n;
	integer t;

	long A, B, C, D, E;

	char M[BLOCK_SIZE_BYTES];
	long W[80];

	long TEMP;

	msgPadded = sha1Pad(msg);

	h0 = $67452301;
	h1 = $EFCDAB89;
	h2 = $98BADCFE;
	h3 = $10325476;
	h4 = $C3D2E1F0;

	for(mIdx = 1; mIdx < length_array(msgPadded); mIdx=mIdx+BLOCK_SIZE_BYTES) {
	
		M = mid_string(msgPadded,mIdx,BLOCK_SIZE_BYTES);

		i = 1;
		for(wIdx = 1; wIdx < length_array(M) ; wIdx = wIdx + WORD_SIZE_BYTES) {
			stack_var char binary[32];
			binary = stringToBinary(mid_string(M,wIdx,WORD_SIZE_BYTES));
			W[i] = binaryToLong(binary);
			i++;
		}

		for(t = 17; t <= 80; t++) {
			W[t] = sha1CircularShift(1,(W[t-3] BXOR W[t-8] BXOR W[t-14] BXOR W[t-16]));
		}

		A = H0;
		B = H1;
		C = H2;
		D = H3;
		E = H4;

		for(t = 1; t <= 80; t++) {
			stack_var long f;
			stack_var long k;	

			if((1 <= t) && (t <= 20)) {
				f = ((B BAND C) BOR ((BNOT B) BAND D));
				k = $5A827999;
			} else if((21 <= t) && (t <= 40)) {
				f = (B BXOR C BXOR D);
				k = $6ED9EBA1;
			} else if((41 <= t) && (t <= 60)) {
				f = ((B BAND C) BOR (B BAND D) BOR (C BAND D))
				k = $8F1BBCDC;
			} else if((61 <= t) && (t <= 80)) {
				f = (B BXOR C BXOR D)
				k = $CA62C1D6;
			}
			TEMP = sha1CircularShift(5,A) + f + E + W[t] + K;
			E = D;
			D = C;
			C = sha1CircularShift(30,B);
			B = A;
			A = TEMP;
		}

		H0 = (H0 + A);
		H1 = (H1 + B);
		H2 = (H2 + C);
		H3 = (H3 + D);
		H4 = (H4 + E);
	}

	binaryResult = "longToBinary(H0),longToBinary(H1),longToBinary(H2),longToBinary(H3),longToBinary(H4)"
	result = binaryToString(binaryResult);

	return result;
}

define_function long sha1CircularShift(integer shift, long word) {
	stack_var long result;

	result = ((word << shift) | (word >> (32-shift)))

	return result;
}

define_function CHAR[1048576] sha1Pad(char msg[]) {
	char result[1048576];
	long len;
	long i;
	long offset;

	len = length_array(msg);
	
	if((len % 64) > 55) {	// not enough room to pad in the last 512-bit block will need to pad and then add another 512-bit block
		result = "msg,$80";
		while((length_array(result) % 64) > 0) {
			result = "result,$00";
		}
		while((length_array(result) % 64) < 56) {	// pad with zeros but leave the last 64-bits alone (reserved for length)
			result = "result,$00";
		}
	} else {
		result = "msg,$80";
		while((length_array(result) % 64) < 56) {	// pad with zeros but leave the last 64-bits alone (reserved for length)
			result = "result,$00";
		}
	}
	result = "result,$00,$00,$00,$00,ltba(len*BYTE_SIZE_BITS)"

	return result;
}


#END_IF
