# (import build/com_ahungry_meta)
# (import build/com_ahungry_curl)

# (pp (com_ahungry_meta/version))

(import com_ahungry_iup :as iup)
#(import build/janet-iup :as iup)

(pp "Import success")

(defn main [& xs]
  (iup/IupOpen (iup/int-ptr) (iup/char-ptr))
  (iup/IupMessage "hi " "there")
  (iup/IupMainLoop))
