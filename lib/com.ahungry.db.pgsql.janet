(import pq :as pgsql)

(def meta {:version "20201001"})

# TODO: Figure out a build process for windows, or if libpq isn't available, omit under windows

(def connect pgsql/connect)
(def exec pgsql/exec)
(def row pgsql/row)
(def all pgsql/all)
(def val pgsql/val)
