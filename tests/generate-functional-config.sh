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
# Where safe/reliable (no network call, no live LSP session,
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

echo "  # --- init.vim loads cleanly: no errors (or any other message) at startup."
check "init.vim loads with no startup errors or messages" \
    "if !empty(execute('messages')) | cquit 1 | endif"

echo
echo "  # --- CoC's node side: the service starts and every extension installed"
echo "  # under ~/.config/coc/extensions registers with it. (The <Plug> checks"
echo "  # below only prove coc.nvim's vimscript side loaded.) -c commands run"
echo "  # before VimEnter, which is when coc.nvim starts its service, so fire"
echo "  # VimEnter first; :sleep keeps handling the service's messages meanwhile."
check "coc.nvim service starts and every installed extension registers" \
    "doautocmd VimEnter" \
    "let g:_t = 0" \
    "while !get(g:, 'coc_service_initialized', 0) && g:_t < 300 | sleep 100m | let g:_t += 1 | endwhile" \
    "let g:_n = len(glob('~/.config/coc/extensions/node_modules/*', 0, 1))" \
    "let g:_t = 0" \
    "while get(g:, 'coc_service_initialized', 0) && len(CocAction('extensionStats')) < g:_n && g:_t < 100 | sleep 100m | let g:_t += 1 | endwhile" \
    "if !get(g:, 'coc_service_initialized', 0) || g:_n == 0 || len(filter(CocAction('extensionStats'), {_, v -> v.state !=# 'disabled' && v.state !=# 'unknown'})) < g:_n | cquit 1 | endif"

echo
echo "  # --- <C-s> is CtrlSF. Normal mode must use a Cword target: CtrlSFVwordPath"
echo "  # only exists in visual mode, and a <Plug> target that doesn't exist gets"
echo "  # typed as literal keys, which overwrites the rest of the line."
check "<C-s> (normal) searches the word under the cursor with CtrlSF" \
    "if maparg('<C-s>', 'n') !~# 'CtrlSFCwordPath' | cquit 1 | endif" \
    "if empty(maparg('<Plug>CtrlSFCwordPath', 'n')) | cquit 1 | endif"
check "<C-s> (visual) searches the selection with CtrlSF" \
    "if maparg('<C-s>', 'x') !~# 'CtrlSFVwordPath' | cquit 1 | endif" \
    "if empty(maparg('<Plug>CtrlSFVwordPath', 'x')) | cquit 1 | endif"

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
echo "  # --- CoC: CocList-family bindings (cd/ce/cc/co/cy/cj/ck/cp) are plain Ex"
echo "  # command invocations, not <Plug> targets - check the commands directly."
for cmd in CocList CocNext CocPrev CocListResume; do
    check "coc.nvim provides :$cmd" \
        "if !exists(':$cmd') | cquit 1 | endif"
done

echo
echo "  # --- Telescope is the one fuzzy finder. Its picker UI isn't reliable"
echo "  # headless, so check that each key points at the right picker."
check "<C-f> opens Telescope's file finder" \
    "if maparg('<C-f>', 'n') !~# 'Telescope find_files' | cquit 1 | endif"
check "<leader>f opens Telescope's recent files" \
    "if maparg('<leader>f', 'n') !~# 'Telescope oldfiles' | cquit 1 | endif"
check "<leader>o opens Telescope's buffer list" \
    "if maparg('<leader>o', 'n') !~# 'Telescope buffers' | cquit 1 | endif"

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
echo "  # --- <leader>tt was Tagbar and now opens CoC's outline, the same list as co."
check "<leader>tt opens CoC's outline" \
    "if maparg('<leader>tt', 'n') !~# 'CocList outline' | cquit 1 | endif"

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

echo
echo "  # --- CoC features moved off keys that other plugins own."
check "cv selects a CoC range (normal and visual)" \
    "if maparg('cv', 'n') !~# 'coc-range-select' || maparg('cv', 'x') !~# 'coc-range-select' | cquit 1 | endif"
check "gi falls back when a language server can't find implementations" \
    "if maparg('gi', 'n') !~# 'GoToImplementation' || !exists('*GoToImplementation') | cquit 1 | endif"
check "cy searches symbols in Telescope" \
    "if maparg('cy', 'n') !~# 'Telescope coc workspace_symbols' | cquit 1 | endif"
check "gr lists references in Telescope" \
    "if maparg('gr', 'n') !~# 'Telescope coc references' | cquit 1 | endif"
check "Telescope has loaded the CoC pickers" \
    "if !luaeval('require(''telescope'').extensions.coc ~= nil') | cquit 1 | endif"
check "<C-d> and <C-u> scroll CoC popups" \
    "if maparg('<C-d>', 'n') !~# 'coc#float#scroll' || maparg('<C-u>', 'n') !~# 'coc#float#scroll' | cquit 1 | endif"
check "Tab and Shift-Tab cycle CoC's menu (pumvisible() can't see it)" \
    "if maparg('<Tab>', 'i') !~# 'coc#pum#next' || maparg('<S-Tab>', 'i') !~# 'coc#pum#prev' | cquit 1 | endif"

echo
echo "  # --- A trailing comment on a map line becomes part of the mapping and"
echo "  # runs as keystrokes. nr2char(34) is a double quote."
for key in ",st" ",sn" ",sp" ",sa" ",ss" "<M-J>" "<M-K>"; do
    check "$key mapping has no trailing comment" \
        "if empty(maparg('$key', 'n')) || stridx(maparg('$key', 'n'), nr2char(34)) >= 0 | cquit 1 | endif"
done

echo
echo "  # --- <leader>r (visual) goes through CmdLine(), which must exist."
check "CmdLine() is defined for <leader>r" \
    "if !exists('*CmdLine') | cquit 1 | endif"

echo
echo "  # --- Cheatsheet: <leader>? opens it in a floating window, q closes it."
check "<leader>? opens the cheatsheet in a floating window" \
    "normal ,?" \
    "if nvim_win_get_config(0).relative ==# '' || line('\$') < 10 | cquit 1 | endif"
check "q closes the cheatsheet" \
    "normal ,?" "normal q" \
    "if nvim_win_get_config(0).relative !=# '' | cquit 1 | endif"

echo
echo "  # --- The cheatsheet lists the current mode's or window's keys first."
check "F1 opens the cheatsheet in normal, visual and insert mode" \
    "if empty(maparg('<F1>', 'n')) || empty(maparg('<F1>', 'x')) || empty(maparg('<F1>', 'i')) | cquit 1 | endif"
check "finding functions comes first in normal mode" \
    "Cheatsheet" "if getline(1) !=# 'FIND A FUNCTION' | cquit 1 | endif"
check "insert-mode keys come first from insert mode" \
    "Cheatsheet insert" "if getline(1) !=# 'IN INSERT MODE' | cquit 1 | endif"
check "visual-mode keys come first from visual mode" \
    "Cheatsheet visual" "if getline(1) !=# 'WITH TEXT SELECTED' | cquit 1 | endif"
check "a plugin window's keys come first inside it" \
    "setfiletype nerdtree" "Cheatsheet" "if getline(1) !~# 'NERDTREE' | cquit 1 | endif"
check "F1 in Fugitive's status window opens the cheatsheet, not its help" \
    "if !exists('#User#FugitiveIndex') | cquit 1 | endif"
check "every other section still follows, and tags aren't shown" \
    "Cheatsheet insert" \
    "if search('^FIND A FUNCTION\$') == 0 || search('@insert') != 0 | cquit 1 | endif"

echo
echo "  # --- which-key's setup runs inside a pcall, so a mistake there is silent."
echo "  # It finishes loading just after VimEnter, so give it a moment."
check "which-key is set up and has its labels" \
    "doautocmd VimEnter" \
    "sleep 300m" \
    "if !luaeval('require(''which-key.config'').loaded') | cquit 1 | endif" \
    "if luaeval('#vim.tbl_filter(function(m) return m.lhs == ''gd'' and m.desc ~= nil end, require(''which-key.config'').mappings)') == 0 | cquit 1 | endif"
check "which-key also watches c, where CoC's keys are" \
    "doautocmd VimEnter" \
    "sleep 300m" \
    "if luaeval('#vim.tbl_filter(function(m) return m.lhs == ''c'' end, require(''which-key.config'').triggers.mappings)') == 0 | cquit 1 | endif"
check "Enter runs ,s and ,n from the popup" \
    "if empty(maparg(',s<CR>', 'n')) || empty(maparg(',s<CR>', 'x')) || empty(maparg(',n<CR>', 'n')) | cquit 1 | endif"
check ":OR uses basedpyright's own command in Python" \
    "setfiletype python" \
    "if !exists(':OR') || !exists('*OrganizeImports') | cquit 1 | endif"
check "Neovim's unused language-server keys don't delay gr" \
    "for k in ['grr', 'gra', 'gri', 'grn', 'grt', 'gO'] | if !empty(maparg(k, 'n')) | cquit 1 | endif | endfor"
