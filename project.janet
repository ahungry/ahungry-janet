(declare-project
 :name "com.ahungry"
 :description "Collection of unofficial Janet libraries"
 :author "Matthew Carter"
 :license "GPLv3"
 :url "https://github.com/ahungry/ahungry-janet/"
 :repo "git+https://github.com/ahungry/ahungry-janet.git"
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

#(os/shell "./get-iup-linux-files.sh")

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

(defn build-iup-linux []
  # Make sure we have appropriate include/header files etc.
  (or (and (os/stat "./deps/linux/iup")
           (os/stat "./deps/linux/im"))
      (os/shell "./get-iup-linux-files.sh"))
  (declare-native
   :name "com_ahungry_iup"
   :cflags ["-std=c99" "-Wall" "-Wextra" "-fPIC" "-I./deps/linux/iup/include"]
   :lflags ["-L./deps/linux/iup" "-l:libiup.a" "-l:libiupimglib.a"
            "-l:libiupim.a" "-L./deps/linux/im" "-l:libim.a" "-lpng16"
            "-lstdc++" "-lX11"
            # BEGIN Generated from pkg-config --libs gtk+-3.0
            "-lgtk-3" "-lgdk-3" "-lz" "-lpangocairo-1.0" "-lpango-1.0"
            "-lharfbuzz" "-latk-1.0" "-lcairo-gobject" "-lcairo" "-lgdk_pixbuf-2.0"
            "-lgio-2.0" "-lgobject-2.0" "-lglib-2.0"
            # END Generated from pkg-config
            ]
   :source @["src/iup_wrap.c"]))

(defn build-iup-stub []
  (declare-native
   :name "com_ahungry_iup"
   :clfags []
   :lflags []
   :source @["src/iup_none.c"]))

(cond
  (= "linux" ((os/environ) "IUP")) (build-iup-linux)
  :else (build-iup-stub))

(declare-source :source @["lib/com.ahungry.janet"])
(declare-source :source @["lib/com.ahungry.db.janet"])
(declare-source :source @["lib/com.ahungry.db.sqlite.janet"])
(declare-source :source @["lib/com.ahungry.gui.janet"])
(declare-source :source @["lib/com.ahungry.gui.iup.janet"])
(declare-source :source @["lib/com.ahungry.meta.janet"])
(declare-source :source @["lib/com.ahungry.net.janet"])
(declare-source :source @["lib/com.ahungry.net.client.janet"])
(declare-source :source @["lib/com.ahungry.wire.janet"])
(declare-source :source @["lib/com.ahungry.wire.json.janet"])
