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
make help    # List the targets (also what plain `make` does)

# Any of the first three under a specific engine (default: auto-detect)
make up NEOVIM_ENGINE=podman
```

The image is tagged `neovim:latest` (`localhost/neovim:latest` under Podman). The compose project name is pinned to `neovim` (top-level `name:` in `docker-compose.yaml`), and the host's `neovim()` function finds the container by its `com.docker.compose.project=neovim` / `com.docker.compose.service=neovim` labels, which both Docker Compose and podman-compose set.

## Tracking Work

Open work lives in GitHub issues (`gh issue list`). There is no TODO file.

## Architecture

| File | Purpose |
|------|---------|
| `Dockerfile` | Two-stage build. `builder` installs vim-plug, the plugins and the CoC extensions headlessly from a build-time copy of `init.vim`. `runtime` installs only what nvim and the plugins use, creates the user matching host UID/GID, and copies in just `~/.nvim`, `~/.config/coc` and vim-plug, so `init.vim` comes only from the bind mount at runtime |
| `docker-compose.yaml` | Defines the `neovim` service; bind-mounts `nvim/init.vim` and `nvim/coc-settings.json` into the container so changes take effect without a rebuild |
| `compose.podman.yaml` | Podman-only overrides the Makefile layers on top when `NEOVIM_ENGINE=podman`: `userns_mode: keep-id` and `x-podman: in_pod: false` (see Key Design Points) |
| `Makefile` | `build`/`up`/`down` via `docker compose` or `podman-compose -f docker-compose.yaml -f compose.podman.yaml`, chosen by `NEOVIM_ENGINE` |
| `nvim/init.vim` | Full Neovim config — plugins, CoC LSP, keymaps |
| `nvim/coc-settings.json` | CoC LSP config; currently wires up `ccls` for C/C++ |
| `tests/` | [container-structure-test](https://github.com/GoogleContainerTools/container-structure-test)-based test suite for the built image. `tests/test-image.sh [Dockerfile]` builds the given Dockerfile and checks it; `tests/cst/base.yaml` holds Dockerfile-agnostic structural checks (binaries, user/mount setup), `tests/generate-cst-config.sh` generates the plugin/CoC/symlink checks that depend on the specific Dockerfile or host user, and `tests/generate-functional-config.sh` bind-mounts the real `nvim/init.vim`/`coc-settings.json` in (same paths `docker-compose.yaml` uses at runtime) and checks that plugin keybindings actually load and work, not just that their plugin directories exist on disk. Run via `make test`. |

## Key Design Points

- **Docker or Podman**: the Makefile picks `NEOVIM_ENGINE` — `docker` when a real Docker CLI is installed, otherwise `podman` (podman-docker's `docker` shim reports "podman version ..." and counts as Podman). The `neovim()` function in bashrc_vimrc uses the same rule and passes its choice to `make up`. Export `NEOVIM_ENGINE` to override both.
- **Rootless Podman needs `keep-id`**: without it, the container's UID 1000 maps to a host subuid (e.g. 100999), so saving through `/system` fails or leaves files owned by that subuid. `compose.podman.yaml` sets `userns_mode: keep-id` (your host UID/GID pass straight through, matching the build args) and `in_pod: false` (podman-compose's default pod can't be combined with a per-container user namespace). Docker rejects `keep-id`, which is why this lives in a separate file. Requires `podman`, `podman-compose` and an `/etc/subuid`/`/etc/subgid` range for the user.
- **Podman `make up` recreates stale containers**: podman-compose, unlike Docker Compose, keeps a container on its old image after `make build`. Under Podman, `make up` first removes a container whose image isn't the current `neovim:latest` (named volumes are kept), so a rebuild takes effect the same way on both engines.
- **Base image is fully qualified** (`docker.io/library/ubuntu:26.04`) so Podman doesn't need a short-name alias to resolve it.
- **UID/GID passthrough**: the image is built with the host user's UID/GID so file permissions work correctly on bind-mounted files. Always pass these when building manually: `docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg LOCAL_UNAME=$(whoami) .`
- **Config is live-edited**: `init.vim` and `coc-settings.json` are bind-mounted, so editing them on the host is immediately reflected inside the running container — no rebuild needed.
- **Plugin changes require a rebuild**: adding or removing plugins in `init.vim` requires `make build` because plugins are installed at image build time. The `autocmd VimEnter` auto-install guard in `init.vim` handles net-new plugins on first launch after a rebuild. The image keeps no plugin `.git` directories, so `:PlugUpdate`/`:PlugClean`/`:PlugStatus` don't work inside the container; rebuild instead.
- **What the runtime image contains**: only what nvim and the plugins use while editing (see the comments in `Dockerfile`'s runtime stage). It installs with `--no-install-recommends`, so there is no compiler, `pip` or `python3-dev`. The C/C++ standard headers (`libc6-dev`, `libstdc++-15-dev`) stay because the clangd that coc-clangd downloads needs them. npm comes from the npm registry (`/opt/npm`, linked into `/usr/local/bin`) rather than Debian's `npm` package, which is ~93 MB larger; coc.nvim uses npm for extension installs and coc-tsserver for type acquisition. The image is about 0.96 GB uncompressed, down from 2.7 GB.
- **Rust comes from the host**: the `neovim()` function puts the host's `~/.cargo/bin` on `PATH`. Those are rustup shims, so the image sets `RUSTUP_HOME` and `CARGO_HOME` to the host's directories (through the `/home/$LOCAL_UNAME` symlink); without them `cargo`, `rustc` and `rustfmt` refuse to run. The rust-analyzer server isn't in the image: coc-rust-analyzer offers to download it the first time a Rust file is opened, into `~/.local/share/coc-rust-analyzer` on the host (bind-mounted over the extension's data directory, created by `make up`), so it survives the container being recreated. `rust-analyzer.updates.checkOnStartup` is off because CoC records the installed version inside the container and would prompt after every recreate; update with `:CocCommand rust-analyzer.upgrade`.
- **`/system` mount**: the entire host root is mounted at `/system`, which is how the `neovim()` shell function (in the README `.bashrc` snippet) translates host paths to container paths when opening files.

## Plugin Stack (init.vim)

- **Completion/LSP**: CoC (`coc.nvim`) with extensions for C/C++ (`coc-clangd`), Python (`coc-pyright`), Rust (`coc-rust-analyzer`), TypeScript, YAML, JSON, etc.
- **File navigation**: NERDTree, Telescope (files, recent files, buffers), CtrlSF (project search).
- **Tags**: `vim-gutentags` (auto ctags). The file outline comes from CoC.
- **Leader key**: `,`
- **Cheatsheet**: `,?` (or `:Cheatsheet`) opens the key reference stored in section 8 of `init.vim`. Update it whenever a key is added or changed.
