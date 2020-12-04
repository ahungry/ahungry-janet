# This is sort of a scratch file that has snuck in here...
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

# Sample thing to read one line at a time
(defn lazy-reader [filename]
  (make-lazy
   (fn [{:last-bytes last-bytes :bytes bytes :fh fh}]
     (def s (file/read fh :line))
     {:last-bytes bytes :bytes (+ bytes (length (or s ""))) :s s :fh fh})
   (fn [{:last-bytes last-bytes :bytes bytes :fh fh :s s}]
     (when (and (>= bytes ((os/stat filename) :size))
                (= last-bytes bytes))
       (file/close fh)
       true))
   (fn [] {:last-bytes 0 :bytes 0 :s "" :fh (file/open filename :r)})))


# (def this-file (lazy-reader "/etc/passwd"))

# (:map this-file |(get $ :bytes))
# (:map this-file |(get $ :s))

# (:iter this-file)
# (:take-all this-file)

(defn while-lines [filename]
  (def fh (file/open filename :r))
  (while (def s (file/read fh :line))
    (pp s))
  (file/close fh))

# (while-lines "/etc/passwd")

(defn lazy-simple [f g init]
  (var next init)
  (while (def produced (g next)) (pp next) (set next (f next))))

# (lazy-simple inc |(> 10 $) 0)


(def PrependableBuffer
  @{:buf nil
    :max-size 0
    :midpoint 0
    :prepends 0
    :appends 0
    :get-buf (fn [self]
               (buffer/slice (self :buf)
                             (- (self :midpoint) (self :prepends))
                             (+ (self :midpoint) (self :appends))))
    :push-char-front (fn [self c]
                 (put self :prepends (inc (self :prepends)))
                 (put (self :buf) (- (self :midpoint) (self :prepends)) c))
    :push-char (fn [self c]
                 (put (self :buf) (+ (self :midpoint) (self :appends)) c)
                 (put self :appends (inc (self :appends))))
    :new (fn [self max-size]
           (put self :max-size max-size)
           (put self :midpoint (/ max-size 2))
           (put self :buf (buffer/new max-size)))})

(def pb (:new PrependableBuffer 20))

(:push-char pb 76) # L
(:push-char pb 76) # L
(:push-char pb 79) # O
(:push-char-front pb 69) # E
(:push-char-front pb 72) # H

(pp (:get-buf pb)) # @"HELLO"

(def pb2 (:new PrependableBuffer 20))

(def buf3 (buffer/new (+ (length buf1) (length buf2))))

(buffer/push-string buf3 (string buf1 buf2))

(defn bufcat [buf1 buf2]
  (-> (buffer/new (+ (length buf1) (length buf2)))
      (buffer/push-string (string buf1 buf2))))

(def buf1 @"hi")
(def buf2 @"bye")
(pp (bufcat buf1 buf2))
