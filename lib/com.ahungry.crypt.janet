(import com_ahungry_crypt :as crypt)

(def meta {:version "20210427"})

# (defn make [k v]
#   (pp (jwt/hmac-sha256 k v)))

# (pp (make "val" "key"))

(def hmac-sha256 crypt/hmac-sha256)
(def hmac-sha256-hex crypt/hmac-sha256-hex)
(def sha256 crypt/sha256)
(def base64-encode crypt/base64-encode)
(def base64-decode crypt/base64-decode)
