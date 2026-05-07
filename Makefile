.PHONY: build

build:
	UID=$$(id -u) GID=$$(id -g) LOCAL_UNAME=$$(whoami) docker compose build
