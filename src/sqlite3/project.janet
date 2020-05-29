(declare-project
 :name "sqlite3"
 :author "Calvin Rose"
 :license "MIT"
 :url "https://github.com/ahungry/sqlite3"
 :repo "git+https://github.com/ahungry/sqlite3.git")

(declare-native
 :name "sqlite3"
 :cflags []
 :lflags ["-lsqlite3"]
 :source @["main.c"])
