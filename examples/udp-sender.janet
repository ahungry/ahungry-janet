(import com.ahungry.net.udp.client :as udp.client)

(defn main [& xs]
  (udp.client/send "127.0.0.1" 12345 "Hello World"))
