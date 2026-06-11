# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A Dockerized Neovim environment. The container runs persistently (`sleep infinity`) and the host shell `exec`s into it to launch `nvim`. The host filesystem is mounted at `/system` inside the container, so all host files are accessible from within nvim.

## Commands

```bash
make build   # Build the Docker image (passes UID/GID/LOCAL_UNAME automatically)
make up      # Start the container in detached mode
make down    # Stop the container
```

The image is tagged `neovim:latest`. The container is named `neovim-neovim` (service name from `docker-compose.yaml`).

## Architecture

| File | Purpose |
|------|---------|
| `Dockerfile` | Single-stage build: installs packages, creates user matching host UID/GID, installs vim-plug + CoC extensions + Vimspector adapters headlessly, then removes `init.vim` so the bind mount takes over at runtime |
| `wip-Dockerfile` | Two-stage build variant (builder + runtime) — WIP, not yet used by `docker-compose.yaml` |
| `docker-compose.yaml` | Defines the `neovim` service; bind-mounts `nvim/init.vim` and `nvim/coc-settings.json` into the container so changes take effect without a rebuild |
| `nvim/init.vim` | Full Neovim config — plugins, CoC LSP, Vimspector debugger, vim-ai, keymaps |
| `nvim/coc-settings.json` | CoC LSP config; currently wires up `ccls` for C/C++ |
| `vimspector-examples/python/.vimspector.json` | Template `.vimspector.json` for Python debug sessions |

## Key Design Points

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
