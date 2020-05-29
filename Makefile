all: build test

build:
	jpm build

install:
	jpm install

clean:
	jpm clean

test:
	jpm test

.PHONY: all test
