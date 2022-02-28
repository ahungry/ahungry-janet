(import /lib/com.ahungry.net.tcp.server :as s)
(import /lib/com.ahungry.wire.json :as json)

(defn version [_] "1.2.3")
(def default-response
  "Non-json body content, so Hello World! (try passing in object with 'a' and 'b' keys)")

(defn router [{:method method :url url}]
  (cond
    (string/find "/version/" url) (version method)
    default-response))

(defn -main
  "The make-fn in the package will ensure it is a parsed response,
and add the necessary response headers - all we have to do here
is respond with some string."
  [{:body body :headers headers :method method :url url}]
  (pp {:url url :method method :body body})
  (try
    (do
      (def json (json/decode body))
      (pp json)
      (def a (get json "a"))
      (def b (get json "b"))
      (json/encode {:a a :b b :c (+ a b)}))
    ([err]
     (pp err)
     (router {:method method :url url}))))

(def main (s/make-fn -main))
