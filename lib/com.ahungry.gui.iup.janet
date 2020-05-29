(import com_ahungry_iup :as iup)

(def meta {:version "20200528"})

(defn make-dummy [f]
  (fn dummy [& xs]
    (printf
     "com.ahungry.gui.iup/%s was called, but this not built with IUP support (hint: recompile with env IUP=linux or IUP=mingw)."
     (string f))))

(defn make-bind [f]
  (try (eval f)
       ([err] (make-dummy f))))

(def open (make-bind 'iup/IupOpen))
(def int-ptr (make-bind 'iup/int-ptr))
(def char-ptr (make-bind 'iup/char-ptr))
(def close (make-bind 'iup/IupClose))
(def main-loop (make-bind 'iup/IupMainLoop))
(def message (make-bind 'iup/IupMessage))

(defn init []
  (open (int-ptr) (char-ptr)))
