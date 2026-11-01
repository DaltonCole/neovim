.PHONY: build up down test test-wip

# Container engine: docker or podman. Defaults to Docker when a real Docker
# CLI is installed, otherwise Podman. podman-docker's `docker` shim reports
# "podman version ..." and counts as Podman. Override per call
# (`make up NEOVIM_ENGINE=podman`) or by exporting NEOVIM_ENGINE.
ifndef NEOVIM_ENGINE
NEOVIM_ENGINE := $(shell if command -v docker >/dev/null 2>&1 && ! docker --version 2>/dev/null | grep -qi podman; then echo docker; elif command -v podman >/dev/null 2>&1; then echo podman; else echo docker; fi)
endif

ifeq ($(NEOVIM_ENGINE),podman)
# compose.podman.yaml adds the Podman-only settings (see that file).
COMPOSE = podman-compose -f docker-compose.yaml -f compose.podman.yaml
else ifeq ($(NEOVIM_ENGINE),docker)
COMPOSE = docker compose
else
$(error NEOVIM_ENGINE must be docker or podman, got '$(NEOVIM_ENGINE)')
endif

# The image's user is created with your UID/GID (see docker-compose.yaml).
USER_ENV = UID=$$(id -u) GID=$$(id -g) LOCAL_UNAME=$$(whoami)

build:
	$(USER_ENV) $(COMPOSE) build

up:
ifeq ($(NEOVIM_ENGINE),podman)
# Unlike Docker Compose, podman-compose doesn't recreate the container after
# the image is rebuilt; it keeps running the old image. Remove a container
# that isn't on the current neovim:latest first (named volumes are kept).
	@cid=$$(podman ps -aq --filter label=com.docker.compose.project=neovim --filter label=com.docker.compose.service=neovim); \
	if [ -n "$$cid" ] && [ "$$(podman inspect --format '{{.Image}}' $$cid)" != "$$(podman image inspect --format '{{.Id}}' neovim:latest 2>/dev/null)" ]; then \
		echo "neovim:latest was rebuilt; recreating the container"; \
		$(COMPOSE) down; \
	fi
endif
	$(USER_ENV) $(COMPOSE) up -d

down:
	$(COMPOSE) down

# The test suite uses container-structure-test's Docker driver, so it
# always runs under Docker regardless of NEOVIM_ENGINE.
test:
	./tests/test-image.sh

test-wip:
	./tests/test-image.sh wip-Dockerfile
