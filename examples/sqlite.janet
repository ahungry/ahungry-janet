(import com.ahungry.wire.json :as json)
(import com.ahungry.db.sqlite :as sqlite3)

(def db-name "dummy.db")

(defn create-db []
  (def db (sqlite3/open db-name))
  (sqlite3/eval db "create table IF NOT EXISTS users (name text, data text)")
  (sqlite3/eval db "INSERT INTO users (name, data) VALUES (?, ?)"
                ["dummy" (json/encode @{"some" "data"})])
  (sqlite3/close db))

(defn exec-db []
  (or (os/stat db-name)
      (create-db))
  # Open up the db
  (def db (sqlite3/open db-name))
  (def r (sqlite3/eval db "select data from users where name = ?" ["dummy"]))
  (sqlite3/close db)
  r)

(def data (exec-db))
(pp data)
(pp (-> (get data 0) (get :data) json/decode))
