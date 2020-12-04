# Similar to JPM for inlining embedded bytes
# Necessary if we want to use embedded bytes on Windows to pre-generate the file

# diff <(janet bytes-to-embedded-c.janet pobox_lib ~/src/janet-pobox/pobox_lib.janet) ~/src/janet-pobox/build/pobox_lib.janet.c

(defn embed-janet [name bytes]
  (def chunks (seq [b :in bytes] (string b)))
  (print (string
          "#include <janet.h>\n"
          "static const unsigned char bytes[] = {"
          (string/join (interpose ", " chunks))
          "};\n\n"
          "const unsigned char *" name "_embed = bytes;\n"
          "size_t " name "_embed_size = sizeof(bytes);\n")))

(defn main [& args]
  (def name (get args 1))
  (def filename (get args 2))
  (unless (and name filename)
    (print "Please pass in <name> and <filename> (janet file) to create C out of.")
    (os/exit 1))
  (embed-janet name (slurp filename)))
