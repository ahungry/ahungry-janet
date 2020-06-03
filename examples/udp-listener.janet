(import com.ahungry.net.udp.server :as udp)

# Just a benchmark to check how fast we can receive data
(var n 0)

(defn main [& xs]
  (while true
    (set n (inc n))
    (pp n)
    (pp
     (udp/listen 12345))))
