# Ahungry Janet

Library of code to use with Janet and make it easier to quickly
develop a variety of apps.

If you need something more specific (a small GUI like Puny GUI, or
perhaps a web framework like Joy) you can view options at
https://github.com/ahungry/awesome-janet

This set of files should be installable using the jpm (Janet Package
manager) or can also be leveraged as a starting point for a new
project by forking this repository.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Ahungry Janet](#ahungry-janet)
- [Installation](#installation)
- [Features](#features)
    - [com.ahungry.conc](#comahungryconc)
        - [com.ahungry.conc.atom](#comahungryconcatom)
    - [com.ahungry.db](#comahungrydb)
        - [com.ahungry.db.sqlite](#comahungrydbsqlite)
    - [com.ahungry.gui](#comahungrygui)
        - [com.ahungry.gui.iup](#comahungryguiiup)
    - [com.ahungry.net](#comahungrynet)
        - [com.ahungry.net.client](#comahungrynetclient)
    - [com.ahungry.wire](#comahungrywire)
        - [com.ahungry.wire.json](#comahungrywirejson)
- [Samples](#samples)
- [License](#license)

<!-- markdown-toc end -->

# Installation

You can install as a janet dependency (only tested as such in
GNU/Linux) by adding to your project.janet file as such:

```clojure
 :dependencies
 [{:repo "https://github.com/ahungry/ahungry-janet.git"}]

```

and then running:

```sh
JANET_PATH=./deps IUP=linux jpm deps
```

Leave off JANET_PATH to install globally and/or leave IUP unset or
IUP=none to avoid having it install the IUP files.

# Features

## com.ahungry.conc

Concurrency features (including pobox integration for Clojure like atoms)

### com.ahungry.conc.atom

Clojure like atoms for sharing state among Janet threads (usually
restricted to message passing only).

## com.ahungry.db

Database abstractions around sqlite3 and postgresql + mysql/mariadb soon.

### com.ahungry.db.sqlite

Integration of https://github.com/janet-lang/sqlite3 with some common
abstractions to come.

## com.ahungry.gui

Optionally installable GUI abstractions around IUP and possibly others (soon).

### com.ahungry.gui.iup

Features more Janet like abstractions over the C wrapper.

## com.ahungry.net

Network abstractions around curl and native janet net/ + servers TBD

### com.ahungry.net.client

Full-featured HTTP(s) client backed by libcurl.

## com.ahungry.wire

Wire protocols and serialization around JSON and YAML/TOML/JDN soon.

### com.ahungry.wire.json

Integration of https://github.com/janet-lang/json for JSON encoding/decoding.

# Samples

Making a curl call to http bin:

```clojure
(import com.ahungry.net.client :as net.client)

# This
(pp (-> (net.client/http-get "http://httpbin.org/ip") json/decode))

# Or this
(pp (-> (net.client/json-get "http://httpbin.org/ip")))
```

Showing a GUI pop up:

```clojure
(import com.ahungry.gui.iup :as gui)

(defn main [& xs]
  (gui/init)
  (gui/message "My first GUI" "Greetings from the GUI")
  (gui/main-loop)
  (gui/close))

```

Showing a GUI and ensuring only one per process:
```clojure
(import com.ahungry.conc.atom :as atom)
(import com.ahungry.gui.iup :as gui)

(pp "Try calling (alert)")

(atom/make :has-alerted? false)

(defn alert []
  (thread/new
   (fn [p]
     (if (atom/get :has-alerted?)
       (pp "Sorry, only one GUI main-loop per process!")
       (do
         (gui/init)
         (atom/update :has-alerted? (fn [m] true))
         (def label (gui/label "Some label here"))
         (def vbox (gui/vbox label (gui/int-ptr)))
         (def dialog
           (-> (gui/dialog vbox)
               (gui/set-attr "TITLE" "Greetings")
               (gui/set-attr "SIZE" "600x300")))
         (def button (gui/button "Close" "NULL"))
         (gui/set-action button (fn [self n]
                               (pp "Button clicked")
                               (gui/close)
                               (gui/CLOSE)))
         (gui/append vbox button)
         (gui/show-xy dialog (gui/CENTER) (gui/CENTER))
         (gui/main-loop)
         (gui/close))))))

```

# License

All linked/included works that are not my own are subject to their
original licenses (the majority are MIT).

You can find the original sources on the associated links above.

All original works are copyright Matthew Carter <m@ahungry.com> and
licensed under GPLv3.

If you make a derivative work, you need to adhere to the license here
(as well as those in the dependencies, which may be GPLv2 in the case
of the mongoose/circlet stuff).
