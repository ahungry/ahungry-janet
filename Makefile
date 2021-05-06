# Set to IUP=none to skip iup stuff
IUP?=linux
GUI?=yes

CC=gcc
CFLAGS=-Wall -Wno-unused-variable -Wno-unused-function -Wno-unused-parameter -Wno-format-truncation -std=gnu99 -fPIC
LFLAGS=-lm -pthread -lz -ldl

all: build install test janet.bin

ming:
	make -f Wakefile all

package-linux:
	make docker-build
	make docker-run
	make docker-get
	ls -l app-gnu-linux64.tar.gz

package-windows:
	make ming
	./package-windows.sh

libjanet.so.1.16:
	$(CC) $(CFLAGS) -shared -I./amalg amalg/janet.c -o $@ $(LFLAGS)

libjanet.so: libjanet.so.1.16
	ln -sfn $< $@

janet.bin: libjanet.so
	$(CC) $(CFLAGS) -I./amalg amalg/shell.c -o $@ $(LFLAGS) -L. -l:./libjanet.so

build:
	-IUP=$(IUP) GUI=$(GUI) jpm build
	make local-lib

install:
	-IUP=$(IUP) GUI=$(GUI) jpm install

clean:
	-jpm clean
	-jpm clear-cache
	-jpm clear-manifest
	-rm -f libjanet.so libjanet.so.1.16 janet.bin

test:
	janet -m ./lib test/test.janet

docker-alpine-build:
	env docker build -t ahungry_janet_alpine_build . -f Dockerfile_alpine

docker-alpine-run:
	-env docker rm ahungry_janet_alpine_run
	env docker run --name ahungry_janet_alpine_run -it ahungry_janet_alpine_build

docker-build:
	env docker build -t ahungry_janet_build . -f Dockerfile_ubuntu

docker-get:
	env docker cp ahungry_janet_run:/app/app-gnu-linux64.tar.gz ./

docker-run:
	$(info docker cp ahungry_janet:/app/app-gnu-linux64.tar.gz ./)
	-env docker rm ahungry_janet_run
	env docker run --name ahungry_janet_run \
	-it ahungry_janet_build

local-lib:
	cp build/*.so ./lib/

.PHONY: all test local-lib build
