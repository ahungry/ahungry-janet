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
(defn get-mingw-cflags []
  ["-std=c99"
   "-Wall"
   "-Wextra"
   "-fPIC"
   "-shared"
   #"-static"
   "-D_WIN32_WINNT=0x0600"
   "-I./amalg"
   #(string/format "-I%s" ((os/environ) "JANET_AMALG_SOURCE_DIR"))
   ])

(defn get-mingw-lflags []
  [
   (string/format "-L%s" (or ((os/environ) "JANET_DLL_DIR") (os/cwd)))
   "-l:libjanet_dll.a"
   ])

(defn get-cflags []
  (if (= "x86_64-w64-mingw32-gcc" ((os/environ) "CC"))
    (get-mingw-cflags)
    []))

(defn get-lflags []
  (if (= "x86_64-w64-mingw32-gcc" ((os/environ) "CC"))
    (get-mingw-lflags)
    []))

(declare-native
 :name "com_ahungry_json"
 :cflags ["-std=c99" "-Wall" "-Wextra" (splice (get-cflags))]
 :lflags [(splice (get-lflags))]
 :source @["src/json/json.c"])

(declare-native
   :name "com_ahungry_meta"
   :cflags ["-std=c99" "-Wall" "-Wextra" (splice (get-cflags))]
   :lflags [(splice (get-lflags)) ]
   :source @["src/meta.c"])

(declare-native
   :name "com_ahungry_curl"
   :cflags ["-std=c99" "-Wall" "-Wextra" "-fPIC" (splice (get-cflags))]
   :lflags ["-lcurl" (splice (get-lflags))]
   :source @["src/curl_wrap_app.c"])

(declare-native
   :name "com_ahungry_sqlite3"
   :cflags ["-std=c99" "-Wall" "-Wextra" "-fPIC" (splice (get-cflags))]
   :lflags ["-lsqlite3" (splice (get-lflags))]
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

(defn build-iup-mingw []
  # Make sure we have appropriate include/header files etc.
  (or (and (os/stat "./deps/win/iup")
           (os/stat "./deps/win/im"))
      (os/shell "./get-iup-windows-files.sh"))
  #(os/setenv "CC" "x86_64-w64-mingw32-gcc")
  (declare-native
   :name "com_ahungry_iup"
   :cflags [
            "-mwindows"
            "-I./deps/win/iup/include"
            (splice (get-mingw-cflags))
            ]
   :lflags [
            "-Wl,--out-implib,libiup_dll.a"
            #"-Wl,--export-all-symbols"
            #"-Wl,--enable-auto-import"
            "-L./deps/win/iup"
            "-l:libiup.a"
            "-l:libiupim.a"
            "-l:libiup_scintilla.a"
            "-l:libfreetype6.a"
            "-l:libftgl.a"
            "-l:libiupcd.a"
            "-l:libiupcontrols.a"
            "-l:libiupgl.a"
            "-l:libiupglcontrols.a"
            "-l:libiup_mglplot.a"
            "-l:libiupole.a"
            "-l:libiup_plot.a"
            "-l:libiuptuio.a"
            "-l:libz.a"
            #"-l:libiup.a"
            "-l:libiupimglib.a"
            #"-l:libiupim.a"
            "-L./deps/win/im"
            "-l:libim.a"
            "-l:libz.a"
            "-lm"
            "-pthread"
            "-lwinmm"
            "-lws2_32"
            "-lmswsock"
            "-ladvapi32"
            #"-L/usr/x86_64-w64-mingw32/lib"
            #"-l:libmingw32.a"
            "-lopengl32"
            "-lpangowin32-1.0"
            "-lgdi32"
            "-luuid"
            "-lcomctl32"
            "-lole32"
            "-lcomdlg32"
            "-lmingw32"
            #"-lwininet"
            #"-lstdc++"
            (splice (get-mingw-lflags))
            ]
   :source @["src/iup_wrap.c"])
  (os/shell "cp build/com_ahungry_iup.so build/com_ahungry_iup.dll"))

(defn build-iup-stub []
  (declare-native
   :name "com_ahungry_iup"
   :clfags []
   :lflags []
   :source @["src/iup_none.c"]))

(cond
  (= "linux" ((os/environ) "IUP")) (build-iup-linux)
  (= "mingw" ((os/environ) "IUP")) (build-iup-mingw)
  :else (build-iup-stub))

(declare-native
  :name "pobox"
  :cflags ["-Wall" "-Wextra"]
  :lflags ["-pthread"]
  #:embedded @["pobox_lib.janet"]
  :source @["src/pobox.c"])

(declare-native
  :name "com_ahungry_crypt"
  :cflags ["-Wall" "-Wextra"]
  :lflags ["-pthread" "-lssl" "-lcrypto" (splice (get-lflags))]
  #:embedded @["pobox_lib.janet"]
  :source @["src/com_ahungry_crypt.c"])

# Original wrappers
(declare-source :source @["lib/com.ahungry.janet"])
(declare-source :source @["lib/com.ahungry.conc.atom.janet"])
(declare-source :source @["lib/com.ahungry.crypt.jwt.janet"])
(declare-source :source @["lib/com.ahungry.db.janet"])
(declare-source :source @["lib/com.ahungry.db.pgsql.janet"])
(declare-source :source @["lib/com.ahungry.db.sqlite.janet"])
(declare-source :source @["lib/com.ahungry.gfx.cairo.janet"])
(declare-source :source @["lib/com.ahungry.gui.janet"])
(declare-source :source @["lib/com.ahungry.gui.iup.janet"])
(declare-source :source @["lib/com.ahungry.gui.webview.janet"])
(declare-source :source @["lib/com.ahungry.meta.janet"])
(declare-source :source @["lib/com.ahungry.net.janet"])
(declare-source :source @["lib/com.ahungry.net.tcp.client.janet"])
(declare-source :source @["lib/com.ahungry.net.udp.client.janet"])
(declare-source :source @["lib/com.ahungry.net.udp.server.janet"])
(declare-source :source @["lib/com.ahungry.util.janet"])
(declare-source :source @["lib/com.ahungry.wire.janet"])
(declare-source :source @["lib/com.ahungry.wire.json.janet"])

(declare-native
 :name "com_ahungry_udp"
 :cflags ["-std=gnu99" "-Wall" "-Wextra"]
 :lflags ["-lm" "-ldl" "-lpthread"]
 :source @["src/udp.c"])

# Copies from other projects
(declare-source :source ["lib/pq.janet"])

(declare-native
   :name "com_ahungry_pq"
   :cflags ["-std=c99" "-Wall" "-Wextra" "-fPIC" "-I/usr/include/postgresql" (splice (get-cflags))]
   :lflags ["-lpq" (splice (get-lflags))]
   :source @["src/janet-pq/pq.c"])

# BEGIN Webview build stuff
(defn shell
  "Helper for using pkg-config"
  [str]
  (def f (file/popen str))
  (def output (file/read f :all))
  (file/close f)
  (string/replace "\n" "" output))

(def webview-def (case (os/which)
  :windows "WEBVIEW_WINAPI"
  :macos "WEBVIEW_COCOA"
  "WEBVIEW_GTK"))

(defn parts
  "Split on whitespace."
  [str]
  (peg/match
    '{:ws (set " \t\n\r\0")
      :non-ws '(some (if-not :ws 1))
      :main (any (* (any :ws) :non-ws))}
    str))

(def more-flags (case (os/which)
  # :windows "-lole32 -lcomctl32 -loleaut32 -luuid -mwindows" # flags are for mingw
  :windows []
  :macos ["-framework" "WebKit"]
  (parts
    (shell `pkg-config --cflags --libs gtk+-3.0 webkit2gtk-4.0`))))

(when (= "yes" ((os/environ) "GUI"))
  (declare-native
   #:name "webview"
   :name "com_ahungry_webview"
   :cflags [;default-cflags ;more-flags]
   :defines {webview-def true}
   :source @["src/webview/webview.c"])
  # END Webview build stuff

  (declare-native
   :name "com_ahungry_cairo"
   :cflags ["-std=gnu99" "-Wall" "-Wextra" "-I/usr/include/cairo"
            "-I/usr/include/glib-2.0" "-I/usr/lib/glib-2.0/include"
            "-I/usr/lib/libffi-3.2.1/include" "-I/usr/include/pixman-1"
            "-I/usr/include/freetype2" "-I/usr/include/libpng16"
            "-I/usr/include/harfbuzz"]
   :lflags ["-lm" "-ldl" "-lpthread" "-lcairo"]
   :source @["src/cairo_wrap.c"]))
