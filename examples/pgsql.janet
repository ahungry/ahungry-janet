(import com.ahungry.db.pgsql :as pgsql)

(def conn (pgsql/connect "postgresql://localhost?dbname=janet"))

(pgsql/exec conn "create table IF NOT EXISTS users (name text, data jsonb);")
(pgsql/exec conn "insert into users(name, data) values($1, $2);" "dummy" (pgsql/jsonb @{"some" "data"}))
(pgsql/row conn "select * from users where name = $1;" "dummy")

# {:name "ac" :data @{"some" "data"}}
(def users (pgsql/all conn "select * from users"))

(pp users)

# [{:name "ac" :data @{"some" "data"}} ...]
(def data (pgsql/val conn "select data from users where name = $1;" "ac"))

(pp data)
# @{"some" "data"}
