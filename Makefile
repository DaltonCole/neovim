.PHONY: build up down

build:
	UID=$$(id -u) GID=$$(id -g) LOCAL_UNAME=$$(whoami) docker compose build

up:
	UID=$$(id -u) GID=$$(id -g) LOCAL_UNAME=$$(whoami) docker compose up -d

down:
	docker compose down
