# Set to IUP=none to skip iup stuff
IUP?=linux

CC=gcc
CFLAGS=-Wall -Wno-unused-variable -Wno-unused-function -Wno-unused-parameter -Wno-format-truncation -std=gnu99 -fPIC
LFLAGS=-lm -pthread -lz -ldl

all: build install test app.bin

ming:
	make -f Wakefile all

package-linux:
	make docker-build
	make docker-run
	make docker-get

package-windows:
	./package-windows.sh

libjanet.so.1.9: libjanet.so
	ln -sfn libjanet.so $@

libjanet.so:
	$(CC) $(CFLAGS) -shared -I./amalg amalg/janet.c -o $@ $(LFLAGS)

app.bin: libjanet.so.1.9
	$(CC) $(CFLAGS) -I./amalg src/app.c -o $@ $(LFLAGS) -ljanet

build:
	-IUP=$(IUP) jpm build

install:
	-IUP=$(IUP) jpm install

clean:
	-jpm clean
	-jpm clear-cache
	-jpm clear-manifest

test:
	-jpm test

docker-build:
	docker build -t ahungry_janet_build . -f Dockerfile_ubuntu

docker-get:
	docker cp ahungry_janet_run:/app/app-gnu-linux64.tar.gz ./

docker-run:
	$(info docker cp ahungry_janet:/app/app-gnu-linux64.tar.gz ./)
	-docker rm ahungry_janet_run
	docker run --name ahungry_janet_run \
	-it ahungry_janet_build

local-lib:
	mkdir -p local-lib
	cp build/*.so ./local-lib/
	cp lib/*.janet ./local-lib/

.PHONY: all test local-lib
