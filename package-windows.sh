#!/bin/sh

rm app-win64.zip

zip -r app-win64.zip \
    ./*.janet \
    ./*.dll \
    ./*.exe \
    ./lib \
    ./examples
