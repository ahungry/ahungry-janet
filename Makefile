IUP?=none

CC=gcc
CFLAGS=-Wall -Wno-unused-variable -Wno-unused-function -Wno-unused-parameter -Wno-format-truncation -std=gnu99 -fPIC
LFLAGS=-lm -pthread -lz -ldl

all: build install test

ming:
	make -f Wakefile all

package:
	./package-windows.sh

app.bin:
	$(CC) $(CFLAGS) -I./amalg amalg/janet.c src/app.c -o $@ $(LFLAGS)

build:
	IUP=$(IUP) jpm build

install:
	IUP=$(IUP) jpm install

clean:
	-jpm clean
	-jpm clear-cache
	-jpm clear-manifest

test:
	jpm test

.PHONY: all test
