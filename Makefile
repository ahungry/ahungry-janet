IUP?=none

CC=gcc
CFLAGS=-Wall -Wno-unused-variable -Wno-unused-function -Wno-unused-parameter -Wno-format-truncation -std=gnu99 -fPIC
LFLAGS=-lm -pthread -lz -ldl

all: build install test

ming:
	make -f Wakefile all

package:
	./package-windows.sh

libjanet.so:
	$(CC) $(CFLAGS) -shared -I./amalg amalg/janet.c -o $@ $(LFLAGS)

app.bin:
	$(CC) $(CFLAGS) -I./amalg src/app.c -o $@ $(LFLAGS) -ljanet

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
