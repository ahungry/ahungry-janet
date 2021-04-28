(import com_ahungry_crypt :as crypt)

(def meta {:version "20210427"})

# (defn make [k v]
#   (pp (jwt/hmac-sha256 k v)))

# (pp (make "val" "key"))

(def hmac-sha256 crypt/hmac-sha256)
(def hmac-sha256-hex crypt/hmac-sha256-hex)
(def sha256 crypt/sha256)
(def base64-encode crypt/base64-encode)

# Need to allow a variation without padding.
(defn base64-encode-nopad [s]
  (-> (crypt/base64-encode s)
      (string/trim "=")))

# Need to be able to re-add padding on the decode whether its there or not.
(defn add-padding [s]
  (let [pad (- 4 (mod (length s) 4))
        chars (case pad 1 "=" 2 "==" 3 "===" "")]
    (string s chars)))

(def base64-decode (comp crypt/base64-decode add-padding))
