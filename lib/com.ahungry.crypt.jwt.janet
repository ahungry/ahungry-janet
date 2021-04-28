(import com.ahungry.crypt :as crypt)
(import com.ahungry.wire.json :as json)

(def meta {:version "20210427"})

(defn- make-signature [secret b64-header b64-payload]
  (crypt/hmac-sha256
   :sha256 secret
   (string/join [b64-header b64-payload] ".")))

(defn make [secret payload-ds]
  (def header (json/encode {:alg "HS256" :typ "JWT"}))
  (def payload (json/encode payload-ds))
  (def b64-header (janetls/base64/encode header :url-unpadded))
  (def b64-payload (janetls/base64/encode payload :url-unpadded))
  (def signature (make-signature secret b64-header b64-payload))
  (def b64-signature (janetls/base64/encode signature :url-unpadded))
  (string/join [b64-header b64-payload b64-signature] "."))

(defn verify-signature [secret jwt]
  (def parts (string/split "." jwt))
  (def b64-header (get parts 0))
  (def b64-payload (get parts 1))
  (def b64-signature (get parts 2))
  (def signature-actual (janetls/base64/decode b64-signature :url-unpadded))
  (def signature-expected (make-signature secret b64-header b64-payload))
  (= signature-actual signature-expected))

(defn get-payload [jwt]
  (-> (def parts (string/split "." jwt))
      (get 1)
      (janetls/base64/decode :url-unpadded)
      json/decode))
