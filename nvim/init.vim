" =============================================================================
" init.vim
" =============================================================================
" Press ,? in normal mode for the command cheatsheet (or run :Cheatsheet).
"
" Sections:
"   1. Plugins          plug#begin ... plug#end
"   2. Basics           encoding, indentation, search, undo, saving
"   3. Appearance       colorscheme, UI options, statusline
"   4. Finding things   NERDTree, CtrlP, MRU, BufExplorer, CtrlSF, Telescope, tags
"   5. Code             CoC, formatters, languages
"   6. Windows & Git    splits, window movement, Fugitive, GitGutter
"   7. Editing          surround, pairs, Emmet, spell, align, insert helpers
"   8. Cheatsheet       the ,? popup and its contents
"
" When you add or change a key, update the cheatsheet in section 8.
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
Plug 'jackguo380/vim-lsp-cxx-highlight'  " Better C++ highlighting

" --- HTML ---
" Emmet: ,, to expand  |  html:5,,  div.foo>p#bar>a,,  ul>li*5,,
Plug 'mattn/emmet-vim'
" vim-closetag: > closes tag, >> puts close tag on new line
Plug 'alvan/vim-closetag'

" --- Completion (CoC) ---
" Docs: https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" --- Fuzzy finder (used by CtrlP / Telescope) ---
Plug 'junegunn/fzf'

" --- Rust ---
Plug 'rust-lang/rust.vim'

" --- Editing Utilities ---
Plug 'tpope/vim-surround'        " S+symbol in visual to surround
Plug 'chun-yang/auto-pairs'      " Auto close (, [, {, ", '
Plug 'jdhao/better-escape.vim'   " jj to escape insert mode
Plug 'chaoren/vim-wordmotion'    " CamelCase and snake_case word motion
Plug 'chrisbra/vim-diff-enhanced'" Better vim-diff

" --- File Navigation ---
Plug 'yegappan/mru'              " <leader>f  Most recently used files
Plug 'jlanzarotta/bufexplorer'   " <leader>o  Files in buffer
Plug 'ctrlpvim/ctrlp.vim'        " ctrl-f     Open files in cwd
Plug 'preservim/nerdtree'        " <leader>nn Directory tree
Plug 'dyng/ctrlsf.vim'           " <C-s>      Search across files

" --- Telescope ---
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.6' }

" --- Tags ---
" ctags (apt package, see Dockerfile): ctrl-] jump to def, ctrl-t jump back, :ts list tags
Plug 'ludovicchabant/vim-gutentags'  " Auto create/update ctags
Plug 'preservim/tagbar'              " <leader>tt  Sidebar tag viewer

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

" --- MRU (Most Recently Used) ---
let MRU_File = '~/.config/nvim/mru/vim_mru_files'
let MRU_Max_Entries = 400
map <leader>f :MRU<CR>

" --- BufExplorer ---
let g:bufExplorerDefaultHelp=0
let g:bufExplorerShowRelativePath=1
let g:bufExplorerFindActive=1
let g:bufExplorerSortBy='name'
map <leader>o :BufExplorer<cr>

" --- CtrlP ---
let g:ctrlp_map = '<C-f>'
let g:ctrlp_max_height = 20
let g:ctrlp_custom_ignore = 'node_modules\|^\.DS_Store\|^\.git\|^\.coffee'

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
nnoremap <leader>tf <cmd>Telescope find_files<cr>
nnoremap <leader>tg <cmd>Telescope live_grep<cr>
nnoremap <leader>tb <cmd>Telescope buffers<cr>
nnoremap <leader>th <cmd>Telescope help_tags<cr>

" --- Gutentags ---
if !executable('ctags')
    let g:gutentags_dont_load = 1
endif

" --- Tagbar ---
map <leader>tt :TagbarToggle<CR>

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
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

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
" ,? or :Cheatsheet shows the text below in a floating window.
" Format: titles start in column 1 in capitals; entries are two spaces, the
" keys, at least two spaces, then the description. Keep lines under 76 columns.

let s:cheatsheet =<< END
FIND A FILE
  Ctrl-f            fuzzy find in the current directory (CtrlP)
  ,f                recently opened files (MRU)
  ,tf               fuzzy find with preview (Telescope)
  ,nn               toggle the file tree (NERDTree)
  ,nf               show the current file in the tree
  ,ng               open the tree at the Git root
  ,nb               open the tree at a bookmark

SWITCH BETWEEN OPEN FILES
  ,o                list open buffers (BufExplorer)
  ,tb               fuzzy find open buffers (Telescope)
  ,bt               toggle the buffer list
  ,bs / ,bv         buffer list in a horizontal / vertical split
  ]b / [b           next / previous buffer
  Ctrl-^            back to the previous file

SEARCH IN THIS FILE
  Space             search forward
  Ctrl-Space        search backward
  n / N             next / previous match
  * / #             search for the word under the cursor
  * (visual)        search for the selected text
  ,r (visual)       replace the selected text in this file
  :noh              clear the search highlight

SEARCH ACROSS THE PROJECT
  Ctrl-s            search for the word under the cursor, Enter to run
  Ctrl-s (visual)   search for the selected text, Enter to run
  :CtrlSF text      search for any text
  :CtrlSFToggle     show or hide the last results
  ,tg               live search as you type (Telescope)
  ,th               search Vim's help topics (Telescope)

JUMP BY TAG (CTAGS)
  Ctrl-]            jump to the definition under the cursor
  Ctrl-t            jump back
  :ts name          list every tag with that name
  ,tt               toggle the outline sidebar (Tagbar)

KEYS INSIDE THE FILE TREE (NERDTREE)
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

KEYS INSIDE CTRLP
  Ctrl-j / Ctrl-k   move down / up the list
  Enter             open
  Ctrl-x / Ctrl-v   open in a horizontal / vertical split
  Ctrl-t            open in a new tab
  Ctrl-f / Ctrl-b   switch between files, buffers and recent files
  Ctrl-d            match file names only, not full paths
  Ctrl-r            use a regular expression
  Ctrl-z / Ctrl-o   mark several files / open the marked files
  F5                rescan the directory
  Esc               close

KEYS INSIDE TELESCOPE
  Ctrl-n / Ctrl-p   move down / up the list
  Enter             open
  Ctrl-x / Ctrl-v   open in a horizontal / vertical split
  Ctrl-t            open in a new tab
  Ctrl-u / Ctrl-d   scroll the preview
  Tab               mark a result
  Ctrl-q / Alt-q    send all / marked results to the quickfix list
  Ctrl-c            close
  Ctrl-/            list every key

KEYS INSIDE THE BUFFER LIST (BUFEXPLORER)
  Enter / o         open
  f / v             open in a split below / to the right
  t                 open in a new tab
  d                 close the buffer
  s / r             change the sort / reverse the sort
  q                 close the list
  F1                show help

KEYS INSIDE THE RECENT FILES LIST (MRU)
  Enter             open
  o / O             open in a horizontal / vertical split
  t / v             open in a tab / read-only
  p                 open in the preview window
  u / d             refresh the list / remove the entry
  q                 close the list

KEYS INSIDE SEARCH RESULTS (CTRLSF)
  Ctrl-h            move into the results (they open on the left)
  Enter / o         open the match
  O                 open the match and close the results
  t / p             open in a new tab / preview
  Ctrl-j / Ctrl-k   next / previous match
  Ctrl-n / Ctrl-p   next / previous file
  M                 switch between normal and compact view
  (edit) then :w    change text in the results and save it to the files
  q                 close the results

KEYS INSIDE THE OUTLINE (TAGBAR)
  Enter / p         jump to the tag / jump but stay in the sidebar
  o                 open or close the fold
  s                 sort by name or by file order
  q                 close the sidebar
  ?                 show help

UNDERSTAND CODE (COC)
  gd                go to the definition
  gy                go to the type definition
  gi                go to the implementation
  gr                list every reference
  H                 show docs for the word under the cursor
  Ctrl-d / Ctrl-u   scroll an open docs popup (otherwise half a page)
  Ctrl-j / Ctrl-k   scroll an open docs popup in insert mode
  co                outline of this file
  cy                project-wide symbol search (needs a language server)

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

COMPLETION (INSERT MODE)
  Tab               start completion, then next suggestion
  Shift-Tab         previous suggestion
  Ctrl-n / Ctrl-p   next / previous suggestion
  Ctrl-y            accept the suggestion
  Ctrl-e            dismiss the list

SELECT BY CODE STRUCTURE (COC)
  if / af           inside / around a function (vif, daf, yaf)
  ic / ac           inside / around a class

COC LISTS
  cc                every CoC command
  ce                installed extensions
  cp                reopen the last list
  cj / ck           run the next / previous item of the last list

RUST LANGUAGE SERVER
  :CocCommand rust-analyzer.upgrade   update the server on your host

KEYS INSIDE A COC LIST
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

KEYS INSIDE :GIT STATUS
  s / u             stage / unstage the file or hunk
  =                 show or hide an inline diff
  dv                side-by-side diff
  X                 discard the change
  cc                commit
  ca                amend the last commit
  gq                close the status window
  g?                list every key

IN A DIFF
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
  S" (visual)       wrap the selection in quotes
  ,s (visual)       wrap the selection in ( )
  $1 $2 $3 (visual)  wrap the selection in ( ) [ ] { }
  $$ $q $e (visual)  wrap the selection in " " ' ' ` `

BRACKET AND QUOTE HELPERS (INSERT MODE)
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

ALIGN (TABULAR)
  t (visual)        align on a character: type it, then press Enter
  :Tab /=           align on =

MOVE AND EDIT
  jj                leave insert mode
  0                 first non-blank character on the line
  |                 first column of the line
  w / b / e         stop at camelCase and snake_case parts
  Alt-Shift-j / k   move the line down / up
  gcc               comment or uncomment the line
  gc (visual)       comment or uncomment the selection
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
  ,tg               type the text, then Ctrl-q to fill the quickfix list
  :cdo s/old/new/g | update  replace it in every result and save

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
  PageDown          page down (Ctrl-f is CtrlP here)

VIM: MOVING AROUND
  Ctrl-o / Ctrl-i   back / forward through your jumps
  g; / g,           older / newer edit location
  %                 matching bracket
  gg / G            top / bottom of the file
  :42               go to line 42
  { / }             previous / next blank line
  f{c} / t{c}       to / just before a character on this line
  ;                 repeat that find

VIM: SELECTING
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
  Ctrl-r a          paste register a in insert mode
  :reg              list registers

VIM: SUBSTITUTE
  :s/a/b/g          replace on this line
  :%s/a/b/g         replace in the whole file
  :%s/a/b/gc        same, asking before each one
  :'<,'>s/a/b/g     replace in the selection
  &                 repeat the last substitute on this line

VIM: QUICKFIX LIST
  :copen / :cclose  open / close the list
  ]q / [q           next / previous entry
  :cdo cmd          run a command on each entry

VIM: FOLDS
  zi                turn folding on or off (off by default here)
  za                open or close this fold
  zM / zR           close / open every fold
END

function! s:OpenCheatsheet() abort
  let width = min([76, &columns - 4])
  let height = min([len(s:cheatsheet), &lines - 6])
  let buf = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(buf, 0, -1, v:false, s:cheatsheet)
  let win = nvim_open_win(buf, v:true, {
        \ 'relative': 'editor',
        \ 'width': width,
        \ 'height': height,
        \ 'row': max([(&lines - height) / 2 - 1, 0]),
        \ 'col': (&columns - width) / 2,
        \ 'style': 'minimal',
        \ 'border': 'rounded',
        \ 'title': ' Cheatsheet   / search   n next   q close ',
        \ 'title_pos': 'center',
        \ })
  setlocal bufhidden=wipe nomodifiable scrolloff=0
  setlocal winhighlight=NormalFloat:Normal,FloatBorder:Normal
  call matchadd('Title', '^\u.*$')
  call matchadd('Special', '^  \S.\{-}\ze\s\{2,}')
  nnoremap <buffer> <silent> <nowait> q :close<CR>
  nnoremap <buffer> <silent> <nowait> <Esc> :close<CR>
  nnoremap <buffer> <silent> <nowait> <leader>? :close<CR>
  execute 'autocmd WinLeave <buffer> ++once silent! call nvim_win_close(' . win . ', v:true)'
endfunction

command! Cheatsheet call s:OpenCheatsheet()
nnoremap <silent> <leader>? :Cheatsheet<CR>
