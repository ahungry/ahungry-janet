# Ahungry Janet

Ahungry Library for Janet

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Ahungry Janet](#ahungry-janet)
- [Features](#features)
    - [com.ahungry.db](#comahungrydb)
    - [com.ahungry.gui](#comahungrygui)
    - [com.ahungry.net](#comahungrynet)
    - [com.ahungry.wire](#comahungrywire)
- [Samples](#samples)
- [License](#license)

<!-- markdown-toc end -->

# Features

## com.ahungry.db

Database abstractions around sqlite3 and postgresql + mysql/mariadb soon.

## com.ahungry.gui

GUI abstractions around IUP and possibly others (soon).

## com.ahungry.net

Network abstractions around curl and native janet net/ + servers TBD

## com.ahungry.wire

Wire protocols and serialization around JSON and YAML/TOML/JDN soon.

# Samples

Making a curl call to http bin:

```clojure
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

# License

All linked/included works that are not my own are subject to their
original licenses (the majority are MIT).

You can find the original sources on the associated links above.

All original works are copyright Matthew Carter <m@ahungry.com> and
licensed under GPLv3.

If you make a derivative work, you need to adhere to the license here
(as well as those in the dependencies, which may be GPLv2 in the case
of the mongoose/circlet stuff).
