(import com.ahungry.net.tcp.client :as client :fresh true)

(defn get-ip []
  (client/json-get "https://httpbin.org/ip"))

(pp (get-ip))
