(import com.ahungry.db.pgsql :as pq)

(def conn (pq/connect "postgresql://localhost?dbname=janet"))

(pq/exec conn "create table IF NOT EXISTS users(name text, data jsonb);")
(pq/exec conn "insert into users(name, data) values($1, $2);" "ac" (pq/jsonb @{"some" "data"}))
(pq/row conn "select * from users where name = $1;" "ac")

# {:name "ac" :data @{"some" "data"}}
(def users (pq/all conn "select * from users"))

(pp users)

# [{:name "ac" :data @{"some" "data"}} ...]
(def data (pq/val conn "select data from users where name = $1;" "ac"))

(pp data)
# @{"some" "data"}
