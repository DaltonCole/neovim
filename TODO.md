# TODO

## Tasks

* Minimize the size of the docker container:
    2) be employing a multi-stage build process
        * wip-Dockerfile has known issues (still WIP) - docker-compose.yaml points back at the stable Dockerfile for now
* Two bugs found while inventorying init.vim's keybindings for the functional test suite (not fixed - logged only):
    * `<leader>r` in visual mode calls `VisualSelection('replace', '')`, which calls `CmdLine(...)` - a function that is never defined anywhere in this repo. Guaranteed `E117: Unknown function: CmdLine` if triggered. (Normal-mode `<leader>r` is not mapped.)
    * `g:javascript_plugin_jsdoc` / `g:javascript_plugin_flow` are configured in init.vim but no `vim-javascript` plugin is ever declared in the `Plug` list - dead/orphaned config.

## Completed Tasks

* Clean up repository: removed stray generated `tags` file from repo root; fixed docker-compose.yaml pointing at the broken wip-Dockerfile instead of the stable Dockerfile
* Clean up files: removed dead `Plug 'universal-ctags/ctags'` line from init.vim (it only cloned the source and never built a binary; apt-installed `exuberant-ctags` already provides the `ctags` binary gutentags uses)
* Minimize the size of the docker container:
    1) Clean up docker file to remove unnecessary components - trimmed `git-all` to `git`, dropped the system `clangd` package (coc-clangd downloads its own matching clangd on first use; container has internet)
* Added a backwards-compatibility test suite (`tests/`, container-structure-test based, `make test` / `make test-wip`) that builds a Dockerfile and checks core binaries, the vim-plug/CoC extension install, and the user/mount setup all still work. Surfaced a pre-existing bug (unrelated to the cleanup above), fixed below:
    * `coc-markdown` fails to install (404 from the npm registry under that extension name)
* Fixed the `coc-markdown` 404 in `Dockerfile`: that package was never actually published to npm (registry 404, and it's absent from both the npm registry and the coc.nvim wiki's extension list). Swapped it for `coc-markdownlint`, the extension the coc.nvim wiki actually lists for Markdown support, maintained by the same author (fannheyward) as several other extensions already in this list. Verified via `make test`: 65/65 passing, no known failures left. wip-Dockerfile still has the original `coc-markdown` line - not touched, left for you to keep iterating on separately.
