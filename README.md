# neovim-docker

This builds a docker container for the use of neovim + plugins. It is assumed that CoC will be used as a plugin. If this is not the case, comment out the "CocInstall" line in the Dockerfile.

## Getting started

* To build: `docker build -t neovim --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg LOCAL_UNAME=$(whoami) .`
    * This will create a docker container with the `neovim` tag

* To run:
    *  `docker run --rm -v /:/system -it neovim nvim /system/<FILE>`
    * See the .bashrc section for an easier way to run

## .bashrc

* It is recommended to add the following to your `.bashrc` file:

```
# Neovim
NEOVIM_IMAGE="neovim"
NEOVIM_VOL="/system"
# Docker alias
neovim_start_container() {
    VOL=/system
    #docker run --rm --name neovim-ide \
    #    -v /:/${VOL} \
    #    -v undo-dir:/home/docker/.config/nvim/undodir \
    #    -td neovim "bash" > /dev/null
    docker compose -f /home/drc/neovim/docker-compose.yaml up -d
}
neovim() {
    CONTAINER_ID=$(docker ps -q --filter name=neovim-neovim)
    if [ -z "${CONTAINER_ID}" ]; then
        neovim_start_container
        CONTAINER_ID=$(docker ps -q --filter name=neovim-neovim)
    fi

    VOL=/system
    CD_DIR=/${VOL}/$(pwd)
    PYTHON_PATH=$(dirname $(which python) 2> /dev/null)
    CARGO_PATH=$(dirname $(which cargo) 2> /dev/null)
    # Handle `nvim <file>` and `nvim` differently
	if [ -n "$1" ]; then
        VIM_DIR="/${VOL}/$(readlink -f "$1")"
        docker exec -it ${CONTAINER_ID} /bin/bash -l -c \
            "export PATH=\"${PYTHON_PATH}:$PATH\" && cd ${CD_DIR} && nvim ${VIM_DIR}"
    else
        docker exec -it ${CONTAINER_ID} /bin/bash -l -c \
            "export PATH=\"${PYTHON_PATH}:$PATH\" && cd ${CD_DIR} && nvim"
    fi
}
alias buildnvim="docker build -t neovim --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg LOCAL_UNAME=$(whoami) ."
alias n="neovim"
alias vim="neovim"
alias nvim="neovim"
alias vi="neovim"
alias oldvim="\vim"
alias oldnvim="\nvim"
```
