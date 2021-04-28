(import com_ahungry_crypt :as crypt)

(def meta {:version "20210427"})

# (defn make [k v]
#   (pp (jwt/hmac-sha256 k v)))

# (pp (make "val" "key"))

(pp (crypt/hmac-sha256 "key" "val"))
(pp (crypt/hmac-sha256-hex "key" "val"))
(pp (crypt/sha256 ""))
