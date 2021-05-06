(defn add-headers [res]
  (string/join
   ["HTTP/1.1 200 OK\n"
    "Content-Type: text/html\n"
    "Content-Length: " (string (length res)) "\n"
    "Connection: close\n\n" res] ""))

(defn main [req]
  (pp "On the server side, we see this: ")
  (pp req)
  (add-headers (string "Client gets back their req: \n" req)))
