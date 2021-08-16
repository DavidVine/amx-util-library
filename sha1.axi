program_name='sha1'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: sha1
// 
// Description:
//
//    - This include file provides a NetLinx implementation of the SHA-1 (Secure Hash Algorithm 1) cryptographic hash
//      function as defined in RFC 3174 (see https://tools.ietf.org/html/rfc3174).
//
// Implementation:
//
//    - Any NetLinx program utilising the sha1 include file must use either the INCLUDE or #INCLUDE keywords to include 
//      the sha1 include file within the program. While the INCLUDE and #INCLUDE keywords are both functionally 
//      equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE keyword is 
//      from the earlier Axcess programming language and is included within the NetLinx programming language for 
//      backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'SHA-1 Demo'
//
//          #include 'sha1'
//
// Usage:
//
//    - The sha1 function provided within this include file takes a message of unbound length and returns a 160-bit
//      (20-byte) message digest in a CHAR array.
//
//      E.g:
//
//          hashedPassword = sha1('p@55w0rd');
//          // returns "$CE,$0B,$2B,$77,$1F,$7D,$46,$8C,$01,$41,$91,$8D,$AE,$A7,$04,$E0,$E5,$AD,$45,$DB"
//
//    - Some example SHA-1 results to test against are as follows (note the results are hex values, not ASCII strings):
//
//          msg: ''
//          result: "$da,$39,$a3,$ee,$5e,$6b,$4b,$0d,$32,$55,$bf,$ef,$95,$60,$18,$90,$af,$d8,$07,$09"
//
//          msg: 'The quick brown fox jumps over the lazy dog'
//          result: "$2f,$d4,$e1,$c6,$7a,$2d,$28,$fc,$ed,$84,$9e,$e1,$bb,$76,$e7,$39,$1b,$93,$eb,$12"
//
//          msg: 'abc'
//          result: "$a9,$99,$3e,$36,$47,$06,$81,$6a,$ba,$3e,$25,$71,$78,$50,$c2,$6c,$9c,$d0,$d8,$9d"
//
//          msg: 'abcdefghijklmnopqrstuvwxyz'
//          result: "$32,$d1,$0c,$7b,$8c,$f9,$65,$70,$ca,$04,$ce,$37,$f2,$a1,$9d,$84,$24,$0d,$3a,$89"
//
//          msg: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
//          result: "$80,$25,$6f,$39,$a9,$d3,$08,$65,$0a,$c9,$0d,$9b,$e9,$a7,$2a,$95,$62,$45,$45,$74"
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __SHA_1__
#define __SHA_1__


#include 'binary'
#include 'convert'
#include 'string'


define_constant

SHA_1_BYTE_SIZE_BITS = 8
SHA_1_WORD_SIZE_BITS = 32
SHA_1_WORD_SIZE_BYTES = 4
SHA_1_BLOCK_SIZE_BITS = 512
SHA_1_BLOCK_SIZE_BYTES = 64


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: sha1
//
// Parameters:
//    char msg[]   -   Data to hash.
//
// Returns:
//    char[20]   -   160-bit SHA-1 message digest.
//
// Description:
//    This is a NetLinx implemntation of the SHA-1 message digest algorithm as described in RFC3174 (see 
//    https://tools.ietf.org/html/rfc3174).
//
//    Takes a message parameter and returns a 160-bit (20-byte) SHA-1 hash of the message.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function CHAR[20] sha1(char msg[]) {
	char digest[20];
	char binaryResult[1024];
	char msgPadded[1048576];

	long h0, h1, h2, h3, h4;

	integer mIdx;
	integer wIdx;
	integer i;
	integer n;
	integer t;

	long A, B, C, D, E;

	char M[SHA_1_BLOCK_SIZE_BYTES];
	long W[80];
	
	long lenMsg;

	long TEMP;
	
	lenMsg = length_array(msg);
	
	if((lenMsg % 64) > 55) {	// not enough room to pad in the last 512-bit block will need to pad and then add another 512-bit block
		msgPadded = "msg,$80";
		while((length_array(msgPadded) % 64) > 0) {
			msgPadded = "msgPadded,$00";
		}
		while((length_array(msgPadded) % 64) < 56) {	// pad with zeros but leave the last 64-bits alone (reserved for length)
			msgPadded = "msgPadded,$00";
		}
	} else {
		msgPadded = "msg,$80";
		while((length_array(msgPadded) % 64) < 56) {	// pad with zeros but leave the last 64-bits alone (reserved for length)
			msgPadded = "msgPadded,$00";
		}
	}
	msgPadded = "msgPadded,$00,$00,$00,$00,ltba(lenMsg*SHA_1_BYTE_SIZE_BITS)"
	
	h0 = $67452301;
	h1 = $EFCDAB89;
	h2 = $98BADCFE;
	h3 = $10325476;
	h4 = $C3D2E1F0;

	for(mIdx = 1; mIdx < length_array(msgPadded); mIdx=mIdx+SHA_1_BLOCK_SIZE_BYTES) {
	
		M = mid_string(msgPadded,mIdx,SHA_1_BLOCK_SIZE_BYTES);

		i = 1;
		for(wIdx = 1; wIdx < length_array(M) ; wIdx = wIdx + SHA_1_WORD_SIZE_BYTES) {
			stack_var char binary[32];
			binary = stringToBinary(mid_string(M,wIdx,SHA_1_WORD_SIZE_BYTES));
			W[i] = binaryToLong(binary);
			i++;
		}

		for(t = 17; t <= 80; t++) {
			W[t] = lcls((W[t-3] BXOR W[t-8] BXOR W[t-14] BXOR W[t-16]),1);
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
			TEMP = lcls(A,5) + f + E + W[t] + K;
			E = D;
			D = C;
			C = lcls(B,30);
			B = A;
			A = TEMP;
		}

		H0 = (H0 + A);
		H1 = (H1 + B);
		H2 = (H2 + C);
		H3 = (H3 + D);
		H4 = (H4 + E);
	}

	digest = "ltba(H0),ltba(H1),ltba(H2),ltba(H3),ltba(H4)"

	return digest;
}


#end_if
