(import com_ahungry_punyserver :as ps)

(def meta {:version "20220228"})

# Sample http requests
(comment
 (def sample-req "GET / HTTP/1.1\r\nHost: 127.0.0.1:12345\r\nAccept: */*\r\nAccept-Encoding: gzip, deflate\r\nUser-Agent: Mozilla/5.0 (pc-x86_64-linux-gnu) Siege/4.1.1\r\nConnection: close\r\n\r\n")

 (def sample-req-2 "GET /version/ HTTP/1.1\r\nHost: localhost:12345\r\nUser-Agent: curl/7.81.0\r\nAccept: */*\r\n\r\n")

 (def sample-req-3 "POST /version/ HTTP/1.1\r\nHost: localhost:12345\r\nUser-Agent: curl/7.81.0\r\nAccept: */*\r\nAuthorization: Bearer myjwt\r\nContent-Length: 8\r\nContent-Type: application/x-www-form-urlencoded\r\n\r\n{\"x\": 1}"))

(defn parse-method-url
  "Sample input string: POST /version/ HTTP/1.1"
  [s]
  (def xs (string/split " " s))
  {:method (first xs)
   :url (get xs 1)})

(defn parse-req-headers
  "Take an array of strings, each of form 'Header: value' and return a map."
  [xs]
  (def m @{})
  (each x xs
    (def ds (string/split ": " x))
    (put m (keyword (string/ascii-lower (first ds))) (last ds)))
  m)

(defn parse-req
  "Given a request string, parse it."
  [req]
  (def xs (string/split "\r\n" req))
  (def headers (array/slice xs 1 (- (length xs) 2)))
  (def method-url (parse-method-url (first xs)))
  {:headers (parse-req-headers headers)
   :method (method-url :method)
   :url (method-url :url)
   :body (last xs)})

(defn add-headers [res]
  (string/join
   ["HTTP/1.1 200 OK\n"
    "Content-Type: text/html\n"
    "Content-Length: " (string (length res)) "\n"
    "Connection: close\n\n" res] ""))

# TODO: Allow user to set additional headers on the response object.
(defn make-fn
  "Take a user provided function, that will have the remote REQ applied to it."
  [f]
  (fn [request]
    (def req (parse-req request))
    (def res (f req))
    (add-headers res)))

(defn start
  ```
Point to a janet HANDLER-FILE that will receive a req, and
a PORT to listen on.

A sample handler may look like:

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
```
  [handler-file port]
  (ps/start handler-file (string port)))
