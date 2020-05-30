(import com_ahungry_iup :as iup)

(pp "Import success")

(defn main [& xs]
  (iup/IupOpen (iup/int-ptr) (iup/char-ptr))
  (iup/IupMessage "hi " "there")
  (iup/IupMainLoop))
