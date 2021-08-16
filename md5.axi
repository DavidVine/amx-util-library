program_name='md5'

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include: md5
// 
// Description:
//
//    - This include file provides a NetLinx implementation of the MD5 message-digest algorithm. A cryptographic hash
//      function as defined in RFC 1321 (see https://tools.ietf.org/html/rfc1321).
//
// Implementation:
//
//    - Any NetLinx program utilising the md5 include file must use either the INCLUDE or #INCLUDE keywords to 
//      include the md5 include file within the program. While the INCLUDE and #INCLUDE keywords are both 
//      functionally equivalent the #INCLUDE keyword is recommended only because it is the NetLinx keyword (the INCLUDE
//      keyword is from the earlier Axcess programming language and is included within the NetLinx programming language 
//      for backwards compatibility).
//
//      Note: The NetLinx language is not case-sensitive when it comes to keywords. The convention used in this project
//      is for keywords to be written in lower case (e.g., include instead of INCLUDE).
//
//      E.g:
//
//          define_program 'MD5 Demo'
//
//          #include 'md5'
//
// Usage:
//
//    - The md5 function provided within this include file takes a message of unbound length and returns a 128-bit
//      (16-byte) message digest in a CHAR array.
//
//      E.g:
//
//          hashedPassword = md5('p@55w0rd');
//          // returns "$39,$F1,$3D,$60,$B3,$F6,$FB,$E0,$BA,$16,$36,$B0,$A9,$28,$3C,$50"
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#if_not_defined __MD5__
#define __MD5__


#include 'binary'
#include 'convert'
#include 'string'


define_constant

MD5_BYTE_SIZE_BITS = 8
MD5_WORD_SIZE_BITS = 32
MD5_WORD_SIZE_BYTES = 4
MD5_BLOCK_SIZE_BITS = 512
MD5_BLOCK_SIZE_BYTES = 64


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// Function: md5
//
// Parameters:
//    char msg[]   -   Data to hash.
//
// Returns:
//    CHAR[16]   -   128-bit MD5 message digest.
//
// Description:
//    This is a NetLinx implemntation of the MD5 message digest algorithm as described in RFC1321 (see 
//    https://tools.ietf.org/html/rfc1321).
//
//    Takes a message parameter and returns a 128-bit (16-byte) MD5 hash of the message.
// 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
define_function CHAR[16] md5(char msg[]) {
    long K[64];
    long s[64];

    long a0, b0, c0, d0;

    char msgPadded[1048576];
    char digest[16];

    integer chunkIdx;

    long lenMsg;
    long lenPadded;

    a0 = $67452301
    b0 = $efcdab89
    c0 = $98badcfe
    d0 = $10325476

    s[1]  = 7;   s[2]  = 12;   s[3]  = 17;   s[4]  = 22;
    s[5]  = 7;   s[6]  = 12;   s[7]  = 17;   s[8]  = 22;
    s[9]  = 7;   s[10] = 12;   s[11] = 17;   s[12] = 22;
    s[13] = 7;   s[14] = 12;   s[15] = 17;   s[16] = 22;
    s[17] = 5;   s[18] = 9;    s[19] = 14;   s[20] = 20;
    s[21] = 5;   s[22] = 9;    s[23] = 14;   s[24] = 20;
    s[25] = 5;   s[26] = 9;    s[27] = 14;   s[28] = 20;
    s[29] = 5;   s[30] = 9;    s[31] = 14;   s[32] = 20;
    s[33] = 4;   s[34] = 11;   s[35] = 16;   s[36] = 23;
    s[37] = 4;   s[38] = 11;   s[39] = 16;   s[40] = 23;
    s[41] = 4;   s[42] = 11;   s[43] = 16;   s[44] = 23;
    s[45] = 4;   s[46] = 11;   s[47] = 16;   s[48] = 23;
    s[49] = 6;   s[50] = 10;   s[51] = 15;   s[52] = 21;
    s[53] = 6;   s[54] = 10;   s[55] = 15;   s[56] = 21;
    s[57] = 6;   s[58] = 10;   s[59] = 15;   s[60] = 21;
    s[61] = 6;   s[62] = 10;   s[63] = 15;   s[64] = 21;

    K[1]  = $d76aa478;    K[2]  = $e8c7b756;    K[3]  = $242070db;    K[4]  = $c1bdceee;
    K[5]  = $f57c0faf;    K[6]  = $4787c62a;    K[7]  = $a8304613;    K[8]  = $fd469501;
    K[9]  = $698098d8;    K[10] = $8b44f7af;    K[11] = $ffff5bb1;    K[12] = $895cd7be;
    K[13] = $6b901122;    K[14] = $fd987193;    K[15] = $a679438e;    K[16] = $49b40821;
    K[17] = $f61e2562;    K[18] = $c040b340;    K[19] = $265e5a51;    K[20] = $e9b6c7aa;
    K[21] = $d62f105d;    K[22] = $02441453;    K[23] = $d8a1e681;    K[24] = $e7d3fbc8;
    K[25] = $21e1cde6;    K[26] = $c33707d6;    K[27] = $f4d50d87;    K[28] = $455a14ed;
    K[29] = $a9e3e905;    K[30] = $fcefa3f8;    K[31] = $676f02d9;    K[32] = $8d2a4c8a;
    K[33] = $fffa3942;    K[34] = $8771f681;    K[35] = $6d9d6122;    K[36] = $fde5380c;
    K[37] = $a4beea44;    K[38] = $4bdecfa9;    K[39] = $f6bb4b60;    K[40] = $bebfbc70;
    K[41] = $289b7ec6;    K[42] = $eaa127fa;    K[43] = $d4ef3085;    K[44] = $04881d05;
    K[45] = $d9d4d039;    K[46] = $e6db99e5;    K[47] = $1fa27cf8;    K[48] = $c4ac5665;
    K[49] = $f4292244;    K[50] = $432aff97;    K[51] = $ab9423a7;    K[52] = $fc93a039;
    K[53] = $655b59c3;    K[54] = $8f0ccc92;    K[55] = $ffeff47d;    K[56] = $85845dd1;
    K[57] = $6fa87e4f;    K[58] = $fe2ce6e0;    K[59] = $a3014314;    K[60] = $4e0811a1;
    K[61] = $f7537e82;    K[62] = $bd3af235;    K[63] = $2ad7d2bb;    K[64] = $eb86d391;

    lenMsg = length_array(msg);
    msgPadded = "msg,$80"
    lenPadded = length_array(msgPadded);
    while(((lenPadded*MD5_BYTE_SIZE_BITS) mod 512) != 448) {
    	msgPadded = "msgPadded,$00"
	lenPadded = length_array(msgPadded);
    }
    msgPadded = "msgPadded,ltba(ltle(lenMsg*MD5_BYTE_SIZE_BITS)),$00,$00,$00,$00";

    for(chunkIdx = 1; chunkIdx < length_array(msgPadded); chunkIdx=chunkIdx+MD5_BLOCK_SIZE_BYTES) {

	char chunk[MD5_BLOCK_SIZE_BYTES];
	long M[16];
	integer mIdx;
	long A, B, C, D;
	long i;

	chunk = mid_string(msgPadded,chunkIdx,MD5_BLOCK_SIZE_BYTES);
	
	i = 1;
	for(mIdx=1; mIdx<=length_array(chunk); mIdx=mIdx+MD5_WORD_SIZE_BYTES) {
	    char word[MD5_WORD_SIZE_BYTES];
	    word = mid_string(chunk,mIdx,MD5_WORD_SIZE_BYTES);
	    M[i] = ((word[4] << 24) BOR (word[3] << 16) BOR (word[2] << 8) BOR word[1])
	    
	    i++;
	}

	A = a0;
	B = b0;
	C = c0;
	D = d0;

	for(i=0; i <= 63; i++) {
	    long F, g;

	    if((i>=0) && (i<=15)) {
		F = (B BAND C) BOR ((BNOT B) BAND D);
		g = i;
	    }
	    else if((i>=16) && (i<=31)) {
		F = (D BAND B) BOR ((BNOT D) BAND C);
		g = ((5*i) + 1) mod 16;
	    }
	    else if((i>=32) && (i<=47)) {
		F = B BXOR C BXOR D;
		g = ((3*i) + 5) mod 16;
	    }
	    else if((i>=48) && (i<=63)) {
		F = C BXOR (B BOR (BNOT D));
		g = (7*i) mod 16;
	    }

	    F = F + A + K[i+1] + M[g+1];
	    A = D
	    D = C
	    C = B
	    B = B + ((F << s[i+1]) | (F >> (32 - s[i+1])))
	}

	a0 = a0 + A
	b0 = b0 + B
	c0 = c0 + C
	d0 = d0 + D
    }

    digest = "ltba(ltle(a0)),ltba(ltle(b0)),ltba(ltle(c0)),ltba(ltle(d0))"

    return digest;
}


#end_if
