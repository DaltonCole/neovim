# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A containerized Neovim environment that runs under Docker or rootless Podman. The container runs persistently (`sleep infinity`) and the host shell `exec`s into it to launch `nvim`. The host filesystem is mounted at `/system` inside the container, so all host files are accessible from within nvim.

## Commands

```bash
make build   # Build the image (passes UID/GID/LOCAL_UNAME automatically)
make up      # Start the container in detached mode
make down    # Stop the container
make test    # Run the backwards-compatibility test suite against Dockerfile (Docker only)
make test-wip # Run the same suite against wip-Dockerfile (Docker only)

# Any of the first three under a specific engine (default: auto-detect)
make up NEOVIM_ENGINE=podman
```

The image is tagged `neovim:latest` (`localhost/neovim:latest` under Podman). The compose project name is pinned to `neovim` (top-level `name:` in `docker-compose.yaml`), and the host's `neovim()` function finds the container by its `com.docker.compose.project=neovim` / `com.docker.compose.service=neovim` labels, which both Docker Compose and podman-compose set.

## Architecture

| File | Purpose |
|------|---------|
| `Dockerfile` | Single-stage build: installs packages, creates user matching host UID/GID, installs vim-plug + CoC extensions + Vimspector adapters headlessly, then removes `init.vim` so the bind mount takes over at runtime |
| `wip-Dockerfile` | Two-stage build variant (builder + runtime) — WIP, not yet used by `docker-compose.yaml` |
| `docker-compose.yaml` | Defines the `neovim` service; bind-mounts `nvim/init.vim` and `nvim/coc-settings.json` into the container so changes take effect without a rebuild; passes `NEOVIM_VIM_AI` through from `.env` |
| `compose.podman.yaml` | Podman-only overrides the Makefile layers on top when `NEOVIM_ENGINE=podman`: `userns_mode: keep-id` and `x-podman: in_pod: false` (see Key Design Points) |
| `.env` | Gitignored, per machine. Read by `docker-compose.yaml`; currently just `NEOVIM_VIM_AI` |
| `Makefile` | `build`/`up`/`down` via `docker compose` or `podman-compose -f docker-compose.yaml -f compose.podman.yaml`, chosen by `NEOVIM_ENGINE` |
| `nvim/init.vim` | Full Neovim config — plugins, CoC LSP, Vimspector debugger, vim-ai, keymaps |
| `nvim/coc-settings.json` | CoC LSP config; currently wires up `ccls` for C/C++ |
| `vimspector-examples/python/.vimspector.json` | Template `.vimspector.json` for Python debug sessions |
| `tests/` | [container-structure-test](https://github.com/GoogleContainerTools/container-structure-test)-based test suite for the built image. `tests/test-image.sh [Dockerfile]` builds the given Dockerfile and checks it; `tests/cst/base.yaml` holds Dockerfile-agnostic structural checks (binaries, user/mount setup), `tests/generate-cst-config.sh` generates the plugin/CoC/symlink checks that depend on the specific Dockerfile or host user, and `tests/generate-functional-config.sh` bind-mounts the real `nvim/init.vim`/`coc-settings.json` in (same paths `docker-compose.yaml` uses at runtime) and checks that plugin keybindings actually load and work, not just that their plugin directories exist on disk. Run via `make test` / `make test-wip`. |

## Key Design Points

- **Docker or Podman**: the Makefile picks `NEOVIM_ENGINE` — `docker` when a real Docker CLI is installed, otherwise `podman` (podman-docker's `docker` shim reports "podman version ..." and counts as Podman). The `neovim()` function in bashrc_vimrc uses the same rule and passes its choice to `make up`. Export `NEOVIM_ENGINE` to override both.
- **Rootless Podman needs `keep-id`**: without it, the container's UID 1000 maps to a host subuid (e.g. 100999), so saving through `/system` fails or leaves files owned by that subuid. `compose.podman.yaml` sets `userns_mode: keep-id` (your host UID/GID pass straight through, matching the build args) and `in_pod: false` (podman-compose's default pod can't be combined with a per-container user namespace). Docker rejects `keep-id`, which is why this lives in a separate file. Requires `podman`, `podman-compose` and an `/etc/subuid`/`/etc/subgid` range for the user.
- **Podman `make up` recreates stale containers**: podman-compose, unlike Docker Compose, keeps a container on its old image after `make build`. Under Podman, `make up` first removes a container whose image isn't the current `neovim:latest` (named volumes are kept), so a rebuild takes effect the same way on both engines.
- **vim-ai on/off**: `NEOVIM_VIM_AI=0` in `.env` makes `init.vim` skip vim-ai's `Plug` line, config and mappings (`g:use_vim_ai`). The plugin stays installed in the image; unset or any other value means enabled. Covered by a functional test.
- **Base image is fully qualified** (`docker.io/library/ubuntu:26.04`) so Podman doesn't need a short-name alias to resolve it.
- **UID/GID passthrough**: the image is built with the host user's UID/GID so file permissions work correctly on bind-mounted files. Always pass these when building manually: `docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg LOCAL_UNAME=$(whoami) .`
- **Config is live-edited**: `init.vim` and `coc-settings.json` are bind-mounted, so editing them on the host is immediately reflected inside the running container — no rebuild needed.
- **Plugin changes require a rebuild**: adding or removing plugins in `init.vim` requires `make build` because plugins are installed at image build time. The `autocmd VimEnter` auto-install guard in `init.vim` handles net-new plugins on first launch after a rebuild.
- **`/system` mount**: the entire host root is mounted at `/system`, which is how the `neovim()` shell function (in the README `.bashrc` snippet) translates host paths to container paths when opening files.

## Plugin Stack (init.vim)

- **Completion/LSP**: CoC (`coc.nvim`) with extensions for C/C++ (`coc-clangd`), Python (`coc-pyright`), Rust (`coc-rust-analyzer`), TypeScript, YAML, JSON, etc.
- **Debugger**: Vimspector with `debugpy` (Python) and `vscode-cpptools` (C/C++) adapters.
- **AI**: `vim-ai` pointed at a local Llama 3.3 70B endpoint (`https://shirty.sandia.gov/api/v1/chat/completions`).
- **File navigation**: NERDTree, CtrlP, MRU, BufExplorer, CtrlSF, Telescope.
- **Tags**: `vim-gutentags` (auto ctags) + Tagbar sidebar.
- **Leader key**: `,`
