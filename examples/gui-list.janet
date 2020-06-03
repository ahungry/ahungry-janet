(import com.ahungry.gui.iup :as gui)

# Unlike the Text listener, this will always return
# a proper value no matter what is held (alt, ctrl, etc.)
(defn bind-keys [el]
  (gui/set-thunk el "K_ANY"
                 (fn [self k]
                   (pp "Received a key from listener")
                   (pp k))))

(defn main [& xs]
  (gui/init)
  (def label (gui/label "Some label here"))
  (def vbox (gui/vbox label (gui/int-ptr)))
  (def dialog
    (-> (gui/dialog vbox)
        (gui/set-attr "TITLE" "Greetings")
        (gui/set-attr "SIZE" "600x300")))
  (def button (gui/button "Close" "NULL"))
  (gui/set-action button (fn [self n] (gui/CLOSE)))
  (gui/append vbox button)

  (def list (gui/list "NULL"))
  (map (fn [n] (gui/set-attr list (string (inc n)) (string "Item " n)))
       (range 50))
  (gui/set-attrs list {:1 "Foo" :2 "Bar" :size "200x200"
                       #:dropdown :yes
                       #:multiple :yes
                       })
  (gui/set-action list
                  (fn [self n]
                    (printf "List item chosen: %s %s"
                            (string (gui/get-attr-s self "VALUE")) (string n))))

  # Not working...
  # (gui/set-thunk list "DBLCLICK_CB"
  #                (fn [self n]
  #                  (pp "Double clicked hte thing..")))

  (gui/append vbox list)

  (bind-keys vbox)
  (gui/show-xy dialog (gui/CENTER) (gui/CENTER))
  (gui/main-loop)
  (gui/close))
