# neovim-docker

This builds a container for the use of neovim + plugins, run under Docker or rootless Podman. It is assumed that CoC will be used as a plugin. If this is not the case, comment out the "CocInstall" line in the Dockerfile.

## Getting started

* To build: `make build`

* To run: `make up`

`make` picks the engine: Docker when a real Docker CLI is installed, otherwise Podman (podman-docker's `docker` shim counts as Podman). Override with e.g. `make up NEOVIM_ENGINE=podman`, or export `NEOVIM_ENGINE`.

Under Podman, the Makefile runs `podman-compose` with `compose.podman.yaml` layered on top of `docker-compose.yaml`. That runs the container with `userns_mode: keep-id`, so files you save through `/system` stay owned by you. It needs `podman`, `podman-compose`, and an `/etc/subuid`/`/etc/subgid` range for your user (Ubuntu creates one for normal users).

## Per-machine settings

`docker-compose.yaml` reads an optional, gitignored `.env` file next to it:

* `NEOVIM_VIM_AI=0` loads nvim without the vim-ai plugin (its config and `<leader>a`/`<leader>c`/`<leader>r` mappings are skipped too). Unset means enabled.

## .bashrc

* It is recommended to add the following to your `.bashrc` file (this is the version in [bashrc_vimrc](https://github.com/DaltonCole/bashrc_vimrc)):

```
# --- Neovim (Docker or Podman) ---
NEOVIM_COMPOSE_DIR="$HOME/neovim/"

# Prints the engine that runs the neovim container: docker when a real Docker
# CLI is installed, otherwise podman. podman-docker's `docker` shim counts as
# Podman. Export NEOVIM_ENGINE=docker|podman to override. Same rule as the
# neovim repo's Makefile.
neovim_engine() {
    if [ -n "${NEOVIM_ENGINE}" ]; then
        echo "${NEOVIM_ENGINE}"
    elif command -v docker > /dev/null 2>&1 && ! docker --version 2> /dev/null | grep -qi podman; then
        echo docker
    elif command -v podman > /dev/null 2>&1; then
        echo podman
    else
        echo docker
    fi
}

# Finds the running container by its compose labels. The neovim repo pins the
# project name to "neovim", and both Docker and podman-compose set these.
neovim_container_id() {
    "${1:-$(neovim_engine)}" ps -q \
        --filter label=com.docker.compose.project=neovim \
        --filter label=com.docker.compose.service=neovim
}

neovim_start_container() {
    make -C "${NEOVIM_COMPOSE_DIR}" up NEOVIM_ENGINE="${1:-$(neovim_engine)}"
}

neovim() {
    local engine
    engine=$(neovim_engine)
    CONTAINER_ID=$(neovim_container_id "${engine}")
    if [ -z "${CONTAINER_ID}" ]; then
        neovim_start_container "${engine}"
        CONTAINER_ID=$(neovim_container_id "${engine}")
    fi

    VOL=/system
    CD_DIR=/${VOL}/$(pwd)
    PYTHON_PATH=$(dirname $(which python) 2> /dev/null)
    CARGO_PATH=$(dirname $(which cargo) 2> /dev/null)

    if [ -n "$1" ]; then
        VIM_DIR="/${VOL}/$(readlink -f "$1")"
        "${engine}" exec -it ${CONTAINER_ID} /bin/bash -l -c \
            "export PATH=\"${PYTHON_PATH}:${CARGO_PATH}:$PATH\" && cd ${CD_DIR} && nvim ${VIM_DIR}"
    else
        "${engine}" exec -it ${CONTAINER_ID} /bin/bash -l -c \
            "export PATH=\"${PYTHON_PATH}:${CARGO_PATH}:$PATH\" && cd ${CD_DIR} && nvim"
    fi
}

# Was an alias; a function so the engine is picked when it runs, not each
# time a shell starts. Extra arguments go to `build`.
buildnvim() {
    "$(neovim_engine)" build -t neovim --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg LOCAL_UNAME=$(whoami) "$@" .
}
alias n="neovim"
alias vim="neovim"
alias nvim="neovim"
alias vi="neovim"
```
