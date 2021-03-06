(import com.ahungry.wire.json :as json)

(use com_ahungry_curl)

(def meta {:version "20200528"})

(defn json-get
  "Make a `GET` JSON request to a remote endpoint."
  [host]
  # Make the new curl instance
  (def ch (curl-easy-init))

  # Build the headers we need
  (def headers
    (-> (new-curl-slist-null)
        (curl-slist-append "Content-Type: application/json")
        (curl-slist-append "Accept:") # Take any response
        ))

  # Add them to our instance
  (curl-easy-setopt-pointer ch (const-CURLOPT-HTTPHEADER) headers)

  # We really don't need to verify peer for this
  # FIXME: This does not work on Windows, see:
  # https://curl.haxx.se/mail/lib-2013-03/0013.html
  # It would work ok on most GNU/Linux - may need to expose this
  # setting to Windows users and suggest they do not call endpoint that
  # could be MITM'ed (such as a locally run proxy in front of remote they need)
  (curl-easy-setopt ch (const-CURLOPT-SSL-VERIFYHOST) 0)
  (curl-easy-setopt ch (const-CURLOPT-SSL-VERIFYPEER) 0)

  # Set the remote url and follow redirects
  (curl-easy-setopt-string ch (const-CURLOPT-URL) host)
  (curl-easy-setopt ch (const-CURLOPT-FOLLOWLOCATION) 1)

  # Ensure we have a way to pull out the response
  (def buf (curl-make-buffer))
  (curl-easy-setopt-pointer ch (const-CURLOPT-WRITEFUNCTION) (curl-dummy-callback))
  (curl-easy-setopt-pointer ch (const-CURLOPT-WRITEDATA) buf)

  (def res-status (curl-easy-perform ch))
  (def res (curl-get-buffer-content buf))

  # And clean up our curl handle and heades
  (curl-easy-cleanup ch)
  (curl-slist-free-all headers)

  (free buf)
  (json/decode res))

(defn http-get
  "Make a `GET` HTTP request to a remote endpoint."
  [host]
  # Make the new curl instance
  (def ch (curl-easy-init))

  # Build the headers we need
  (def headers
       (-> (new-curl-slist-null)
           (curl-slist-append "Accept:") # Take any response
           ))

  # Add them to our instance
  (curl-easy-setopt-pointer ch (const-CURLOPT-HTTPHEADER) headers)

  # We really don't need to verify peer for this
  (curl-easy-setopt ch (const-CURLOPT-SSL-VERIFYHOST) 0)
  (curl-easy-setopt ch (const-CURLOPT-SSL-VERIFYPEER) 0)

  # Set the remote url and follow redirects
  (curl-easy-setopt-string ch (const-CURLOPT-URL) host)
  (curl-easy-setopt ch (const-CURLOPT-FOLLOWLOCATION) 1)

  # Ensure we have a way to pull out the response
  (def buf (curl-make-buffer))
  (curl-easy-setopt-pointer ch (const-CURLOPT-WRITEFUNCTION) (curl-dummy-callback))
  (curl-easy-setopt-pointer ch (const-CURLOPT-WRITEDATA) buf)

  (def res-status (curl-easy-perform ch))
  (def res (curl-get-buffer-content buf))

  # And clean up our curl handle and heades
  (curl-easy-cleanup ch)
  (curl-slist-free-all headers)

  (free buf)
  res)
