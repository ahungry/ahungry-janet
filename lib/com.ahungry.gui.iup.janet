(use com_ahungry_iup)

(def meta {:version "20200528"})

(defn init []
  (IupOpen (int-ptr) (char-ptr)))

(def close IupClose)
(def main-loop IupMainLoop)
(def message IupMessage)
