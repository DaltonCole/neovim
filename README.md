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
# Docker alias
neovim_start_container() {
    VOL=/system
    docker run --rm \
        -v /:/${VOL} \
        -v undo-dir:/home/docker/.config/nvim/undodir \
        -td neovim "bash" > /dev/null
}
neovim() {
    CONTAINER_ID=$(docker ps -q --filter ancestor=neovim | tail -1)
    if [ -z "${CONTAINER_ID}" ]; then
        neovim_start_container
        CONTAINER_ID=$(docker ps -q --filter ancestor=neovim | tail -1)
    fi

    VOL=/system
    CD_DIR=/${VOL}/$(pwd)
    VIM_DIR=/${VOL}/$(readlink -f $1)
    PYTHON_PATH=$(dirname $(which python) 2> /dev/null)
    docker exec -it ${CONTAINER_ID} /bin/bash -l -c "export PATH=\"${PYTHON_PATH}:$PATH\" && cd ${CD_DIR} && nvim ${VIM_DIR}"
}
alias n="neovim"
alias vim="neovim"
alias nvim="neovim"
alias vi="neovim"
```
