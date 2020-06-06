(def Lazy
  @{:g not
    :f identity
    :applications 0
    :init nil
    :last nil
    :acc @[]
    :stop? false
    :reset (fn [self]
             (put self :applications 0)
             (put self :last (self :init))
             (put self :acc @[]))
    :-take (fn [self n]
             (if (or (>= (self :applications) n)
                     (self :stop?))
               (self :acc)
               (do
                 (array/push (self :acc) (self :last))
                 (:iter self)
                 (:-take self n))))
    :take (fn [self n]
            (:reset self)
            (:-take self n))
    :iter (fn [self]
            (def next-val ((self :f) (self :last)))
            (if ((self :g) next-val)
              (put self :stop? true)
              (do
                (put self :applications (inc (self :applications)))
                (put self :last next-val)))
            next-val)
   })

(defn make-lazy
  "Make a 'lazy' thing that calls F to generate and checks G to stop."
  [f g v]
  (table/setproto @{:f f :g g :init v :last v} Lazy))

(defn lazy-range [n]
  (make-lazy inc |(>= $ n) 0))

(def test1 (lazy-range 1e6))

(:iter test1)

(:take test1 100)
