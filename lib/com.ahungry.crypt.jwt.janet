(import com.ahungry.crypt :as crypt)
(import com.ahungry.wire.json :as json)

(def meta {:version "20210427"})

(defn- make-signature [secret b64-header b64-payload]
  (crypt/hmac-sha256
   secret
   (string/join [b64-header b64-payload] ".")))

(defn make [secret payload-ds]
  (def header (string (json/encode {:alg "HS256" :typ "JWT"})))
  (def payload (string (json/encode payload-ds)))
  (def b64-header (crypt/base64-encode-nopad header))
  (def b64-payload (crypt/base64-encode-nopad payload))
  (def signature (make-signature secret b64-header b64-payload))
  (def b64-signature (crypt/base64-encode-nopad signature))
  (string/join [b64-header b64-payload b64-signature] "."))

(defn verify-signature [secret jwt]
  (def parts (string/split "." jwt))
  (def b64-header (get parts 0))
  (def b64-payload (get parts 1))
  (def b64-signature (get parts 2))
  (def signature-actual (crypt/base64-decode b64-signature))
  (def signature-expected (make-signature secret b64-header b64-payload))
  (pp signature-actual)
  (pp signature-expected)
  (= signature-actual signature-expected))

(defn get-payload [jwt]
  (-> (def parts (string/split "." jwt))
      (get 1)
      crypt/base64-decode
      json/decode))
