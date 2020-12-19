#!/bin/sh

find deps -name '*.dll' -exec cp {} ./ \;
find deps -name '*.a' -exec cp {} ./ \;
