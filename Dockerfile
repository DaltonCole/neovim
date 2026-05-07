FROM ubuntu:26.04

# --- Package Installation --- #
# Update packages
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y ca-certificates \
                       nvim \
                       clang-format \
                       exuberant-ctags \
                       python3 \
                       python3-neovim \
                       python3-pip \
                       git-all \
                       nodejs \
                       npm \
                       curl \
                       clangd && \
    update-ca-certificates && apt-get clean && rm -rf /var/lib/apt/lists/*
# Removed ccls, might need to do sudo snap install ccls --classic


# Install neovim and dependencies
#RUN curl -sL install-node.vercel.app/lts | bash # nodejs - coc requirement
RUN pip install --no-cache-dir --break-system-packages setuptools

# --- Add a user --- #
ARG UNAME=docker
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME

USER $UNAME
ENV HOME=/home/${UNAME}

# --- Plugins --- #
# Install Plug
RUN curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# Copy init.vim for headless plugin install
COPY --chown=${UID}:${GID} nvim/init.vim ${HOME}/.config/nvim/init.vim
# Install plugins
RUN nvim --headless +PlugInstall +qall
RUN nvim --headless +'CocInstall -sync coc-yank coc-html coc-highlight coc-git coc-fzf-preview coc-docker coc-clang-format-style-options coc-yaml coc-tsserver coc-sh coc-rust-analyzer coc-pyright coc-markdown coc-json coc-htmlhint coc-css coc-cmake coc-clangd' +qall
RUN nvim --headless +'VimspectorInstall debugpy vscode-cpptools' +qall
# Remove it — the bind mount will provide the real one at runtime
RUN rm ${HOME}/.config/nvim/init.vim

# Get local conda environment to work inside of container
ARG LOCAL_UNAME
ARG LOCAL_SYSTEM_VOL=system
USER root
RUN ln -s /${LOCAL_SYSTEM_VOL}/home/$LOCAL_UNAME /home/$LOCAL_UNAME
USER $UNAME

# Use bash as the entrypoint. Will require adding nvim as an argument
#   This is given to add more flexibility when running the container
ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
