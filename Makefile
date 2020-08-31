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

clean:
	rm -rf .make/*

####################

.make/build: $(DOCKERFILES:%=.make/%) .env
	touch $@

.make/Dockerfile-archlinux:
.make/Dockerfile-archlinux-emacs: .make/Dockerfile-archlinux
.make/Dockerfile-archlinux-teams: .make/Dockerfile-archlinux
.make/Dockerfile-archlinux-slack: .make/Dockerfile-archlinux
.make/Dockerfile-archlinux-discord: .make/Dockerfile-archlinux

.make/%: docker/%
	docker image build -f $< -t conao3/$(subst docker/Dockerfile-,,$<) --build-arg UID=$(UID) --build-arg GID=$(GID) docker
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

.PHONY: emacs teams slack discord
emacs teams slack discord: .make/up
	docker-compose exec $@ $@
