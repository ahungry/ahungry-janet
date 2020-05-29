(import com.ahungry.gui.iup :as gui)

(defn main [& xs]
  (gui/init)
  (gui/message "My first GUI" "Greetings from the GUI")
  (gui/main-loop)
  (gui/close))
