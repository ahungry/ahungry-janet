(import com.ahungry.gui.iup :as gui)

(defn main [& xs]
  (gui/init)
  (def label (gui/label "Some label here"))
  (def vbox (gui/vbox label (gui/int-ptr)))
  (def dialog
    (-> (gui/dialog vbox)
        (gui/set-attr "TITLE" "Greetings")
        (gui/set-attr "SIZE" "600x300")))
  (def button (gui/button "Close" "NULL"))
  (gui/set-action button (fn [self n]
                        (pp "Button clicked")
                        (gui/CLOSE)))
  (gui/append vbox button)
  (def text (gui/set-attrs (gui/text "NULL")
                           {:multiline :yes
                            :expand :yes
                            :formatting "YES"
                            :linespacing "DOUBLE"
                            #:bgcolor "10 10 20"
                            #:fgcolor "55 135 255"
                            :font "MONOSPACE"}))
  (gui/set-action text (fn [self x]
                         (pp "Text input ascii was")
                         (pp x)
                         (gui/set-attr self "VALUE" "Something in cb")
                         (gui/IGNORE)))
  (gui/set-attr text "VALUE"
                (-> (slurp "examples/gui-syntax-hl.janet") string))
  # https://webserver2.tecgraf.puc-rio.br/iup/en/attrib/iup_formatting.html
  (def format (-> (gui/user)
                  #(gui/set-attr "ALIGNMENT" "CENTER")
                  (gui/set-attr "BGCOLOR" "255 128 64")
                  (gui/set-attr "FGCOLOR" "255 255 0")
                  #(gui/set-attr "FONTSIZE" "44")
                  (gui/set-attr "SELECTION" "1,1:30,55")
                  #(gui/set-attr "SELECTIONPOS" "1,1:30,55")
                  ))
  (gui/set-attr format "SELECTION" "1,1:1,5")
  (gui/set-attr text "FORMATTING" "YES")
  (gui/set-attr-handle-s text "ADDFORMATTAG_HANDLE" format)
  (def format2 (-> (gui/user)
                   (gui/set-attr "FGCOLOR" "0 255 0")
                   (gui/set-attr "SELECTION" "3,1:3,20")))
  (gui/set-attr-handle-s text "ADDFORMATTAG_HANDLE" format2)
  (gui/append vbox text)
  (gui/show-xy dialog (gui/CENTER) (gui/CENTER))
  (gui/main-loop)
  (gui/close))
