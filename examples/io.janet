(import com.ahungry.io :as io)

(defn main [&]
  (pp "Get a key prior to any raw term stuff (press key, then Enter)")
  (def key1 (io/read-key))
  (pp "Press the any key to continue...")
  (def key2 (io/wait-for-key))
  (pp "Press any OTHER key to continue...")
  (var key3 key2)
  (while (= key2 key3) (set key3 (io/wait-for-key)))
  (pp "done")
  (pp "Get a key after raw term stuff (press key, then enter)")
  (def key4 (io/read-key))
  (pp (string/format "You pushed the '%c' key at first, then '%c', then '%c', and finally '%c'" key1 key2 key3 key4)))
