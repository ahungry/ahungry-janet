(import com.ahungry.net.tcp.server :as server)

# TODO: Better path resolution logic for server start handlers.
(defn main [&]
  (server/start "./examples/webserver-handler" "12345"))
