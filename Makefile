## Makefile

all:

DOCKERFILES := $(subst docker/,,$(wildcard docker/Dockerfile-*))

##############################

.PHONY: all
all: build

.PHONY: build
build: $(DOCKERFILES:%=.make/%) .env

.make/Dockerfile-archlinux:
.make/Dockerfile-archlinux-emacs: .make/Dockerfile-archlinux
.make/Dockerfile-archlinux-teams: .make/Dockerfile-archlinux
.make/Dockerfile-archlinux-slack: .make/Dockerfile-archlinux
.make/Dockerfile-archlinux-discord: .make/Dockerfile-archlinux

.make/%: docker/%
	docker image build -t conao3/$(subst docker/Dockerfile-,,$<) -f $< docker
	touch $@

####################

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

.make/up: build .make/xhost .env
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

.PHONY: emacs
emacs: .make/up
	docker-compose exec emacs emacs
