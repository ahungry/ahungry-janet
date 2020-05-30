(import com.ahungry.conc.atom :as atom)
(import com.ahungry.gui.iup :as gui)

(pp "Try calling (alert)")

(atom/make :has-alerted? false)

(defn alert []
  (thread/new
   (fn [p]
     (if (atom/get :has-alerted?)
       (pp "Sorry, only one GUI main-loop per process!")
       (do
         (gui/init)
         (atom/update :has-alerted? (fn [m] true))
         (def label (gui/label "Some label here"))
         (def vbox (gui/vbox label (gui/int-ptr)))
         (def dialog
           (-> (gui/dialog vbox)
               (gui/set-attr "TITLE" "Greetings")
               (gui/set-attr "SIZE" "600x300")))
         (def button (gui/button "Close" "NULL"))
         (gui/onclick button (fn [self n]
                               (pp "Button clicked")
                               (gui/close)
                               (gui/CLOSE)))
         (gui/append vbox button)
         (gui/show-xy dialog (gui/CENTER) (gui/CENTER))
         (gui/main-loop)
         (gui/close))))))
