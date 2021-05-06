(import com.ahungry.io :as io)

(defn main [&]
  (pp "Get a key prior to any raw term stuff (press key, then Enter)")
  (def key1 (io/read-key))
  (pp "Press the any key to continue...")
  (def key2 (io/wait-for-key))
  (pp "Press any OTHER key to continue...")
  (while (= key1 (io/wait-for-key)) nil)
  (pp "done")
  (pp "Get a key after raw term stuff (press key, then enter)")
  (def key3 (io/read-key))
  (pp (string/format "You pushed the '%c' key at first, then '%c', and finally '%c'" key1 key2 key3)))
