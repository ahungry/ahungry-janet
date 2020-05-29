IUP?=none

all: build install test

build:
	jpm --com.ahungry.gui.iup=$(IUP) build

install:
	jpm --com.ahungry.gui.iup=$(IUP) install

clean:
	-jpm clean
	-jpm clear-cache
	-jpm clear-manifest

test:
	jpm test

.PHONY: all test
