program_name='sha256'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: sha256
// 
// Description:
//
//    - This include file provides a NetLinx implementation of the SHA-2 (Secure Hash Algorithm 2) cryptographic hash
//      function, specifically SHA-256.
//
// Implementation:
//
//    - Any NetLinx program utilising the sha256 include file must use either the INCLUDE or #INCLUDE keywords to 
//      include the sha256 include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//      functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the 
//      INCLUDE keyword is from the earlier Axcess programming language and is included within the NetLinx programming 
//      language for backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'SHA-256 Demo'
//
//          #include 'sha256'
//
// Usage:
//
//    - The sha256 function provided within this include file takes a message of unbound length and returns a 256=-bit
//      (32-byte) message digest in a CHAR array.
//
//      E.g:
//
//          hashedPassword = sha256'p@55w0rd');
//          // returns "$59,$F4,$6B,$B9,$0C,$FF,$B0,$ED,$7C,$7E,$5D,$B5,$8B,$B3,$00,$F3,$BC,$D7,$14,$F5,$1A,$E7,$23,$ED,$91,$B0,$6A,$3E,$13,$D4,$D5,$B6"
//
//    - Some example SHA-256 results to test against are as follows (note the results are hex values, not ASCII strings):
//
//          msg: ''
//          result: "$e3,$b0,$c4,$42,$98,$fc,$1c,$14,$9a,$fb,$f4,$c8,$99,$6f,$b9,$24,$27,$ae,$41,$e4,$64,$9b,$93,$4c,$a4,$95,$99,$1b,$78,$52,$b8,$55"
//
//          msg: 'The quick brown fox jumps over the lazy dog'
//          result: "$D7,$A8,$FB,$B3,$07,$D7,$80,$94,$69,$CA,$9A,$BC,$B0,$08,$2E,$4F,$8D,$56,$51,$E4,$6D,$3C,$DB,$76,$2D,$02,$D0,$BF,$37,$C9,$E5,$92"
//
//          msg: 'abc'
//          result: "$BA,$78,$16,$BF,$8F,$01,$CF,$EA,$41,$41,$40,$DE,$5D,$AE,$22,$23,$B0,$03,$61,$A3,$96,$17,$7A,$9C,$B4,$10,$FF,$61,$F2,$00,$15,$AD"
//
//          msg: 'abcdefghijklmnopqrstuvwxyz'
//          result: "$71,$C4,$80,$DF,$93,$D6,$AE,$2F,$1E,$FA,$D1,$44,$7C,$66,$C9,$52,$5E,$31,$62,$18,$CF,$51,$FC,$8D,$9E,$D8,$32,$F2,$DA,$F1,$8B,$73"
//
//          msg: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
//          result: "$D6,$EC,$68,$98,$DE,$87,$DD,$AC,$6E,$5B,$36,$11,$70,$8A,$7A,$A1,$C2,$D2,$98,$29,$33,$49,$CC,$1A,$6C,$29,$9A,$1D,$B7,$14,$9D,$38"
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __SHA_256__
#define __SHA_256__


#include 'binary'
#include 'convert'
#include 'string'


define_constant

SHA_256_BYTE_SIZE_BITS = 8
SHA_256_WORD_SIZE_BITS = 32
SHA_256_WORD_SIZE_BYTES = 4
SHA_256_BLOCK_SIZE_BITS = 512
SHA_256_BLOCK_SIZE_BYTES = 64


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: sha256
//
// Parameters:
//    char msg[]   -   Data to hash.
//
// Returns:
//    char[32]   -   256-bit SHA-256 message digest.
//
// Description:
//    This is a NetLinx implemntation of the SHA-256 message digest algorithm as described in RFC6234 (see 
//    https://tools.ietf.org/html/rfc6234).
//
//    Takes a message parameter and returns a 256-bit (32-byte) SHA-256 hash of the message.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function CHAR[32] sha256(char msg[]) {
	char digest[32];
	char binaryResult[1024];
	char msgPadded[1048576];

	long h0, h1, h2, h3, h4, h5, h6, h7;
	
	long k[64];
	
	long ml; // message length in bits
	long L; // length (in 32-bit integers)
	long kZeros;

	integer mIdx;
	integer wIdx;
	integer i;
	integer n;
	integer t;
	
	long s0, s1;

	long a, b, c, d, e, f, g, h;
	
	long ch;
	long temp1, temp2;
	long maj;

	char M[SHA_256_BLOCK_SIZE_BYTES];
	long W[64];
	
	long lenMsg;
	
	long lenMsgBytes;
	long lenMsgBits;

	long TEMP;
	
	char chunk[64]; // 512 bits
	
	////////////////////////////
	// Initialize hash values //
	h0 = $6a09e667;  
	h1 = $bb67ae85;
	h2 = $3c6ef372;
	h3 = $a54ff53a;
	h4 = $510e527f;
	h5 = $9b05688c;
	h6 = $1f83d9ab;
	h7 = $5be0cd19;
	
	/////////////////////////////////////////
	// Initialize array of round constants //
	k[1]  = $428a2f98;  k[2]  = $71374491;  k[3]  = $b5c0fbcf;  k[4]  = $e9b5dba5;
	k[5]  = $3956c25b;  k[6]  = $59f111f1;  k[7]  = $923f82a4;  k[8]  = $ab1c5ed5;
	k[9]  = $d807aa98;  k[10] = $12835b01;  k[11] = $243185be;  k[12] = $550c7dc3;
	k[13] = $72be5d74;  k[14] = $80deb1fe;  k[15] = $9bdc06a7;  k[16] = $c19bf174;
	k[17] = $e49b69c1;  k[18] = $efbe4786;  k[19] = $0fc19dc6;  k[20] = $240ca1cc;
	k[21] = $2de92c6f;  k[22] = $4a7484aa;  k[23] = $5cb0a9dc;  k[24] = $76f988da;
	k[25] = $983e5152;  k[26] = $a831c66d;  k[27] = $b00327c8;  k[28] = $bf597fc7;
	k[29] = $c6e00bf3;  k[30] = $d5a79147;  k[31] = $06ca6351;  k[32] = $14292967;
	k[33] = $27b70a85;  k[34] = $2e1b2138;  k[35] = $4d2c6dfc;  k[36] = $53380d13;
	k[37] = $650a7354;  k[38] = $766a0abb;  k[39] = $81c2c92e;  k[40] = $92722c85;
	k[41] = $a2bfe8a1;  k[42] = $a81a664b;  k[43] = $c24b8b70;  k[44] = $c76c51a3;
	k[45] = $d192e819;  k[46] = $d6990624;  k[47] = $f40e3585;  k[48] = $106aa070;
	k[49] = $19a4c116;  k[50] = $1e376c08;  k[51] = $2748774c;  k[52] = $34b0bcb5;
	k[53] = $391c0cb3;  k[54] = $4ed8aa4a;  k[55] = $5b9cca4f;  k[56] = $682e6ff3;
	k[57] = $748f82ee;  k[58] = $78a5636f;  k[59] = $84c87814;  k[60] = $8cc70208;
	k[61] = $90befffa;  k[62] = $a4506ceb;  k[63] = $bef9a3f7;  k[64] = $c67178f2;
	
	//////////////////////////////
	// Pre-processing (Padding) //
	
	//// begin with the original message of length L bits
	L = length_array(msg) * SHA_256_BYTE_SIZE_BITS;
	//// append a single '1' bit
	msgPadded = "msg,$80"
	//// append K '0' bits, where K is the minimum number >= 0 such that L + 1 + K + 64 is a multiple of 512
	kZeros = 7; // hex 80 = bin 10000000 so we're starting off with 7 zero's appended
	while(((L + 1 + kZeros + 64) % 512) != 0) {
	    msgPadded = "msgPadded,$00";
	    kZeros = kZeros+SHA_256_BYTE_SIZE_BITS;
	}
	//// append L as a 64-bit big-endian integer, making the total post-processed length a multiple of 512 bits
	msgPadded = "msgPadded,$00,$00,$00,$00,ltba(L)";
	
	
	//////////////////////////////////////////////////////
	// Process the message in successive 512-bit chunks //

	// break message into 512-bit chunks
	// for each chunk
	for(mIdx = 1; mIdx < length_array(msgPadded); mIdx=mIdx+SHA_256_BLOCK_SIZE_BYTES) {
	
	    // copy chunk into first 16 words w[0..15] of the message schedule array
	    M = mid_string(msgPadded,mIdx,SHA_256_BLOCK_SIZE_BYTES);
	    i = 1;
	    for(wIdx = 1; wIdx < length_array(M) ; wIdx = wIdx + SHA_256_WORD_SIZE_BYTES) {
		    stack_var char binary[32];
		    binary = stringToBinary(mid_string(M,wIdx,SHA_256_WORD_SIZE_BYTES));
		    W[i] = binaryToLong(binary);
		    i++;
	    }
	    
	    // Extend the first 16 words into the remaining 48 words w[16..63] of the message schedule array:
	    for(t = 17; t <= 64; t++) {
		s0 = (lcrs(W[t-15],7) BXOR lcrs(W[t-15],18) BXOR (W[t-15] >> 3));
		s1 = (lcrs(W[t-2],17) BXOR lcrs(W[t-2],19) BXOR (W[t-2] >> 10));
		W[t] = W[t-16] + s0 + W[t-7] + s1;
	    }
	    
	    // Initialize working variables to current hash value:
	    a = h0;
	    b = h1;
	    c = h2;
	    d = h3;
	    e = h4;
	    f = h5;
	    g = h6;
	    h = h7;
	    
	    // Compression function main loop:
	    for(i=1; i<=64; i++) {
		s1 = lcrs(e,6) bxor lcrs(e,11) bxor lcrs(e,25);
		ch = (e band f) bxor ((bnot e) band g);
		temp1 = h + s1 + ch + k[i] + w[i];
		s0 = lcrs(a,2) bxor lcrs(a,13) bxor lcrs(a,22);
		maj = (a band b) bxor (a band c) bxor (b band c);
		temp2 = s0 + maj;
		
		h = g;
		g = f;
		f = e;
		e = d + temp1;
		d = c;
		c = b;
		b = a;
		a = temp1 + temp2;
	    }
	    
	    // Add the compressed chunk to the current hash value:
	    h0 = h0 + a;
	    h1 = h1 + b;
	    h2 = h2 + c;
	    h3 = h3 + d;
	    h4 = h4 + e;
	    h5 = h5 + f;
	    h6 = h6 + g;
	    h7 = h7 + h;
	}
	
	// Produce the final hash value (big-endian):
	digest = "ltba(h0),ltba(h1),ltba(h2),ltba(h3),ltba(h4),ltba(h5),ltba(h6),ltba(h7)"
	
	return digest;
}


#end_if
