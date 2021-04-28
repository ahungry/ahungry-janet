(import com.ahungry.crypt :as crypt)

(pp (crypt/hmac-sha256 "key" "val"))
(pp (crypt/hmac-sha256-hex "key" "val"))
(pp (crypt/sha256 ""))
