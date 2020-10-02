(import com.ahungry.wire.json :as json)
(import com.ahungry.db.sqlite :as sqlite)

(def db-name "dummy.db")

(defn create-db []
  (def db (sqlite/open db-name))
  (sqlite/eval db "create table IF NOT EXISTS users (name text, data text)")
  (sqlite/eval db "INSERT INTO users (name, data) VALUES (?, ?)"
                ["dummy" (json/encode @{"some" "data"})])
  (sqlite/close db))

(defn exec-db []
  (or (os/stat db-name)
      (create-db))
  # Open up the db
  (def db (sqlite/open db-name))
  (def r (sqlite/eval db "select data from users where name = ?" ["dummy"]))
  (sqlite/close db)
  r)

(def data (exec-db))
(pp data)
(pp (-> (get data 0) (get :data) json/decode))
