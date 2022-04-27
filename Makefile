.PHONY: all always-build

RELPATH := $(shell realpath .)

all: version.txt
always-build:

version.txt: version.txt.tmpl always-build
	gomplate < version.txt.tmpl > version.txt
	git add version.txt

prepare-release: version.txt

test:
	echo "Add tests" 1>&2
	false
