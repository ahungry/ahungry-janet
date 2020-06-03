#!/bin/sh

rm app-win64.zip

zip --exclude '*.so' -r app-win64.zip \
    ./*.janet \
    ./*.dll \
    ./*.exe \
    ./lib \
    ./*.bat \
    ./examples
