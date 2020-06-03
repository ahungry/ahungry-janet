# Ahungry Janet

Cross platform tested library of code to use with Janet and make it
easier to quickly develop a variety of apps.

If you need something more specific (a small GUI like Puny GUI, or
perhaps a web framework like Joy) you can view options at
https://github.com/ahungry/awesome-janet

This set of files should be installable using the jpm (Janet Package
manager) on GNU/Linux, or can also be leveraged as a starting point
for a new project by forking this repository (perhaps easier if
targetting Windows, as the mingw building goes through make, not jpm
at the moment).

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Ahungry Janet](#ahungry-janet)
- [Why?](#why)
- [Installation](#installation)
- [Features](#features)
    - [com.ahungry.conc](#comahungryconc)
        - [com.ahungry.conc.atom](#comahungryconcatom)
    - [com.ahungry.db](#comahungrydb)
        - [com.ahungry.db.sqlite](#comahungrydbsqlite)
    - [com.ahungry.gui](#comahungrygui)
        - [com.ahungry.gui.iup](#comahungryguiiup)
        - [com.ahungry.gui.webview](#comahungryguiwebview)
    - [com.ahungry.net](#comahungrynet)
        - [com.ahungry.net.tcp.client](#comahungrynettcpclient)
        - [com.ahungry.net.udp.client](#comahungrynetudpclient)
        - [com.ahungry.net.udp.server](#comahungrynetudpserver)
    - [com.ahungry.wire](#comahungrywire)
        - [com.ahungry.wire.json](#comahungrywirejson)
- [Samples](#samples)
- [License](#license)

<!-- markdown-toc end -->

# Why?

As I come across useful Janet packages, I'd like to keep them
centralized and more clearly organized (I think the javaesque naming
convention is better here - I'd rather search for
com.ahungry.net.tcp.client rather than blazbluzster when in need of an
HTTP client library), so I don't have to hunt down the same couple
packages I use over and over as I make new projects.

However, this goes beyond a simple aggregation repository of other
packages - I am "snapshotting" the dependencies as part of this
repository, to avoid playing catch-up in perpetuity, and having a
scattered coupling of community packages.

Obviously this has the potential to mean certain packages become out
of date over time, but I'd rather pull those changes in manually
(refreshing the incorporated code) after I have tested it, rather than
having code updated opaquely from under me.

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

Incorporated from: https://github.com/ahungry/janet-pobox

## com.ahungry.db

Database abstractions around sqlite3 and postgresql + mysql/mariadb soon.

### com.ahungry.db.sqlite

Integration of https://github.com/janet-lang/sqlite3 with some common
abstractions to come.

Incorporated from: https://github.com/janet-lang/sqlite3

## com.ahungry.gui

Optionally installable GUI abstractions around IUP and possibly others (soon).

### com.ahungry.gui.iup

Features more Janet like abstractions over the C wrapper.

### com.ahungry.gui.webview

Embedded webview to run an Electron like app (or whatever else is
useful for a local web browser).  Challenging at the moment to build a
web browser out of it, as it lacks the IUP gui features...

Incorporated from: https://github.com/janet-lang/webview

## com.ahungry.net

Network abstractions around curl and native janet net/ + servers TBD

### com.ahungry.net.tcp.client

Full-featured HTTP(s) client backed by libcurl.

### com.ahungry.net.udp.client

Useful to send strings over UDP for IPC.

### com.ahungry.net.udp.server

Useful to receive strings over UDP for IPC.

At the moment does not provide a way to send back to the sender like a
web server - the UDP should be directional in a way that receives
incoming messages in one way, and sends outgoing in another, without
any direct coupling between the two, or where the message came from
(fire and forget).

## com.ahungry.wire

Wire protocols and serialization around JSON and YAML/TOML/JDN soon.

### com.ahungry.wire.json

Integration of https://github.com/janet-lang/json for JSON encoding/decoding.

Incorporated from: https://github.com/janet-lang/json

# Samples

Making a curl call to http bin:

```clojure
(import com.ahungry.net.tcp.client :as net.client)

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
