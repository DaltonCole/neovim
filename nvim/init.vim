" =============================================================================
" init.vim
" =============================================================================
" Press F1 in any mode, or ,? in normal and visual mode, for the cheatsheet.
"
" Sections:
"   1. Plugins          plug#begin ... plug#end
"   2. Basics           encoding, indentation, search, undo, saving
"   3. Appearance       colorscheme, UI options, statusline
"   4. Finding things   NERDTree, Telescope, CtrlSF, tags
"   5. Code             CoC, formatters, languages
"   6. Windows & Git    splits, window movement, Fugitive, GitGutter
"   7. Editing          surround, pairs, Emmet, spell, align, insert helpers
"   8. Cheatsheet       the F1 and ,? popup and its contents
"   9. Key hints        labels for the which-key popup
"
" When you add or change a key, update the cheatsheet in section 8 and its
" popup label in section 9.
" Never put a trailing " comment on a map line: it becomes part of the mapping.
" =============================================================================


" =============================================================================
" 1. PLUGINS
" =============================================================================
" Adding or removing a plugin here needs a `make build`.

call plug#begin('~/.nvim/plugged')

" --- Colorscheme ---
Plug 'crucerucalin/peaksea.vim'

" --- Syntax / Highlighting ---
Plug 'luochen1990/rainbow'               " Colorful parentheses

" --- HTML ---
" Emmet: ,, to expand  |  html:5,,  div.foo>p#bar>a,,  ul>li*5,,
Plug 'mattn/emmet-vim'
" vim-closetag: > closes tag, >> puts close tag on new line
Plug 'alvan/vim-closetag'

" --- Completion (CoC) ---
" Docs: https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" --- Rust ---
Plug 'rust-lang/rust.vim'

" --- Editing Utilities ---
Plug 'tpope/vim-surround'        " S+symbol in visual to surround
Plug 'chun-yang/auto-pairs'      " Auto close (, [, {, ", '
Plug 'jdhao/better-escape.vim'   " jj to escape insert mode
Plug 'chaoren/vim-wordmotion'    " CamelCase and snake_case word motion
Plug 'chrisbra/vim-diff-enhanced'" Better vim-diff

" --- File Navigation ---
Plug 'preservim/nerdtree'        " <leader>nn Directory tree
Plug 'dyng/ctrlsf.vim'           " <C-s>      Search across files

" --- Telescope ---
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.6' }

" --- Key hints ---
Plug 'folke/which-key.nvim'      " Pause after g , or c to see what comes next

" --- Tags ---
" ctags (apt package, see Dockerfile): ctrl-] jump to def, ctrl-t jump back, :ts list tags
Plug 'ludovicchabant/vim-gutentags'  " Auto create/update ctags

" --- Git ---
Plug 'airblade/vim-gitgutter'   " <leader>gg toggle git change markers
Plug 'tpope/vim-fugitive'       " <leader>gv  Gvdiffsplit

" --- Formatting ---
Plug 'rhysd/vim-clang-format'

" --- Status Line ---
Plug 'itchyny/lightline.vim'

" --- Markdown ---
Plug 'godlygeek/tabular'
Plug 'preservim/vim-markdown'

call plug#end()

" Auto-install any missing plugins on startup
autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif


" =============================================================================
" 2. BASICS
" =============================================================================

" --- Leader (must come before any <leader> mapping) ---
let mapleader = ","

" --- Filetype ---
filetype plugin indent on

" --- Encoding ---
set encoding=utf8
set ffs=unix,dos,mac

" --- Indentation ---
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set softtabstop=4
set ai
set si
set wrap
set breakindent

" --- Searching ---
set ignorecase
set smartcase
set hlsearch
set incsearch
set magic

" --- History & Undo ---
set history=1000
" 400 recent files for Telescope's ,f. The shada file is on a named volume.
set shada='400,<50,s10,h
try
    set undodir=~/.config/nvim/undodir
    set undofile
catch
endtry

" --- Backups ---
set nobackup
set writebackup

" --- Behavior ---
set hidden  " Required for operations modifying multiple buffers
set backspace=eol,start,indent
set whichwrap+=<,>,h,l,[,]
set autoread
au FocusGained,BufEnter * checktime
set nofoldenable
set updatetime=300
set shortmess+=c
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Return to the last cursor position when reopening a file
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" --- Quickfix ---
autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>

" --- Save helpers ---
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

" --- Delete trailing whitespace on save ---
fun! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun
if has("autocmd")
    autocmd BufWritePre * :call CleanExtraSpaces()
endif


" =============================================================================
" 3. APPEARANCE
" =============================================================================

" --- Colorscheme (must come after plug#end) ---
set background=dark

" CoC derives inlay hints (e.g. pyright's inferred types) from SignColumn's
" background, which peaksea makes green. CoC only sets this group if it's
" undefined, so define it here. Must come before :colorscheme to take effect.
augroup inlay_hint_colors
  autocmd!
  autocmd ColorScheme * highlight CocInlayHint ctermfg=246 ctermbg=NONE guifg=#949494 guibg=NONE
augroup end

colorscheme peaksea

" --- Colors ---
syntax enable
if $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif

" --- Rainbow Parentheses ---
let g:rainbow_active = 1

" --- UI ---
set ruler
set cmdheight=1
set laststatus=2
set wildmenu
set wildignore=*.o,*~,*.pyc
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
set showmatch
set mat=2
set lazyredraw
set scrolloff=999        " Always center cursor vertically
set mouse=v              " Mouse drag/selection in new windows

" --- Left column ---
set signcolumn=number    " Merge sign column and number column
" set number
" set relativenumber

" --- Status Line ---
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
" Fallback if lightline is not active:
" set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c

function! CocCurrentFunction()
    return get(b:, 'coc_current_function', '')
endfunction

let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left':  [ ['mode', 'paste'],
      \              ['readonly', 'filename', 'modified', 'cocstatus', 'currentfunction'] ],
      \   'right': [ ['lineinfo'], ['percent'], ['fugitive'] ]
      \ },
      \ 'component': {
      \   'readonly': '%{&filetype=="help"?"":&readonly?"🔒":""}',
      \   'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}',
      \   'fugitive': '%{exists("*FugitiveHead")?FugitiveHead():""}'
      \ },
      \ 'component_function': {
      \   'cocstatus':       'coc#status',
      \   'currentfunction': 'CocCurrentFunction'
      \ },
      \ 'component_visible_condition': {
      \   'readonly': '(&filetype!="help"&& &readonly)',
      \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
      \   'fugitive': '(exists("*FugitiveHead") && ""!=FugitiveHead())'
      \ },
      \ 'separator':    { 'left': ' ', 'right': ' ' },
      \ 'subseparator': { 'left': ' ', 'right': ' ' }
      \ }
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()


" =============================================================================
" 4. FINDING THINGS
" =============================================================================

" --- Search keys ---
map <space>   /
map <C-space> ?

" --- NERDTree ---
let g:NERDTreeWinPos = "right"
let NERDTreeShowHidden = 1
let NERDTreeIgnore = ['\.pyc$', '__pycache__']
let g:NERDTreeWinSize = 35
let NERDTreeShowBookmarks = 1
let NERDTreeShowLineNumbers = 1
let NERDTreeMinimalMenu = 1
map <leader>nn :NERDTreeToggle<cr>
map <leader>ng :NERDTreeVCS<cr>
map <leader>nb :NERDTreeFromBookmark<Space>
map <leader>nf :NERDTreeFind<cr>

" --- CtrlSF (search across files) ---
" CtrlSFVwordPath only exists in visual mode, so normal mode needs Cword.
nmap <C-s> <Plug>CtrlSFCwordPath
xmap <C-s> <Plug>CtrlSFVwordPath

" --- Telescope ---
" The one fuzzy finder. pcall because the image build loads this file before
" the plugin is installed.
lua pcall(function() require('telescope').setup({ defaults = { file_ignore_patterns = { 'node_modules/' } } }) end)
nnoremap <C-f>      <cmd>Telescope find_files<cr>
nnoremap <leader>f  <cmd>Telescope oldfiles<cr>
nnoremap <leader>o  <cmd>Telescope buffers<cr>
nnoremap <leader>tf <cmd>Telescope find_files<cr>
nnoremap <leader>tb <cmd>Telescope buffers<cr>
nnoremap <leader>th <cmd>Telescope help_tags<cr>

" --- Gutentags ---
if !executable('ctags')
    let g:gutentags_dont_load = 1
endif

" --- Search for / replace the visual selection ---
vnoremap <silent> <leader>r :call VisualSelection('replace', '')<CR>
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>

function! CmdLine(str)
    call feedkeys(":" . a:str)
endfunction

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'gv'
        call CmdLine("Ack '" . l:pattern . "' " )
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction


" =============================================================================
" 5. CODE
" =============================================================================

" --- CoC: completion ---
" Tab starts completion, then cycles the list. CoC draws its own menu, so
" these check coc#pum#visible(); pumvisible() is always false for it.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()
inoremap <silent><expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Don't use arrow keys to select autocomplete items
inoremap <expr> <Up>   pumvisible() ? "\<C-y>\<Up>"   : "\<Up>"
inoremap <expr> <Down> pumvisible() ? "\<C-y>\<Down>" : "\<Down>"

" --- CoC: understanding code ---
" Diagnostics navigation
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nnoremap <silent> gi :<C-u>call GoToImplementation()<CR>
nmap <silent> gr <Plug>(coc-references)

" Neovim's own language-server keys do nothing here because CoC is the client,
" and they make gr wait to see whether another key follows.
silent! nunmap grr
silent! nunmap gra
silent! xunmap gra
silent! nunmap gri
silent! nunmap grn
silent! nunmap grt
silent! nunmap gO

" Python's language server can't find implementations. Rather than an error,
" gi then searches every symbol with the name under the cursor.
function! GoToImplementation() abort
  if CocAction('hasProvider', 'implementation')
    call CocActionAsync('jumpImplementation')
  else
    execute 'CocList -I --input=' . expand('<cword>') . ' symbols'
  endif
endfunction

" Show documentation in preview window
nnoremap <silent> H :call ShowDocumentation()<CR>
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('H', 'in')
  endif
endfunction

" Highlight symbol and references on cursor hold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Scroll float windows. Ctrl-j/k stay insert-only: outside insert mode they
" move between windows (section 6).
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-d> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-d>"
  nnoremap <silent><nowait><expr> <C-u> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-u>"
  inoremap <silent><nowait><expr> <C-J> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-K> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-d> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-d>"
  vnoremap <silent><nowait><expr> <C-u> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-u>"
endif

" --- CoC: changing code ---
" Symbol renaming
nmap crn <Plug>(coc-rename)

" Format selected code
xmap cf  <Plug>(coc-format-selected)
nmap cf  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Code actions
xmap ca  <Plug>(coc-codeaction-selected)
nmap ca  <Plug>(coc-codeaction-selected)
nmap cac <Plug>(coc-codeaction)
nmap cqf <Plug>(coc-fix-current)
nmap ccl <Plug>(coc-codelens-action)

" Text objects (requires textDocument.documentSymbol support)
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Selection ranges
nmap <silent> cv <Plug>(coc-range-select)
xmap <silent> cv <Plug>(coc-range-select)

" Commands
command! -nargs=0 Format :call CocActionAsync('format')
command! -nargs=? Fold   :call CocAction('fold', <f-args>)
command! -nargs=0 OR     :call CocActionAsync('runCommand', 'editor.action.organizeImport')
autocmd BufWritePre *.cpp,*.py,*.rs,*.h,*.hpp :OR

" --- CoC: lists ---
nnoremap <silent><nowait> cd :<C-u>CocList diagnostics<cr>
nnoremap <silent><nowait> ce :<C-u>CocList extensions<cr>
nnoremap <silent><nowait> cc :<C-u>CocList commands<cr>
nnoremap <silent><nowait> co :<C-u>CocList outline<cr>
nnoremap <silent><nowait> <leader>tt :<C-u>CocList outline<cr>
nnoremap <silent><nowait> cy :<C-u>CocList -I symbols<cr>
nnoremap <silent><nowait> cj :<C-u>CocNext<CR>
nnoremap <silent><nowait> ck :<C-u>CocPrev<CR>
nnoremap <silent><nowait> cp :<C-u>CocListResume<CR>

" --- Rust ---
let g:rustfmt_autosave = 1

" --- Clang-Format ---
autocmd FileType c ClangFormatAutoEnable
let g:clang_format#auto_format = 1


" =============================================================================
" 6. WINDOWS & GIT
" =============================================================================

" --- Splits ---
set splitbelow           " Always split below
map <leader>v <C-w>v
map <leader>s <C-w>s

" --- Window Navigation ---
let g:BASH_Ctrl_j = 'off'
let g:BASH_Ctrl_k = 'off'
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" --- GitGutter ---
let g:gitgutter_enabled = 0
nnoremap <silent> <leader>gg :GitGutterToggle<cr>

" --- Fugitive ---
nnoremap <silent> <leader>gv :Gvdiffsplit<cr>


" =============================================================================
" 7. EDITING
" =============================================================================

" --- Emmet ---
let g:user_emmet_leader_key=','

" --- Better Escape ---
let g:better_escape_shortcut = 'jj'
let g:better_escape_interval = 500

" --- Tabular (Align) ---
vnoremap t :Tab /

" --- vim-markdown ---
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_new_list_item_indent = 0

" --- Movement ---
" 0 goes to first non-blank character
map 0 ^

" --- Move Lines ---
" Alt-Shift-j / Alt-Shift-k move the current line down / up
nmap <M-J> mz:m+<cr>`z
nmap <M-K> mz:m-2<cr>`z

" --- Paste Mode ---
map <leader>pp :setlocal paste!<cr>

" --- Spell Check ---
set spelllang=en
set spell
try
    set spellfile=~/.config/nvim/en.utf-8.add
catch
endtry
set spellsuggest+=10

" In order: toggle, next error, previous error, add to dictionary, suggestions
map <leader>st :setlocal spell!<cr>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>ss z=

" --- Parenthesis / Brackets (visual surround) ---
vnoremap $1 <esc>`>a)<esc>`<i(<esc>
vnoremap $2 <esc>`>a]<esc>`<i[<esc>
vnoremap $3 <esc>`>a}<esc>`<i{<esc>
vnoremap $$ <esc>`>a"<esc>`<i"<esc>
vnoremap $q <esc>`>a'<esc>`<i'<esc>
vnoremap $e <esc>`>a`<esc>`<i`<esc>
" Must come after the plain `map <leader>s` in section 6, which it overrides
vnoremap <leader>s xi()<Esc>P

" --- Auto-close in insert mode ---
inoremap $1 ()<esc>i
inoremap $2 []<esc>i
inoremap $3 {}<esc>i
inoremap $4 {<esc>o}<esc>O
inoremap $q ''<esc>i
inoremap $e ""<esc>i
inoremap {  {}<Esc>ha
inoremap (  ()<Esc>ha
inoremap [  []<Esc>ha
inoremap "  ""<Esc>ha
inoremap '  ''<Esc>ha
inoremap `  ``<Esc>ha


" =============================================================================
" 8. CHEATSHEET
" =============================================================================
" F1, ,? or :Cheatsheet shows the text below in a floating window, with the
" keys for the current mode or plugin window first.
" Format: titles start in column 1 in capitals; entries are two spaces, the
" keys, at least two spaces, then the description. Keep lines under 76 columns.
" A title can end with @tags saying where its keys apply: @normal, @insert,
" @visual, @nerdtree, @telescope, @ctrlsf, @fugitive, @list, @diff, @quickfix.
" A title with no tags counts as @normal.

let s:cheatsheet =<< END
FIND A FUNCTION
  gd                jump to where it's defined
  gi                jump to its implementations and overrides
  gr                list every place it's used
  gy                jump to the definition of its type
  cy                search every function and type by name
  co / ,tt          list this file's functions, type to filter
  Ctrl-o / Ctrl-i   jump back / forward again

IF GD OR GI CAN'T FIND IT
  gi in Python      lists every symbol with that name, choose one
  gd stops at .h    C++ needs compile_commands.json, see the recipe below
  Ctrl-]            jump with ctags, needs no language server
  :CocRestart       restart the language servers
  :CocList services  see which language servers are running

RECIPE: MAKE GD REACH OTHER C++ FILES
  cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON   on the host (CMake)
  bear -- make      on the host, for plain Makefiles
  :CocRestart       load it, then gd reaches the .cpp

SEE WHICH KEYS COME NEXT (WHICH-KEY)
  g , c [ ] z       press one and wait: a popup lists what can follow
  Enter             run a key that also starts longer keys (,s and ,n)
  Backspace         go back one key in the popup
  Esc               close the popup
  Ctrl-d / Ctrl-u   scroll a long popup
  :WhichKey         list every key

FIND A FILE
  Ctrl-f / ,tf      fuzzy find in the current directory
  ,f                recently opened files
  ,nn               toggle the file tree (NERDTree)
  ,nf               show the current file in the tree
  ,ng               open the tree at the Git root
  ,nb               open the tree at a bookmark

SWITCH BETWEEN OPEN FILES
  ,o / ,tb          fuzzy find open buffers
  ]b / [b           next / previous buffer
  Ctrl-^            back to the previous file

SEARCH IN THIS FILE
  Space             search forward
  Ctrl-Space        search backward
  n / N             next / previous match
  * / #             search for the word under the cursor
  :noh              clear the search highlight

SEARCH ACROSS THE PROJECT
  Ctrl-s            search for the word under the cursor, Enter to run
  :CtrlSF text      search for any text
  :CtrlSFToggle     show or hide the last results
  ,th               search Vim's help topics

JUMP BY TAG (CTAGS)
  Ctrl-t            jump back after Ctrl-]
  :ts name          list every tag with that name

KEYS INSIDE THE FILE TREE (NERDTREE)  @nerdtree
  Enter / o         open the file, or open and close the folder
  i / s             open in a horizontal / vertical split
  t / T             open in a new tab / a background tab
  m                 add, move, copy or delete (menu)
  u / C             move the tree's root up / to this folder
  r / R             refresh this folder / the whole tree
  I                 show or hide hidden files
  :Bookmark name    bookmark the selected node
  D                 delete the bookmark under the cursor
  q                 close the tree
  ?                 list every key

KEYS INSIDE TELESCOPE  @telescope
  Ctrl-n / Ctrl-p   move down / up the list
  Enter             open
  Ctrl-x / Ctrl-v   open in a horizontal / vertical split
  Ctrl-t            open in a new tab
  Ctrl-u / Ctrl-d   scroll the preview
  Tab               mark a result
  Ctrl-q / Alt-q    send all / marked results to the quickfix list
  Ctrl-c            close
  Ctrl-/            list every key

KEYS INSIDE SEARCH RESULTS (CTRLSF)  @ctrlsf
  Ctrl-h            move into the results (they open on the left)
  Enter / o         open the match
  O                 open the match and close the results
  t / p             open in a new tab / preview
  Ctrl-j / Ctrl-k   next / previous match
  Ctrl-n / Ctrl-p   next / previous file
  M                 switch between normal and compact view
  (edit) then :w    change text in the results and save it to the files
  q                 close the results

UNDERSTAND CODE (COC)
  H                 show docs for the word under the cursor
  Ctrl-d / Ctrl-u   scroll an open docs popup (otherwise half a page)

FIX ERRORS AND WARNINGS (COC)
  ]g / [g           next / previous problem
  cd                list every problem
  cqf               apply the suggested fix on this line

CHANGE CODE (COC)
  crn               rename the symbol everywhere
  ca{motion}        code actions on that text (or select, then ca)
  cac               code actions for the whole file
  ccl               run the code lens on this line
  cf{motion}        format that text (or select, then cf)
  :Format           format the whole file
  :OR               organize imports (runs on save for py, cpp, rs, h)
  :Fold             fold the file using CoC's code ranges
  cv                select this piece of code, press again to grow it

IN INSERT MODE  @insert
  jj                leave insert mode
  F1                open this cheatsheet
  Ctrl-j / Ctrl-k   scroll an open docs popup
  Ctrl-r a          paste register a
  Ctrl-o            run one normal-mode command
  Ctrl-w            delete the word before the cursor

COMPLETION (INSERT MODE)  @insert
  Tab               start completion, then next suggestion
  Shift-Tab         previous suggestion
  Ctrl-n / Ctrl-p   next / previous suggestion
  Ctrl-y            accept the suggestion
  Ctrl-e            dismiss the list

WITH TEXT SELECTED  @visual
  Ctrl-s            search the project for the selection, Enter to run
  *                 search this file for the selection
  ,r                replace the selection in this file
  ca                code actions on the selection
  cf                format the selection
  cv                grow the selection to the next code structure
  S"                wrap the selection in quotes
  ,s                wrap the selection in ( )
  $1 $2 $3          wrap the selection in ( ) [ ] { }
  $$ $q $e          wrap the selection in " " ' ' ` `
  t                 align on a character: type it, then press Enter
  gc                comment or uncomment the selection
  o                 jump to the other end of the selection

SELECT BY CODE STRUCTURE (COC)  @normal @visual
  if / af           inside / around a function (vif, daf, yaf)
  ic / ac           inside / around a class

COC LISTS
  cc                every CoC command
  ce                installed extensions
  cp                reopen the last list
  cj / ck           run the next / previous item of the last list

RUST LANGUAGE SERVER
  :CocCommand rust-analyzer.upgrade   update the server on your host

KEYS INSIDE A COC LIST  @list
  Enter             open or run the item
  Tab               choose what to do with the item
  Up / Down         move through the list
  Ctrl-o            switch to normal mode (j and k to move)
  Esc               close

FORMAT AND DISPLAY
  (on save)         C files run clang-format automatically
  :ClangFormat      format C or C++ now
  :RainbowToggle    turn colored brackets on or off

WINDOWS AND SPLITS
  ,v                split left and right
  ,s                split top and bottom
  Ctrl-h/j/k/l      move to the window left / down / up / right
  Ctrl-w =          make all windows the same size
  Ctrl-w _ / |      maximize height / width
  Ctrl-w o          close every other window
  Ctrl-w c          close this window
  Ctrl-w H/J/K/L    move this window to that edge
  Ctrl-w x          swap with the next window

TABS
  :tabnew           open a new tab
  gt / gT           next / previous tab
  3gt               go to tab 3
  :tabclose         close this tab
  Ctrl-w T          move this window into a new tab

GIT
  :Git              status window (keys below)
  ,gv               side-by-side diff of this file
  :Git blame        who changed each line
  :Git log          commit history
  :Gwrite           stage this file
  :Gread            reset this buffer to the staged version
  ,gg               toggle change markers (off at startup)
  ]c / [c           next / previous change (needs ,gg outside a diff)
  ,hp               preview the change under the cursor (needs ,gg)
  ,hs / ,hu         stage / undo the change (needs ,gg)

KEYS INSIDE :GIT STATUS  @fugitive
  s / u             stage / unstage the file or hunk
  =                 show or hide an inline diff
  dv                side-by-side diff
  X                 discard the change
  cc                commit
  ca                amend the last commit
  gq                close the status window
  g?                list every key

IN A DIFF  @diff
  ]c / [c           next / previous change
  do / dp           take the change from / give it to the other side
  :diffupdate       recompute the diff
  :PatienceDiff     use a better diff algorithm

SURROUND: QUOTES, BRACKETS AND TAGS
  ysiw"             wrap the word in quotes
  yss)              wrap the line in parentheses
  cs"'              change surrounding " to '
  cst<p>            change the surrounding tag to <p>
  ds"               delete the surrounding quotes

BRACKET AND QUOTE HELPERS (INSERT MODE)  @insert
  $1 $2 $3          insert ( ) [ ] { } with the cursor inside
  $4                insert a { } block on separate lines
  $q $e             insert ' ' or " " with the cursor inside
  Alt-p             turn auto-pairs on or off
  Alt-e             pull the next word inside the pair just typed
  Alt-n             jump past the closing bracket

HTML (EMMET, CLOSETAG)
  ,,                expand: div.foo>p#bar,,  ul>li*5,,  html:5,,
  ,n / ,N           next / previous edit point
  ,d / ,D           select the tag inward / outward
  ,u                update the tag
  ,k                remove the tag
  ,j                split or join the tag
  ,/                toggle a comment
  ,a                turn the URL under the cursor into a link
  ,m                merge lines
  >                 close the tag automatically in HTML files
  >>                put the closing tag on a new line

ALIGN (TABULAR)  @visual
  :Tab /=           align on =

MOVE AND EDIT
  0                 first non-blank character on the line
  |                 first column of the line
  w / b / e         stop at camelCase and snake_case parts
  Alt-Shift-j / k   move the line down / up
  gcc               comment or uncomment the line
  ,pp               toggle paste mode

SPELLING
  ,st               turn spell check on or off
  ,sn / ,sp         next / previous misspelled word
  ,ss               suggest corrections (same as z=)
  ,sa               add the word to the dictionary (same as zg)

MARKDOWN FILES
  ]] / [[           next / previous heading
  ]u / ]h           parent heading / start of this section
  gx / ge           open the link / edit the linked file

RECIPE: RENAME A SYMBOL EVERYWHERE
  crn               on the name, type the new name and press Enter
  :wa               save every file it changed

RECIPE: REPLACE TEXT ACROSS THE PROJECT
  :CtrlSF old       search for the text, then press Enter to run it
  Ctrl-h            move into the results
  :%s/old/new/g     replace it in the results
  :w                save the change to every file, then y to confirm

RECIPE: REPLACE SELECTED TEXT IN THIS FILE
  v then motion     select the text
  ,r                the command line fills in :%s/text/
  new/g then Enter  type the replacement to finish

RECIPE: FIX A PROBLEM
  ]g                jump to the next problem
  cqf               apply the suggested fix
  cac               or see every action available

RECIPE: REVIEW AND COMMIT
  :Git              open the status window
  =                 check each file's diff
  s                 stage what you want
  cc                write the commit message, then :wq
  :Git push         push it

RECIPE: STAGE PART OF A FILE
  ,gg               turn on change markers
  ]c                go to the change
  ,hp               check it
  ,hs               stage it

RECIPE: REPEAT AN EDIT
  qa                start recording into register a
  (make the edit)   finish at the start of the next spot
  q                 stop recording
  @a / @@           play it / play it again
  20@a              play it 20 times

RECIPE: ALIGN ON A CHARACTER
  Vjj               select the lines
  t                 opens :Tab /
  = then Enter      type what to align on

RECIPE: PASTE WITHOUT AUTO-INDENT
  ,pp               turn paste mode on
  (paste)           paste from your terminal
  ,pp               turn paste mode off

VIM COMMANDS YOUR KEYS REPLACED
  S                 change the whole line (cc is a CoC list here)
  C                 change to the end of the line
  ciw               change the word (caw is a code action here)
  ct{char}          change up to a character (cf is format here)
  PageDown          page down (Ctrl-f is file search here)

VIM: MOVING AROUND
  g; / g,           older / newer edit location
  %                 matching bracket
  gg / G            top / bottom of the file
  :42               go to line 42
  { / }             previous / next blank line
  f{c} / t{c}       to / just before a character on this line
  ;                 repeat that find

VIM: SELECTING  @normal @visual
  v / V / Ctrl-v    select characters / lines / a block
  gv                reselect the last selection
  o                 jump to the other end of the selection
  aw / ip / i( / a"  word, paragraph, inside ( ), around " "

VIM: EDITING
  .                 repeat the last change
  u / Ctrl-r        undo / redo
  :earlier 10m      go back to the file as it was 10 minutes ago
  ~                 flip the case of a character
  gU{motion}        upper case that text (gu for lower case)
  Ctrl-a / Ctrl-x   add to / subtract from the number
  J                 join the next line onto this one
  >> / <<           indent / unindent the line
  ==                auto-indent the line
  Y                 yank to the end of the line

VIM: MARKS
  ma                set mark a at the cursor (A-Z work across files)
  'a / `a           go to mark a's line / exact spot
  ''                back to where you jumped from
  `.                the last change
  :marks            list marks

VIM: REGISTERS
  "ay / "ap         yank into / paste from register a
  "0p               paste the last yank, not the last delete
  :reg              list registers

VIM: SUBSTITUTE
  :s/a/b/g          replace on this line
  :%s/a/b/g         replace in the whole file
  :%s/a/b/gc        same, asking before each one
  :'<,'>s/a/b/g     replace in the selection
  &                 repeat the last substitute on this line

VIM: QUICKFIX LIST  @normal @quickfix
  :copen / :cclose  open / close the list
  ]q / [q           next / previous entry
  :cdo cmd          run a command on each entry

VIM: FOLDS
  zi                turn folding on or off (off by default here)
  za                open or close this fold
  zM / zR           close / open every fold
END

" Which sections come first depends on where the sheet was opened from.
let s:cheatsheet_labels = {
      \ 'normal': 'Normal mode', 'insert': 'Insert mode', 'visual': 'Visual mode',
      \ 'nerdtree': 'File tree', 'telescope': 'Telescope', 'ctrlsf': 'Search results',
      \ 'fugitive': 'Git status', 'list': 'CoC list', 'diff': 'Diff', 'quickfix': 'Quickfix',
      \ }
let s:cheatsheet_filetypes = {
      \ 'nerdtree': 'nerdtree', 'TelescopePrompt': 'telescope', 'ctrlsf': 'ctrlsf',
      \ 'fugitive': 'fugitive',
      \ }

function! s:CheatsheetContext(mode) abort
  if has_key(s:cheatsheet_filetypes, &filetype)
    return s:cheatsheet_filetypes[&filetype]
  elseif &buftype ==# 'quickfix'
    return 'quickfix'
  elseif &diff
    return 'diff'
  endif
  return a:mode
endfunction

" The sections tagged for this context, then everything else, both in file order.
function! s:CheatsheetLines(context) abort
  let first = []
  let rest = []
  let block = []
  let tags = []
  for line in s:cheatsheet + ['Z']
    if line =~# '^\u'
      if !empty(block)
        call extend(index(tags, a:context) >= 0 ? first : rest, block + [''])
      endif
      let parts = split(line, '\s\+@')
      let block = [parts[0]]
      let tags = len(parts) > 1 ? parts[1:] : ['normal']
    elseif line !~# '^\s*$'
      call add(block, line)
    endif
  endfor
  return first + ['──── EVERYTHING ELSE ────', ''] + rest[:-2]
endfunction

function! s:CloseCheatsheet() abort
  let return_to = b:cheatsheet_return
  let float = win_getid()
  " Closing a float can land on any window, so go back to the one it came from.
  call win_gotoid(return_to.win)
  silent! call nvim_win_close(float, v:true)
  if return_to.mode ==# 'visual'
    normal! gv
  elseif return_to.mode ==# 'insert'
    if return_to.at_end
      startinsert!
    else
      call cursor(return_to.line, return_to.col)
      startinsert
    endif
  endif
endfunction

function! s:OpenCheatsheet(mode) abort
  let return_to = {'win': win_getid(), 'mode': a:mode, 'line': line('.'), 'col': col('.'),
        \ 'at_end': col('.') > len(getline('.'))}
  let context = s:CheatsheetContext(a:mode)
  let lines = s:CheatsheetLines(context)
  stopinsert
  let width = min([76, &columns - 4])
  let height = min([len(lines), &lines - 6])
  let buf = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(buf, 0, -1, v:false, lines)
  " noautocmd: Telescope closes itself when its prompt sees BufLeave.
  let win = nvim_open_win(buf, v:true, {
        \ 'relative': 'editor',
        \ 'width': width,
        \ 'height': height,
        \ 'row': max([(&lines - height) / 2 - 1, 0]),
        \ 'col': (&columns - width) / 2,
        \ 'style': 'minimal',
        \ 'border': 'rounded',
        \ 'zindex': 200,
        \ 'noautocmd': v:true,
        \ 'title': printf(' Cheatsheet: %s   / search   n next   q close ', s:cheatsheet_labels[context]),
        \ 'title_pos': 'center',
        \ })
  let b:cheatsheet_return = return_to
  setlocal bufhidden=wipe nomodifiable scrolloff=0
  setlocal winhighlight=NormalFloat:Normal,FloatBorder:Normal
  call matchadd('Title', '^\u.*$')
  call matchadd('Title', '^─.*$')
  call matchadd('Special', '^  \S.\{-}\ze\s\{2,}')
  for key in ['q', '<Esc>', '<F1>', '<leader>?']
    execute 'nnoremap <buffer> <silent> <nowait> ' . key . ' :call <SID>CloseCheatsheet()<CR>'
  endfor
  execute 'autocmd WinLeave <buffer> ++once silent! call nvim_win_close(' . win . ', v:true)'
endfunction

command! -nargs=? Cheatsheet call s:OpenCheatsheet(empty(<q-args>) ? 'normal' : <q-args>)
nnoremap <silent> <leader>? :call <SID>OpenCheatsheet('normal')<CR>
nnoremap <silent> <F1> :call <SID>OpenCheatsheet('normal')<CR>
xnoremap <silent> <leader>? <Esc>:call <SID>OpenCheatsheet('visual')<CR>
xnoremap <silent> <F1> <Esc>:call <SID>OpenCheatsheet('visual')<CR>
inoremap <silent> <F1> <Cmd>call <SID>OpenCheatsheet('insert')<CR>
" Fugitive's status window uses F1 for its own help. CoC lists read the keyboard
" themselves, so the sheet can't open from one: press Esc first.
autocmd User FugitiveIndex nnoremap <buffer> <silent> <F1> :call <SID>OpenCheatsheet('normal')<CR>


" =============================================================================
" 9. KEY HINTS
" =============================================================================
" which-key lists the keys that can follow when you pause partway through a
" command. These labels are what it shows. A key with no label here shows its
" raw command instead.
" Plain text instead of its default icons, which need a Nerd Font.
" pcall because the image build loads this file before the plugin is installed.

" A key that also starts longer keys waits in the popup for the next key, so
" Enter runs the key itself.
nnoremap <leader>s<CR> <C-w>s
xnoremap <leader>s<CR> xi()<Esc>P
nmap <leader>n<CR> <Plug>(emmet-move-next)

lua << EOF
pcall(function()
  local wk = require('which-key')
  local function_keys = {}
  for i = 1, 12 do function_keys['F' .. i] = 'F' .. i end

  wk.setup({
    delay = 500,
    -- which-key only watches g, z and symbols by itself. CoC's keys start with c.
    triggers = { { '<auto>', mode = 'nxso' }, { 'c', mode = 'n' } },
    icons = {
      mappings = false,
      breadcrumb = '>',
      separator = '->',
      ellipsis = '...',
      keys = vim.tbl_extend('force', function_keys, {
        Up = 'Up', Down = 'Down', Left = 'Left', Right = 'Right',
        C = 'Ctrl-', M = 'Alt-', D = 'Cmd-', S = 'Shift-',
        CR = 'Enter', NL = 'Enter', Esc = 'Esc', BS = 'Backspace',
        Space = 'Space', Tab = 'Tab',
        ScrollWheelDown = 'ScrollDown', ScrollWheelUp = 'ScrollUp',
      }),
    },
  })

  wk.add({
    -- Finding code
    { 'gd', desc = 'Go to definition' },
    { 'gi', desc = 'Go to implementation' },
    { 'gr', desc = 'List references' },
    { 'gy', desc = 'Go to type definition' },
    { 'cy', desc = 'Search all functions and types' },
    { 'co', desc = "List this file's functions" },
    { ',tt', desc = "List this file's functions" },

    -- Problems and changes
    { '[g', desc = 'Previous problem' },
    { ']g', desc = 'Next problem' },
    { 'cd', desc = 'List problems' },
    { 'cq', group = 'Fix' },
    { 'cqf', desc = 'Apply suggested fix' },
    { 'cr', group = 'Rename' },
    { 'crn', desc = 'Rename symbol' },
    { 'ca', desc = 'Code actions on {motion}' },
    { 'cac', desc = 'Code actions for the file' },
    { 'ccl', desc = 'Run code lens' },
    { 'cf', desc = 'Format {motion}' },
    { 'cv', desc = 'Select code, press again to grow' },

    -- CoC lists
    { 'cc', desc = 'CoC commands' },
    { 'ce', desc = 'CoC extensions' },
    { 'cp', desc = 'Reopen the last list' },
    { 'cj', desc = 'Next item of the last list' },
    { 'ck', desc = 'Previous item of the last list' },

    -- Surround
    { 'cs', desc = 'Change surrounding' },
    { 'cS', desc = 'Change surrounding, on new lines' },
    { 'ds', desc = 'Delete surrounding' },
    { 'ys', desc = 'Add surrounding to {motion}' },
    { 'yS', desc = 'Add surrounding on new lines' },
    { 'yss', desc = 'Surround the line' },

    -- Leader keys
    { ',?', desc = 'Cheatsheet' },
    { ',f', desc = 'Recent files' },
    { ',o', desc = 'Open buffers' },
    { ',v', desc = 'Split left and right' },
    { ',', group = 'Leader' },
    { ',s', desc = 'Spelling, or Enter to split top and bottom' },
    { ',s<CR>', desc = 'Split top and bottom' },
    { ',p', group = 'Paste mode' },
    { ',pp', desc = 'Toggle paste mode' },
    { ',n', desc = 'File tree, or Enter for the next Emmet point' },
    { ',n<CR>', desc = 'Emmet: next edit point' },
    { ',nn', desc = 'Toggle the file tree' },
    { ',nf', desc = 'Show this file in the tree' },
    { ',ng', desc = 'Open the tree at the Git root' },
    { ',nb', desc = 'Open the tree at a bookmark' },
    { ',t', group = 'Telescope' },
    { ',tf', desc = 'Find files' },
    { ',tb', desc = 'Open buffers' },
    { ',th', desc = "Vim's help topics" },
    { ',g', group = 'Git' },
    { ',gg', desc = 'Toggle change markers' },
    { ',gv', desc = 'Side-by-side diff' },
    { ',h', group = 'Git change (needs ,gg)' },
    { ',hp', desc = 'Preview the change' },
    { ',hs', desc = 'Stage the change' },
    { ',hu', desc = 'Undo the change' },
    { ',st', desc = 'Toggle spell check' },
    { ',sn', desc = 'Next misspelled word' },
    { ',sp', desc = 'Previous misspelled word' },
    { ',ss', desc = 'Suggest corrections' },
    { ',sa', desc = 'Add word to dictionary' },

    -- Emmet
    { ',,', desc = 'Emmet: expand' },
    { ',N', desc = 'Emmet: previous edit point' },
    { ',d', desc = 'Emmet: select tag inward' },
    { ',D', desc = 'Emmet: select tag outward' },
    { ',u', desc = 'Emmet: update tag' },
    { ',k', desc = 'Emmet: remove tag' },
    { ',j', desc = 'Emmet: split or join tag' },
    { ',/', desc = 'Emmet: toggle comment' },
    { ',a', desc = 'Emmet: URL to link' },
    { ',A', desc = 'Emmet: URL to summary' },
    { ',m', desc = 'Emmet: merge lines' },
    { ',;', desc = 'Emmet: expand word' },
    { ',i', desc = 'Emmet: image size' },
    { ',I', desc = 'Emmet: encode image' },

    -- With text selected
    {
      mode = 'x',
      { ',?', desc = 'Cheatsheet' },
      { ',r', desc = 'Replace the selection in this file' },
      { ',', group = 'Leader' },
      { ',s', desc = 'Spelling, or Enter to wrap in ( )' },
      { ',s<CR>', desc = 'Wrap in ( )' },
      { ',,', desc = 'Emmet: expand' },
      { ',c', desc = 'Emmet: pretty-print code' },
      { ',d', desc = 'Emmet: select tag inward' },
      { ',D', desc = 'Emmet: select tag outward' },
      { 'ca', desc = 'Code actions' },
      { 'cf', desc = 'Format' },
      { 'cv', desc = 'Grow the selection' },
      { 'gS', desc = 'Surround on new lines' },
      { '$1', desc = 'Wrap in ( )' },
      { '$2', desc = 'Wrap in [ ]' },
      { '$3', desc = 'Wrap in { }' },
      { '$$', desc = 'Wrap in double quotes' },
      { '$q', desc = 'Wrap in single quotes' },
      { '$e', desc = 'Wrap in backticks' },
    },
  })
end)
EOF
