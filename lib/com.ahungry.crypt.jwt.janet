(import com_ahungry_crypt_jwt :as jwt)

(def meta {:version "20210427"})

# (defn make [k v]
#   (pp (jwt/hmac-sha256 k v)))

# (pp (make "val" "key"))

#(pp (jwt/hmac-sha256 "val" "key"))
(pp (jwt/hmac-sha256-hex "key" "val"))
