(import pobox)

(def meta {:version "20200530"})

(defn make [k v]
  (pobox/cmake (marshal k) (marshal v)))

(defn update [k f]
  (pobox/cupdate
   (marshal k)
   (fn [x]
     (marshal (f (unmarshal x))))))

(defn get [k]
  (def maybe (pobox/cget (marshal k)))
  (if maybe
    (unmarshal maybe)
    nil))
