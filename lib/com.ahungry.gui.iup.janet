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

(def CENTER        (make-bind 'iup/const-IUP-CENTER))
(def CLOSE         (make-bind 'iup/const-IUP-CLOSE))
(def IGNORE        (make-bind 'iup/const-IUP-IGNORE))
(def open          (make-bind 'iup/IupOpen))
(def int-ptr       (make-bind 'iup/int-ptr))
(def char-ptr      (make-bind 'iup/char-ptr))
(def close         (make-bind 'iup/IupClose))
(def main-loop     (make-bind 'iup/IupMainLoop))
(def message       (make-bind 'iup/IupMessage))
(def get-attr      (make-bind 'iup/IupGetAttribute))
(def get-attr-s    (make-bind 'iup/IupGetAttributeAsString))
(def set-attribute (make-bind 'iup/IupSetAttribute))
(def set-handle    (make-bind 'iup/IupSetAttributeHandle))
(def set-handle-s  (make-bind 'iup/IupSetAttributeHandleAsString))
(def show-xy       (make-bind 'iup/IupShowXY))
(def append        (make-bind 'iup/IupAppend))
(def vbox          (make-bind 'iup/IupVbox))
(def dialog        (make-bind 'iup/IupDialog))
(def label         (make-bind 'iup/IupLabel))
(def button        (make-bind 'iup/IupButton))
(def text          (make-bind 'iup/IupText))
(def user          (make-bind 'iup/IupUser))
(def set-thunk     (make-bind 'iup/iup-set-thunk-callback))
(def redraw        (make-bind 'iup/IupRedraw))
(def update        (make-bind 'iup/IupUpdate))

(def  KEY_UP     65362)
(def  KEY_DOWN   65364)
(def  KEY_LEFT   65361)
(def  KEY_RIGHT  65363)
(def  KEY_O      111)
(def  KEY_I      105)
(def  KEY_J      106)
(def  KEY_K      107)
(def  KEY_H      104)
(def  KEY_L      108)

(defn set-attr [x k v]
  (set-attribute x k v) x)

(defn set-attr-handle [x k v]
  (set-handle x k v) x)

(defn set-attr-handle-s [x k v]
  (set-handle-s x k v) x)

(defn set-label [label s]
  (set-attr label "TITLE" s) label)

(defn kw->upper [k]
  (if (keyword? k)
      (string/ascii-upper (string k))
    k))

(defn set-attrs [ih m]
  (map (fn [k]
         (set-attr ih (kw->upper k) (kw->upper (get m k))))
       (keys m))
  ih)

(defn init []
  (open (int-ptr) (char-ptr)))

(defn set-action [el f]
  (set-thunk el "ACTION" f))
