(import com.ahungry.gfx.cairo :as cairo)

(def width 300)
(def height 300)

(def fmt (cairo/const-FORMAT-ARGB32))
(def surface (cairo/image-surface-create fmt width height))
(def ctx (cairo/create surface))

(pp ctx)

(cairo/set-line-width ctx 9)
(cairo/set-source-rgb ctx 0.69 0.19 0)
(cairo/translate ctx (/ width 2) (/ height 2))
(cairo/arc ctx 0 0 100 0 (* 2 3.1418))
(cairo/stroke-preserve ctx)
(cairo/fill ctx)

(cairo/surface-write-to-png surface "/tmp/swig-worked.png")
(pp "Worked?")
