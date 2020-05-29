IUP?=none

# Mingw related
WINCC?=x86_64-w64-mingw32-gcc
JANET_AMALG_SOURCE_DIR?=$(shell pwd)
JANET_DLL_DIR?=$(shell pwd)

all: build install test

build-ming:
	$(shell JANET_AMALG_SOURCE_DIR=$(JANET_AMALG_SOURCE_DIR) \
		JANET_DLL_DIR=$(JANET_DLL_DIR)\
		CC=$(WINCC) make build-ming-helper)

build-ming-helper:
	IUP=mingw jpm build

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
