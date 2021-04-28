(import com.ahungry.crypt :as crypt)

(pp (crypt/hmac-sha256 "key" "val"))
(pp (crypt/hmac-sha256-hex "key" "val"))
(pp (crypt/sha256 ""))

(pp (crypt/base64-encode "hi"))
(pp (crypt/base64-encode "the quick brown fox jumps over the two story household isnt this an interesting sentence blablabla"))

(pp
 (->
  (crypt/base64-encode "the quick brown fox jumps over the two story household isnt this an interesting sentence blablabla")
  (crypt/base64-decode)))
