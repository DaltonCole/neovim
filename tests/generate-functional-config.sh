#!/usr/bin/env bash
# Generates the container-structure-test config for functional keybinding
# checks: does each plugin declared in nvim/init.vim actually load and
# register what it's supposed to, not just "is its directory present"
# (tests/generate-cst-config.sh already covers that).
#
# The built image has init.vim/coc-settings.json deliberately stripped out
# (the Dockerfile removes them; docker-compose.yaml bind-mounts the real
# ones in at runtime), so this config bind-mounts the real files into the
# test container the same way, via container-structure-test's
# containerRunOptions.bindMounts (docker driver only).
#
# Each check is a single `nvim --headless -c ... -c qa!` invocation that
# `cquit 1`s on failure. Where a plugin exposes something more precise than
# init.vim's own keybinding line (a <Plug> target, a wrapper Ex command),
# that's checked instead/in addition - `nmap gd <Plug>(coc-definition)`
# succeeds even if CoC never defined that target, so checking `gd` alone
# only proves init.vim's line ran, not that CoC provided the feature.
# Where safe/reliable (no network call, no live LSP/debug-adapter session,
# no interactive picker UI), the binding is actually triggered and a real,
# plugin-agnostic side effect is checked (usually a window-count delta)
# rather than just "is it mapped".
#
# Dockerfile-agnostic: same checks regardless of which Dockerfile built the
# base image, since they only depend on the plugins being installed
# (verified separately by generate-cst-config.sh) and on the real init.vim,
# which is identical either way.
#
# Usage: tests/generate-functional-config.sh

set -euo pipefail
cd "$(dirname "$0")/.."

REPO_ROOT="$(pwd)"

echo 'schemaVersion: "2.0.0"'
echo
echo "containerRunOptions:"
echo "  bindMounts:"
echo "    - $REPO_ROOT/nvim/init.vim:/home/docker/.config/nvim/init.vim"
echo "    - $REPO_ROOT/nvim/coc-settings.json:/home/docker/.config/nvim/coc-settings.json"
echo
echo "commandTests:"

# One nvim --headless commandTest per check. $1=name, $2...=one -c argument
# per vimscript command (joined with -c between them), always finishing
# with a forceful quit so leftover windows/unsaved fixture buffers never
# hang the test.
check() {
    local name="$1"; shift
    printf '  - name: "%s"\n' "$name"
    printf '    command: "nvim"\n'
    printf '    args: ["--headless"'
    for cmd in "$@"; do
        printf ', "-c", "%s"' "$cmd"
    done
    printf ', "-c", "qa!"]\n'
    printf '    exitCode: 0\n'
}

echo "  # --- <C-s> conflict: CoC's coc-range-select (nmap/xmap <C-s>, coc.nvim"
echo "  # config section) is shadowed by CtrlSF's later nmap/xmap <C-s> - last"
echo "  # mapping wins. Assert the actual effective binding, not the shadowed one."
check "<C-s> (normal) resolves to CtrlSF, not shadowed CoC range-select" \
    "if maparg('<C-s>', 'n') !~# 'CtrlSFVwordPath' | cquit 1 | endif"
check "<C-s> (visual) resolves to CtrlSF, not shadowed CoC range-select" \
    "if maparg('<C-s>', 'x') !~# 'CtrlSFVwordPath' | cquit 1 | endif"

echo
echo "  # --- CoC: check the <Plug> targets init.vim maps to directly - proves"
echo "  # coc.nvim itself registered them, independent of whether init.vim's own"
echo "  # nmap/xmap lines are intact (those succeed even if the target doesn't exist)."
for plug in "coc-diagnostic-prev:n" "coc-diagnostic-next:n" "coc-definition:n" \
            "coc-type-definition:n" "coc-implementation:n" "coc-references:n" \
            "coc-rename:n" "coc-format-selected:n" "coc-codeaction-selected:n" \
            "coc-codeaction:n" "coc-fix-current:n" "coc-codelens-action:n" \
            "coc-funcobj-i:x" "coc-funcobj-a:x" "coc-classobj-i:x" "coc-classobj-a:x" \
            "coc-range-select:n"; do
    target="${plug%%:*}"
    mode="${plug##*:}"
    check "coc.nvim provides <Plug>($target)" \
        "if empty(maparg('<Plug>($target)', '$mode')) | cquit 1 | endif"
done

echo
echo "  # --- CoC: CocList-family bindings (cd/ce/cc/co/cs/cj/ck/cp) are plain Ex"
echo "  # command invocations, not <Plug> targets - check the commands directly."
for cmd in CocList CocNext CocPrev CocListResume; do
    check "coc.nvim provides :$cmd" \
        "if !exists(':$cmd') | cquit 1 | endif"
done

echo
echo "  # --- MRU / BufExplorer: trigger for real and check the resulting filetype."
echo "  # (Both take over the CURRENT window rather than splitting, so a window-count"
echo "  # delta doesn't detect them; MRU also needs a real, already-existing file"
echo "  # opened first - it no-ops with 'MRU file list is empty' otherwise.)"
check "MRU (<leader>f) opens the MRU list" \
    "edit /etc/hostname" "normal ,f" "if &filetype !=# 'mru' | cquit 1 | endif"
check "BufExplorer (<leader>o) opens the buffer list" \
    "normal ,o" "if &filetype !=# 'bufexplorer' | cquit 1 | endif"

echo
echo "  # --- CtrlP: config-var-driven (g:ctrlp_map), not a literal map line -"
echo "  # its own startup code turns g:ctrlp_map into a real mapping."
check "CtrlP (<C-f>) mapped and :CtrlP command available" \
    "if empty(maparg('<C-f>', 'n')) || !exists(':CtrlP') | cquit 1 | endif"

echo
echo "  # --- NERDTree: trigger the primary toggle and check the well-known"
echo "  # 'nerdtree' filetype; the other three bindings get an existence check."
check "NERDTree (<leader>nn) opens a nerdtree-filetype window" \
    "normal ,nn" "if &filetype !=# 'nerdtree' | cquit 1 | endif"
check "NERDTree (<leader>ng) mapped" \
    "if empty(maparg('<leader>ng', 'n')) | cquit 1 | endif"
check "NERDTree (<leader>nb) mapped" \
    "if empty(maparg('<leader>nb', 'n')) | cquit 1 | endif"
check "NERDTree (<leader>nf) mapped" \
    "if empty(maparg('<leader>nf', 'n')) | cquit 1 | endif"

echo
echo "  # --- Telescope: Lua-based, floating-window picker UI with undocumented"
echo "  # internals and real headless-reliability risk - existence check only."
check "Telescope provides :Telescope command" \
    "if !exists(':Telescope') | cquit 1 | endif"

echo
echo "  # --- Tagbar: needs something for ctags to find; write a tiny fixture"
echo "  # file first, then toggle and check a window opened."
check "Tagbar (<leader>tt) opens a window" \
    "edit /tmp/_tagbar_fixture.py" \
    "call setline(1, ['def foo():', '    pass'])" \
    "write" \
    "let g:_w = winnr('\$')" "normal ,tt" "if winnr('\$') <= g:_w | cquit 1 | endif"

echo
echo "  # --- GitGutter: toggle and check the actual flag it controls flips"
echo "  # from init.vim's explicit default (0)."
check "GitGutter (<leader>gg) flips g:gitgutter_enabled" \
    "normal ,gg" "if g:gitgutter_enabled != 1 | cquit 1 | endif"

echo
echo "  # --- Fugitive / Tabular: existence checks only - Gvdiffsplit needs an"
echo "  # open file in a git tree with real changes; Tab's mapping intentionally"
echo "  # leaves the cmdline open awaiting a regex argument, not end-to-end triggerable."
check "Fugitive provides :Gvdiffsplit" \
    "if !exists(':Gvdiffsplit') | cquit 1 | endif"
check "Tabular provides :Tabularize (:Tab alias used by the t mapping)" \
    "if !exists(':Tabularize') | cquit 1 | endif"

echo
echo "  # --- Vimspector: <Plug> targets only - no live debug adapter session."
for plug in VimspectorContinue VimspectorToggleBreakpoint VimspectorRunToCursor \
            VimspectorRestart VimspectorPause VimspectorStop VimspectorStepOver \
            VimspectorStepInto VimspectorStepOut VimspectorBalloonEval; do
    check "vimspector provides <Plug>$plug" \
        "if empty(maparg('<Plug>$plug', 'n')) | cquit 1 | endif"
done

echo
echo "  # --- vim-ai: command-existence only - these fire a real HTTPS call to"
echo "  # shirty.sandia.gov and must never actually be triggered in a test."
for cmd in AI AIChat AIRedo; do
    check "vim-ai provides :$cmd" \
        "if !exists(':$cmd') | cquit 1 | endif"
done

echo
echo "  # --- vim-ai off switch: NEOVIM_VIM_AI=0 (set via .env on machines that"
echo "  # shouldn't use the endpoint) must leave the plugin unloaded, none of"
echo "  # init.vim's vim-ai mappings set, and no errors logged while loading"
echo "  # init.vim (e.g. from the skipped heredoc). Normal-mode ,a then falls"
echo "  # back to emmet's own mapping, so check for :AI rather than emptiness."
echo "  # v:errmsg isn't usable here: a plugin's silent! call leaves E328 in it"
echo "  # either way, so check the logged messages instead."
echo "  # Set via env(1), not envVars: container-structure-test drops per-test"
echo "  # envVars when containerRunOptions (the bind mounts above) is set."
printf '  - name: "%s"\n' "NEOVIM_VIM_AI=0 leaves vim-ai unloaded and unmapped"
printf '    command: "env"\n'
printf '    args: ["NEOVIM_VIM_AI=0", "nvim", "--headless", "-c", "%s", "-c", "qa!"]\n' \
    "if exists(':AI') || exists(':AIChat') || exists(':AIRedo') || maparg(',a', 'n') =~# ':AI' || maparg(',a', 'x') =~# ':AI' || maparg(',c', 'n') =~# ':AI' || maparg(',r', 'n') =~# ':AI' || execute('messages') =~# 'E[0-9][0-9]*:' | cquit 1 | endif"
printf '    exitCode: 0\n'

echo
echo "  # --- <leader>s conflict: bound twice (plain 'map' -> window split,"
echo "  # then a visual-only 'vnoremap' override -> wrap selection in parens)."
echo "  # Verified behaviorally per mode rather than by matching maparg's rhs"
echo "  # encoding, which is fragile for control-key-heavy rhs text."
check "<leader>s (normal) still splits the window" \
    "let g:_w = winnr('\$')" "normal ,s" "if winnr('\$') <= g:_w | cquit 1 | endif"
check "<leader>s (visual) wraps the selection in parens instead of splitting" \
    "call setline(1, 'hello')" \
    "let g:_w = winnr('\$')" \
    "normal v\$,s" \
    "if winnr('\$') != g:_w | cquit 1 | endif" \
    "if getline(1) !~# '(' || getline(1) !~# ')' | cquit 1 | endif"

echo
echo "  # --- Bonus: plugins that register a real mapping at startup from a"
echo "  # config var, even though it's not a literal map/nmap/etc line."
check "better-escape.vim registers its jj-detecting insert mapping" \
    "if maparg('j', 'i') !~# 'better_escape' | cquit 1 | endif"
check "vim-surround registers ys (normal mode)" \
    "if empty(maparg('ys', 'n')) | cquit 1 | endif"
check "vim-surround registers cs (normal mode)" \
    "if empty(maparg('cs', 'n')) | cquit 1 | endif"
check "vim-surround registers ds (normal mode)" \
    "if empty(maparg('ds', 'n')) | cquit 1 | endif"
check "emmet-vim registers ,, (insert mode, from g:user_emmet_leader_key)" \
    "if empty(maparg(',,', 'i')) | cquit 1 | endif"
