# amx-util-library

---

#### The amx-util-library contains various NetLinx include files and modules built to make it easier to perform numerous useful operations which might otherwise be onerous if the amx-util-library did not exist.

All files are located in the one directory. This is due to the limitations of the NetLinx compiler in that the compiler cannot find a file that is in a sub-directory unless either that file or another file in the same sub-directory is referenced by the system.

All include files within the amx-util-library are fully commented to make them as easy as possible to use without having to refer to outside documentation.

Similar to the RMS SDK distributed by AMX many of the include files within the amx-util-library have dependencies of; or are dependencies for; other files within the amx-util-library. These dependencies are outlined as follows:

---

#### `base64.axi`

Functions relating to the Base64 encoding scheme.

Usage:
```
#include 'base64'
```
Dependencies:
* none

---

#### `binary.axi`

Functions for converting between "typical" data and ASCII strings containing binary representations of the data values.

Usage:
```
#include 'binary'
```
Dependencies:
* none

---

#### `cipher.axi`

**[Not yet implemented]**

All cryptography libraries relating to encryption/decryption.

Usage:
```
#include 'cipher'
```
Dependencies:
* none

---

#### `codec.axi`

All cryptography libraries relating to encoding/decoding.

Usage:
```
#include 'codec'
```
Dependencies:
* `base64.axi`

---

#### `convert.axi`

Functions for converting between different datatypes or formats.

Usage:
```
#insert 'convert'
```
Dependencies:
* none

---

#### `crypto.axi`

All cryptography libraries.

Usage:
```
#include 'crypto'
```
Dependencies:
* `cipher.axi`
* `codec.axi`
* `hash.axi`

---

#### `date-time.axi`

Functions relating to date/time.

Usage:
```
#include 'date-time'
```
Dependencies:
* none

---

#### `debug.axi`

Functions assisting with debugging.

Usage:
```
#include 'debug.axi'
```
Dependencies:
* `debug.axi`

---

#### `dictionary.axi`

Functions for storing/retrieving data in/from key-value pairs.

Usage:
```
#insert 'dictionary'
```
Dependencies:
* none

---

#### `hash.axi`

All cryptography libraries relating to hashing algorithms.

Usage:
```
#include 'hash'
```
Dependencies:
* `md5.axi`
* `sha1.axi`
* `sha256.axi`

---

#### `http.axi`

Functions to assist with building/parsing HTTP requests/responses.

Usage:
```
#include 'http'
```
Dependencies:
* `base64.axi`
* `md5.axi`
* `uri.axi`

---

#### `hmac.axi`

Function to compute HMAC.

Usage:
```
#include 'hmac'
```
Dependencies:
* `md5.axi`
* `sha1.axi`
* `sha256.axi`

---

#### `json.axi`

Functions to assist with building/parsing JSON strings.

Usage:
```
#include 'json'
```
Dependencies:
* `string.axi`

---

#### `json-rpc.axi`

Functions to assist with building JSON-RPC strings.

Usage:
```
#include 'json-rpc'
```
Dependencies:
* `json.axi`

---

#### `jwt.axi`

Function to assist with building JSON Web Tokens (JWT)

Usage:
```
#include 'jwt'
```
Dependencies:
* `json.axi`
* `base64.axi`
* `hmac.axi`

---

#### `math.axi`

**[Not yet implemented]**

Functions for various mathematical algorithms.

Usage:
```
#include 'math.axi'
```
Dependencies:
* none

---

#### `proto.axi`

All protocol libraries.

Usage:
```
#include 'proto'
```
Dependencies:
* `http.axi`
* `json.axi`
* `uri.axi`
* `websockets.axi`
* `xml.axi`

---

#### `sha1.axi`

Functions relating to the SHA-1 hashing algorithm.

Usage:
```
#include 'sha1'
```
Dependencies:
* `binary.axi`
* `convert.axi`
* `string.axi`

---

#### `sha256.axi`

Functions relating to the SHA-256 hashing algorithm.

Usage:
```
#include 'sha256'
```
Dependencies:
* `binary.axi`
* `convert.axi`
* `string.axi`

---

#### `string.axi`

Functions extending the built-in string manipulation functions.

Usage:
```
#include 'string'
```
Dependencies:
* none

---

#### `uri.axi`

Functions to assist with building/parsing a URI.

Usage:
```
#include 'uri'
```
Dependencies:
* `string.axi`

---

#### `websockets.axi`

Functions to assist with building/parsing WebSockets frames and manage multiple WebSocket connections.

Usage:
```
#include 'websockets'
```
Dependencies:
* `convert.axi`
* `crypto.axi`
* `debug.axi`
* `http.axi`
* `string.axi`

---

#### `xml.axi`

Functions to assist with building/parsing XML strings.

Usage:
```
#include 'xml'
```
Dependencies:
* `string.axi`

---
