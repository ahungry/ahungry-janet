(import com.ahungry.net.server.udp :as udp)

# Just a benchmark to check how fast we can receive data
(var n 0)

(defn main [& xs]
  (while true
    (set n (inc n))
    (pp n)
    (udp/listen 12345)))
