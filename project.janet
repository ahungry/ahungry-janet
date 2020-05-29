(declare-project
 :name "com.ahungry"
 :description "Collection of unofficial Janet libraries"
 :author "Matthew Carter"
 :license "MIT"
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
   :name "com_ahungry_meta"
   :cflags ["-I./" "-std=c99" "-Wall" "-Wextra"]
   :lflags []
   :source @["src/meta.c"])

(declare-source :source @["lib/com.ahungry.janet"])
(declare-source :source @["lib/com.ahungry.meta.janet"])
(declare-source :source @["lib/com.ahungry.net.janet"])
(declare-source :source @["lib/com.ahungry.net.client.janet"])
