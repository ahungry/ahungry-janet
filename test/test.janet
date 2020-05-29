(import com.ahungry            :as ahungry    :fresh t)
(import com.ahungry.meta       :as meta       :fresh t)
(import com.ahungry.net        :as net        :fresh t)
(import com.ahungry.net.client :as net.client :fresh t)
(import com.ahungry.wire       :as wire       :fresh t)
(import com.ahungry.wire.json  :as json       :fresh t)

(printf "com.ahungry: %s"            (ahungry/meta    :version))
(printf "com.ahungry.meta: %s"       (meta/meta       :version))
(printf "com.ahungry.net: %s"        (net/meta        :version))
(printf "com.ahungry.net.client: %s" (net.client/meta :version))
(printf "com.ahungry.wire: %s"       (wire/meta       :version))
(printf "com.ahungry.wire.json: %s"  (json/meta  :version))

(pp (-> (net.client/http-get "http://httpbin.org/ip") json/decode))
(pp (-> (net.client/json-get "http://httpbin.org/ip")))
