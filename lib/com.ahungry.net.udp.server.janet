(import com_ahungry_udp :as udp)

(def meta {:version "20200602"})

# TODO: Use the atom for managing this
(defn keep-listening? [] true)

(def listen udp/listen)

(defn listen-on-udp
  "Listen on a port for inbound traffic, process it and respond on 12345
with the processed result.

Remove file /tmp/janet.listen to break out of the listen loop."
  [port f]
  (printf "Listening on %s" (string port))
  (while (keep-listening?)
    (-> (udp/listen port) f)))
