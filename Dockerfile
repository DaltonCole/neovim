# Two stages; only the second one becomes the image.
#
#   builder  installs vim-plug, the plugins in nvim/init.vim and the CoC
#            extensions, with tools that only installing needs.
#   runtime  installs what nvim and those plugins use while you edit, then
#            copies the finished plugin and extension directories over.
#
# Both stages use --no-install-recommends and list every package they need.
# Recommends used to pull in hundreds of MB the editor never uses: gcc/g++
# and python3-dev, X11 tools and Mesa drivers (the container has no
# display), and more.
#
# Base image fully qualified so Podman doesn't depend on a short-name alias
# to resolve it. Docker pulls the same image either way.

# =============================================================================
FROM docker.io/library/ubuntu:26.04 AS builder

RUN apt-get -y update && \
    apt-get install -y --no-install-recommends \
                       ca-certificates \
                       curl \
                       git \
                       neovim \
                       nodejs \
                       npm && \
    rm -rf /var/lib/apt/lists/*

# npm from the npm registry, for both stages. Debian splits npm into ~350
# node-* packages plus node-gyp and its -dev headers (+112 MB installed);
# the registry package bundles its own dependencies (19 MB). npm 10 is the
# major version Node 22 ships with upstream. Debian's npm above only
# bootstraps this one and stays in this stage.
RUN npm install --global --prefix /opt/npm --no-audit --no-fund npm@10
ENV PATH=/opt/npm/bin:$PATH

ARG UNAME=docker
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME && \
    useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME

USER $UNAME
ENV HOME=/home/${UNAME}

# vim-plug, then the plugins from init.vim. This copy of init.vim is only
# for the install; the real one is bind-mounted at runtime.
RUN curl -fLo "${HOME}/.local/share/nvim/site/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
COPY --chown=${UID}:${GID} nvim/init.vim ${HOME}/.config/nvim/init.vim
RUN nvim --headless +PlugInstall +qall
# coc-markdown was never a published extension (404 from the npm registry);
# coc-markdownlint is the extension the coc.nvim wiki actually lists for
# Markdown support, maintained by the same author as several extensions here.
# The mkdir keeps the runtime stage's COPY of ~/.config/coc working if you
# comment out the CocInstall line.
RUN mkdir -p ${HOME}/.config/coc && \
    nvim --headless +'CocInstall -sync coc-yank coc-html coc-highlight coc-git coc-fzf-preview coc-docker coc-clang-format-style-options coc-yaml coc-tsserver coc-sh coc-rust-analyzer coc-pyright coc-markdownlint coc-json coc-htmlhint coc-css coc-cmake coc-clangd' +qall

# Drop what nothing reads at runtime before the runtime stage copies it:
#  - each plugin's .git (vim-plug's clone, ~78 MB). Plugins are baked in at
#    build time and changed by rebuilding, so nothing needs their history.
#    The cost: :PlugUpdate, :PlugClean and :PlugStatus inside the container
#    see the plugins as broken. The VimEnter guard in init.vim only checks
#    that each plugin directory exists, so it is unaffected.
#  - source maps in the CoC extensions (~20 MB). Only debuggers read them.
# The npm cache that CocInstall leaves in ~/.npm (~170 MB) is never copied.
RUN find ${HOME}/.nvim/plugged -mindepth 2 -maxdepth 2 -name .git -exec rm -rf {} + && \
    find ${HOME}/.config/coc/extensions -type f \
         \( -name '*.js.map' -o -name '*.cjs.map' -o -name '*.mjs.map' \
            -o -name '*.css.map' -o -name '*.ts.map' \) -delete


# =============================================================================
FROM docker.io/library/ubuntu:26.04

# What nvim and the plugins in init.vim use while you edit:
#   neovim                       the editor
#   python3, python3-neovim      nvim's python3 provider (python-mode)
#   nodejs                       runs coc.nvim and its extensions
#   git, less                    fugitive, gitgutter, coc-git, gutentags;
#                                less is git's default pager
#   exuberant-ctags              gutentags, tagbar
#   clang-format                 vim-clang-format
#   libc6-dev, libstdc++-15-dev  C and C++ standard headers. The clangd that
#                                coc-clangd downloads needs them to resolve
#                                <stdio.h>, <vector> and so on. Headers only,
#                                no compiler. (They used to arrive through
#                                Recommends, along with all of build-essential.)
#   curl                         netrw's downloader (:e https://..., spell
#                                files for languages other than English)
#   make, patch, bzip2,          what nvim's own commands run: :make,
#   xz-utils, xxd                :diffpatch, editing .bz2/.xz files, hex
#                                editing (:help hex-editing). Under 2 MB.
#   ca-certificates              HTTPS for git, curl and node
# coc-clangd and coc-rust-analyzer download their language servers with
# Node's own HTTP and unzip code, so they need no unzip or wget.
# Not installed: clangd (coc-clangd downloads its own matching clangd on
# first use), ccls (might need `sudo snap install ccls --classic`), and
# git-all (fugitive/coc-git/gutentags only need plain git).
# `apt-get upgrade` brings in base-image security fixes on each rebuild.
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
                       bzip2 \
                       ca-certificates \
                       clang-format \
                       curl \
                       exuberant-ctags \
                       git \
                       less \
                       libc6-dev \
                       libstdc++-15-dev \
                       make \
                       neovim \
                       nodejs \
                       patch \
                       python3 \
                       python3-neovim \
                       xxd \
                       xz-utils && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# npm (see the builder stage). coc.nvim runs it for :CocInstall/:CocUpdate
# of extensions that have dependencies, and coc-tsserver for Automatic Type
# Acquisition.
COPY --from=builder /opt/npm /opt/npm
RUN ln -s /opt/npm/bin/npm /opt/npm/bin/npx /usr/local/bin/

# --- Add a user --- #
ARG UNAME=docker
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME && \
    useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME

USER $UNAME
ENV HOME=/home/${UNAME}

# Created as the user so the user owns them. mru and undodir are mount
# points for named volumes, which take this ownership when first created.
# init.vim and coc-settings.json get bind-mounted into ~/.config/nvim at
# runtime, and nvim writes the spellfile (zg) there.
RUN mkdir -p ${HOME}/.config/nvim/mru ${HOME}/.config/nvim/undodir \
             ${HOME}/.config/coc ${HOME}/.local/share/nvim/site ${HOME}/.nvim

# Plugins, CoC extensions and vim-plug from the builder: only these three
# directories, not the builder's toolchain, npm cache or build-time init.vim.
COPY --from=builder --chown=${UID}:${GID} /home/${UNAME}/.nvim                  /home/${UNAME}/.nvim
COPY --from=builder --chown=${UID}:${GID} /home/${UNAME}/.config/coc            /home/${UNAME}/.config/coc
COPY --from=builder --chown=${UID}:${GID} /home/${UNAME}/.local/share/nvim/site /home/${UNAME}/.local/share/nvim/site

# Get local conda environment to work inside of container
ARG LOCAL_UNAME
ARG LOCAL_SYSTEM_VOL=system
USER root
RUN ln -s /${LOCAL_SYSTEM_VOL}/home/$LOCAL_UNAME /home/$LOCAL_UNAME
USER $UNAME

# Use bash as the entrypoint. Will require adding nvim as an argument
#   This is given to add more flexibility when running the container
ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
