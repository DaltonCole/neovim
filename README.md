# neovim-docker

This builds a container for the use of neovim + plugins, run under Docker or rootless Podman. It is assumed that CoC will be used as a plugin. If this is not the case, comment out the "CocInstall" line in the Dockerfile.

## Getting started

* To build: `make build`

* To run: `make up`

`make` picks the engine: Docker when a real Docker CLI is installed, otherwise Podman (podman-docker's `docker` shim counts as Podman). Override with e.g. `make up NEOVIM_ENGINE=podman`, or export `NEOVIM_ENGINE`.

Under Podman, the Makefile runs `podman-compose` with `compose.podman.yaml` layered on top of `docker-compose.yaml`. That runs the container with `userns_mode: keep-id`, so files you save through `/system` stay owned by you. It needs `podman`, `podman-compose`, and an `/etc/subuid`/`/etc/subgid` range for your user (Ubuntu creates one for normal users).

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
    local engine id tool dir arg is_value="" only_files=""
    local vol=/system
    local path=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    local -a args=()

    engine=$(neovim_engine)
    id=$(neovim_container_id "${engine}")
    if [ -z "${id}" ]; then
        neovim_start_container "${engine}"
        id=$(neovim_container_id "${engine}")
    fi

    # Add the host's active Python and cargo to the container's own PATH. Only
    # folders under $HOME exist at the same path in there.
    for tool in cargo python; do
        dir=$(dirname -- "$(command -v -- "${tool}")")
        case "${dir}" in "${HOME}"/*) path="${dir}:${path}" ;; esac
    done

    # File arguments become /system paths. Options and their values don't.
    for arg in "$@"; do
        if [ -n "${is_value}" ]; then
            is_value=""
            args+=("${arg}")
        elif [ -z "${only_files}" ] && [[ "${arg}" == [-+]* ]]; then
            case "${arg}" in
                --) only_files=1 ;;
                -c|--cmd|-t|-u|-i|-S|-s|-q|--listen|--server|--startuptime) is_value=1 ;;
            esac
            args+=("${arg}")
        else
            args+=("${vol}$(realpath -m -- "${arg}")")
        fi
    done

    "${engine}" exec -it -w "${vol}$(pwd -P)" -e PATH="${path}" "${id}" nvim "${args[@]}"
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
