(import com_ahungry_sqlite3 :as sqlite3)

(def meta {:version "20200528"})

(def open sqlite3/open)
(def close sqlite3/close)
(def eval sqlite3/eval)
(def last-insert-rowid sqlite3/last-insert-rowid)
(def error-code sqlite3/error-code)
