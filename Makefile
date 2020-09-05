## Makefile

all:

UID ?= 1000
GID ?= 1000
DOCKERFILES := $(subst docker/,,$(wildcard docker/Dockerfile-*))

##############################

.PHONY: all
all: build

.PHONY: build
build: .make/build

.PHONY: up
up: .make/up

.PHONY: down
down:
	docker-compose down
	xhost -
	rm -rf .make/xhost .env

.PHONY: clean
clean:
	rm -rf .make/*

####################

.make/build: $(DOCKERFILES:%=.make/%) .env
	touch $@

.make/Dockerfile-archlinux:
.make/Dockerfile-archlinux-basedevel: .make/Dockerfile-archlinux
.make/Dockerfile-archlinux-go: .make/Dockerfile-archlinux-basedevel
.make/Dockerfile-archlinux-php: .make/Dockerfile-archlinux-basedevel
.make/Dockerfile-archlinux-cpp: .make/Dockerfile-archlinux-basedevel
.make/Dockerfile-archlinux-lisp: .make/Dockerfile-archlinux-basedevel
.make/Dockerfile-archlinux-elisp: .make/Dockerfile-archlinux-basedevel
.make/Dockerfile-archlinux-anyenv: .make/Dockerfile-archlinux-basedevel
.make/Dockerfile-archlinux-bashcaster: .make/Dockerfile-archlinux-basedevel

.make/%: docker/%
	docker image build -f $< -t conao3/$(subst docker/Dockerfile-,,$<) --build-arg USER=$(USER) --build-arg UID=$(UID) --build-arg GID=$(GID) docker
	touch $@

.make/up: .make/build .make/xhost .env
	docker-compose up -d
	touch $@

.make/xhost:
	xhost +local:root
	touch $@

.env:
	case "$$(uname -s)" in \
	  Linux*)   echo HOST_DISPLAY="$$DISPLAY" > $@;; \
	  Darwin*)  echo HOST_DISPLAY="host.docker.internal:0" > $@;; \
	  CYGWIN*)  echo HOST_DISPLAY="host.docker.internal:0" > $@;; \
	  MINGW*)   echo HOST_DISPLAY="host.docker.internal:0" > $@;; \
	  *)        echo "UNKNOWN uname output:$$(uname -s)";; \
	esac

##############################

.PHONY: elisp bashcaster python go php
elisp bashcaster python go php cpp lisp: .make/up
	docker-compose exec $@ zsh
