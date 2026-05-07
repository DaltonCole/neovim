" =============================================================================
" init.vim
" =============================================================================
" Structure:
"   1. Plugin Declarations  (plug#begin ... plug#end)
"   2. Plugin Configuration (settings, keymaps per plugin)
"   3. Core Vim Settings    (editor behavior, UI, etc.)
"   4. Keymaps & Functions  (non-plugin bindings and helpers)
" =============================================================================

" =============================================================================
" 1. PLUGIN DECLARATIONS
" =============================================================================
" ### Key Bindings Cheat Sheet ###
" --- No Leader ---
"   gt          : Next tab
"   gT          : Previous Tab
"   zg          : Add word to dictionary
"   z=          : Spell check
" --- Leader (,) ---
"   ,dd         : Start/continue debugger
" --- File Exploration ---
"   ,nn         : Open NERDTree file explorer
"   ,f          : Recently opened files (MRU)
"   ,o          : Search for files in buffer (BufExplorer)
"   ctrl-f      : Search for files in current directory (CtrlP)

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

" --- Python ---
" python-mode: <leader>r run, <leader>b breakpoint, <leader>K docs, :help pymode
Plug 'klen/python-mode'

" --- Completion (CoC) ---
" Docs: https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" --- LSP (LanguageClient - used for Rust) ---
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
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
" universal-ctags: ctrl-] jump to def, ctrl-t jump back, :ts list tags
Plug 'universal-ctags/ctags'
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

" --- Debugger (requires neovim >= 0.8) ---
" <leader>dd continue, <leader>db breakpoint, <leader>dh run-to-cursor
" <leader>dr restart, <leader>dp pause, <leader>ds stop
" <leader>do step-over, <leader>dn step-into, <leader>de step-out
" <leader>di inspect (normal + visual)
Plug 'puremourning/vimspector'

" --- AI ---
" <leader>a  AI complete (normal/visual)
" <leader>c  AI chat    (normal/visual)
" <leader>r  AI redo
Plug 'madox2/vim-ai'

call plug#end()

" Auto-install any missing plugins on startup
autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif


" =============================================================================
" 2. PLUGIN CONFIGURATION
" =============================================================================

" --- Leader ---
let mapleader = ","

" --- Colorscheme (must come after plug#end) ---
set background=dark
colorscheme peaksea

" --- Rainbow Parentheses ---
let g:rainbow_active = 1

" --- Emmet ---
let g:user_emmet_leader_key=','

" --- Python-Mode ---
let g:pymode = 0
let g:pymode_lint = 1
let g:pymode_lint_on_write = 1
let g:pymode_lint_ignore = ["E501", "E402"]
let g:pymode_lint_cwindow = 0
let g:pymode_options_colorcolumn = 0
let g:pymode_indent = 1
let g:pymode_doc = 1
let g:pymode_trim_whitespaces = 1

" --- CoC ---
" Use tab for trigger completion
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()
inoremap <silent><expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Don't use arrow keys to select autocomplete items
inoremap <expr> <Up>   pumvisible() ? "\<C-y>\<Up>"   : "\<Up>"
inoremap <expr> <Down> pumvisible() ? "\<C-y>\<Down>" : "\<Down>"

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

" Scroll float windows
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-J> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-K> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-J> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-K> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-J> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-K> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Selection ranges
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Commands
command! -nargs=0 Format :call CocActionAsync('format')
command! -nargs=? Fold   :call CocAction('fold', <f-args>)
command! -nargs=0 OR     :call CocActionAsync('runCommand', 'editor.action.organizeImport')
autocmd BufWritePre *.cpp,*.py,*.rs,*.h,*.hpp :OR

" Status line integration
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" CocList mappings
nnoremap <silent><nowait> cd :<C-u>CocList diagnostics<cr>
nnoremap <silent><nowait> ce :<C-u>CocList extensions<cr>
nnoremap <silent><nowait> cc :<C-u>CocList commands<cr>
nnoremap <silent><nowait> co :<C-u>CocList outline<cr>
nnoremap <silent><nowait> cs :<C-u>CocList -I symbols<cr>
nnoremap <silent><nowait> cj :<C-u>CocNext<CR>
nnoremap <silent><nowait> ck :<C-u>CocPrev<CR>
nnoremap <silent><nowait> cp :<C-u>CocListResume<CR>

set hidden  " Required for operations modifying multiple buffers

" --- LanguageClient (Rust only; CoC handles everything else) ---
" NOTE: Dockerfile LSP intentionally omitted — coc-docker handles it instead.
let g:LanguageClient_serverCommands = {
\ 'rust': ['rust-analyzer'],
\ }
let g:LanguageClient_autoStart = 0  " Don't warn about unconfigured filetypes

" --- Rust ---
let g:rustfmt_autosave = 1

" --- ALE Linter ---
let g:ale_linters = {
\    'rust':       ['analyzer'],
\    'javascript': ['eslint'],
\    'python':     ['flake8'],
\    'go':         ['go', 'golint', 'errcheck']
\}
nmap <silent> <leader>a <Plug>(ale_next_wrap)
let g:ale_lint_on_text_changed = "normal"
let g:ale_lint_delay = 5

" --- MRU (Most Recently Used) ---
let MRU_File = '~/.config/nvim/other/vim_mru_files'
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

" --- Lightline ---
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

" --- GitGutter ---
let g:gitgutter_enabled = 0
nnoremap <silent> <leader>gg :GitGutterToggle<cr>

" --- Fugitive ---
nnoremap <silent> <leader>gv :Gvdiffsplit<cr>

" --- Gutentags ---
if !executable('ctags')
    let g:gutentags_dont_load = 1
endif

" --- Tagbar ---
map <leader>tt :TagbarToggle<CR>

" --- Clang-Format ---
autocmd FileType c ClangFormatAutoEnable
let g:clang_format#auto_format = 1

" --- Better Escape ---
let g:better_escape_shortcut = 'jj'
let g:better_escape_interval = 500

" --- Tabular (Align) ---
vnoremap t :Tab /

" --- vim-markdown ---
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_new_list_item_indent = 0

" --- Javascript ---
let g:javascript_plugin_jsdoc = 1
let g:javascript_plugin_flow  = 1

" --- CtrlSF (search across files) ---
nmap <C-s> <Plug>CtrlSFVwordPath
xmap <C-s> <Plug>CtrlSFVwordPath

" --- Telescope ---
nnoremap <leader>tf <cmd>Telescope find_files<cr>
nnoremap <leader>tg <cmd>Telescope live_grep<cr>
nnoremap <leader>tb <cmd>Telescope buffers<cr>
nnoremap <leader>th <cmd>Telescope help_tags<cr>

" --- Vimspector (Debugger) ---
let g:vimspector_base_dir      = '/home/docker/.nvim/plugged/vimspector'
let g:vimspector_sidebar_width = 75
let g:vimspector_bottombar_height = 5
nmap <Leader>dd <Plug>VimspectorContinue
nmap <Leader>db <Plug>VimspectorToggleBreakpoint
nmap <Leader>dh <Plug>VimspectorRunToCursor
nmap <Leader>dr <Plug>VimspectorRestart
nmap <Leader>dp <Plug>VimspectorPause
nmap <Leader>ds <Plug>VimspectorStop
nmap <Leader>do <Plug>VimspectorStepOver
nmap <Leader>dn <Plug>VimspectorStepInto
nmap <Leader>de <Plug>VimspectorStepOut
nmap <Leader>di <Plug>VimspectorBalloonEval
xmap <Leader>di <Plug>VimspectorBalloonEval

" --- vim-ai ---
let s:initial_complete_prompt =<< trim END
>>> system

You are a general assistant.
Answer shortly, consisely and only what you are asked.
Do not provide any explanantion or comments if not requested.
If you answer in a code, do not wrap it in markdown code block.
END

let chat_engine_config = {
\  "engine": "chat",
\  "options": {
\    "model": "meta-llama/Llama-3.3-70B-Instruct",
\    "endpoint_url": "https://shirty.sandia.gov/api/v1/chat/completions",
\    "max_tokens": 0,
\    "temperature": 0.1,
\    "request_timeout": 20,
\    "selection_boundary": "",
\    "initial_prompt": s:initial_complete_prompt,
\  },
\}

let g:vim_ai_complete = chat_engine_config
let g:vim_ai_edit     = chat_engine_config

nnoremap <leader>a :AI<CR>
xnoremap <leader>a :AI<CR>
xnoremap <leader>c :AIChat<CR>
nnoremap <leader>c :AIChat<CR>
nnoremap <leader>r :AIRedo<CR>


" =============================================================================
" 3. CORE VIM SETTINGS
" =============================================================================

" --- Filetype ---
filetype plugin indent on
filetype plugin on
filetype indent on

" --- Encoding ---
set encoding=utf8
set ffs=unix,dos,mac

" --- Colors ---
syntax enable
if $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif

" --- UI ---
set ruler
set cmdheight=1
set laststatus=2
set wildmenu
set wildignore=*.o,*~,*.pyc
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
set showmatch
set mat=2
set noerrorbells
set novisualbell
set t_vb=
set tm=500
set lazyredraw
set scrolloff=999        " Always center cursor vertically
set signcolumn=number    " Merge sign column and number column
set splitbelow           " Always split below
set mouse=v              " Mouse drag/selection in new windows
set updatetime=300
set shortmess+=c

" --- Left column ---
" set number
" set relativenumber

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

" --- Misc ---
set hid
set backspace=eol,start,indent
set whichwrap+=<,>,h,l,[,]
set autoread
au FocusGained,BufEnter * checktime
set nofoldenable
set pastetoggle=<F2>

" --- Spell Check ---
set spelllang=en
set spell
try
    set spellfile=~/.config/nvim/en.utf-8.add
catch
endtry
set spellsuggest+=10

" --- Status Line (fallback if lightline not active) ---
" set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c


" =============================================================================
" 4. KEYMAPS & FUNCTIONS
" =============================================================================

" --- Leader Shortcuts ---
map <leader>pp :setlocal paste!<cr>
map <leader>st :setlocal spell!<cr>   " Toggle spellcheck
map <leader>sn ]s                     " Next spelling error
map <leader>sp [s                     " Previous spelling error
map <leader>sa zg                     " Add word to dictionary
map <leader>ss z=                     " Spell suggestions

" --- Window Navigation ---
map <leader>v <C-w>v
map <leader>s <C-w>s
let g:BASH_Ctrl_j = 'off'
let g:BASH_Ctrl_k = 'off'
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" --- Searching ---
map <space>   /
map <C-space> ?

" --- Movement ---
map 0 ^   " 0 goes to first non-blank character
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" --- Editing ---
nmap <M-J> mz:m+<cr>`z    " Move line down
nmap <M-K> mz:m-2<cr>`z   " Move line up

" --- Visual Mode ---
vnoremap <silent> <leader>r :call VisualSelection('replace', '')<CR>
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>

" --- Parenthesis / Brackets (visual surround) ---
vnoremap $1 <esc>`>a)<esc>`<i(<esc>
vnoremap $2 <esc>`>a]<esc>`<i[<esc>
vnoremap $3 <esc>`>a}<esc>`<i{<esc>
vnoremap $$ <esc>`>a"<esc>`<i"<esc>
vnoremap $q <esc>`>a'<esc>`<i'<esc>
vnoremap $e <esc>`>a`<esc>`<i`<esc>
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

" --- VisualSelection helper ---
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
