(declare-project
 :name "com.ahungry"
 :description "Collection of unofficial Janet libraries"
 :author "Matthew Carter"
 :license "GPLv3"
 :url "https://github.com/ahungry/ahungry-janet/"
 :repo "git+https://github.com/ahungry/xbuild.git"
 # Optional urls to git repositories that contain required artifacts.
 # :dependencies
 # [
 #  {
 #   :repo
 #   "https://github.com/ahungry/janet-xbuild.git"
 #   :tag
 #   "38e4702c57f78d48c301bc1f390a6856c8011374"
 #   }]
 )

(declare-native
   :name "com_ahungry_json"
   :cflags ["-std=c99" "-Wall" "-Wextra"]
   :lflags []
   :source @["src/json/json.c"])

(declare-native
   :name "com_ahungry_meta"
   :cflags ["-std=c99" "-Wall" "-Wextra"]
   :lflags []
   :source @["src/meta.c"])

(declare-native
   :name "com_ahungry_curl"
   :cflags ["-std=c99" "-Wall" "-Wextra" "-fPIC"]
   :lflags ["-lcurl"]
   :source @["src/curl_wrap_app.c"])

(declare-native
   :name "com_ahungry_sqlite3"
   :cflags ["-std=c99" "-Wall" "-Wextra" "-fPIC"]
   :lflags ["-lsqlite3"]
   :source @["src/sqlite3/main.c"])

(declare-source :source @["lib/com.ahungry.janet"])
(declare-source :source @["lib/com.ahungry.db.janet"])
(declare-source :source @["lib/com.ahungry.db.sqlite.janet"])
(declare-source :source @["lib/com.ahungry.meta.janet"])
(declare-source :source @["lib/com.ahungry.net.janet"])
(declare-source :source @["lib/com.ahungry.net.client.janet"])
(declare-source :source @["lib/com.ahungry.wire.janet"])
(declare-source :source @["lib/com.ahungry.wire.json.janet"])
