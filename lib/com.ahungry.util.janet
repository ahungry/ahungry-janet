(def Lazy
  @{:g (fn [] nil)
    :f (fn [] nil)
    :init (fn [] nil)
    :applications 0
    :last nil
    :stop? false
    :iter (fn [self]
            (def next-val
              (if (= 0 (self :applications))
                ((self :init))
                ((self :f) (self :last))))
            (if ((self :g) next-val)
              (do
                (put self :stop? true)
                (self :last))
              (do
                (put self :applications (inc (self :applications)))
                (put self :last next-val)
                next-val)))
    :reset (fn [self]
             (put self :stop? false)
             (put self :applications 0)
             (put self :last (self :init)))
    :take (fn [self n]
            (:reset self)
            (var next nil)
            (def acc @[])
            (while (and (not (self :stop?))
                        (> n (self :applications)))
              (set next (:iter self))
              (when (not (self :stop?)) (array/push acc next)))
            acc)
    :take-all (fn [self] (:take self math/inf))
    :reduce (fn [self f init]
              (:reset self)
              (var next nil)
              (var acc init)
              (while (not (self :stop?))
                (set next (:iter self))
                (when (not (self :stop?)) (set acc (f acc next))))
              acc)
    :map (fn [self f] (:reduce self (fn [acc x] [;acc (f x)]) []))
   })

(defn make-lazy
  "Make a 'lazy' thing that calls F to generate and checks G to stop."
  [f g h]
  (table/setproto @{:f f :g g :init h} Lazy))

(defn lazy-range [n]
  (make-lazy inc |(>= $ n) (fn [] 0)))

# (def test1 (lazy-range 3))

# (:iter test1)
# (:take test1 1)
# (:take-all test1)
# (:reduce (lazy-range 10) + 1)
# (:map test1 (fn [n] (+ 1 n)))
