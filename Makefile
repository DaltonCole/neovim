.PHONY: build up down test test-wip

build:
	UID=$$(id -u) GID=$$(id -g) LOCAL_UNAME=$$(whoami) docker compose build

up:
	UID=$$(id -u) GID=$$(id -g) LOCAL_UNAME=$$(whoami) docker compose up -d

down:
	docker compose down

test:
	./tests/test-image.sh

test-wip:
	./tests/test-image.sh wip-Dockerfile
