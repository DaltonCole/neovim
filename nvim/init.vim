"### Key Bindings Cheat Sheet ###"
" --- No Leader --- "
" gt: Next tab
" gT: Previous Tab
" zg: Add word to dictionary
" z=: Spell check
" --- Leader --- "
" dd: Start/continue debugger
"
" --- File Exploration ---
"  ,nn: Open nerd tree file explorer
"  ,f: Recently opened files
"  ,o: Search for files in buffer
"  ctrl-f: Search for files in current directory


"### Plugins ###
call plug#begin('~/.nvim/plugged')
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'

" Colorful Parenthesis
Plug 'luochen1990/rainbow'

""" HTML """
" Emmet
" * `,,` is the way to run command in insert-mode
" * HTML Boilerplate: `html:5,,''`
" * Create a tag: `div,,`, `p,,`, etc.
" * Child tags: `div>p>a,,` Will exapand to <div><p><a...
"   * To make many items in an item: `ul>li*5,,`
" * Use `.` for class and `#` for id: `div.container>p#foo>a,,`
Plug 'mattn/emmet-vim'
" Close HTML tags via `>`
"   Use `>>` to put close tag on new line
Plug 'alvan/vim-closetag'

" Python-Mode
" * Run Code: <leader>r
" * Add/Remove Break Point: <leader>b
" * Search Documentation: <leader>K
" * HELP: `:help pymode`
Plug 'klen/python-mode'


""" Coc.nvim (Auto Complete) """
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Find coc config files at: https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions#implemented-coc-extensions

Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
Plug 'junegunn/fzf'

""" END COC """

""" Rust """
"Plug 'neovim/nvim-lspconfig'


Plug 'rust-lang/rust.vim'
""""""

" Colorscheme
Plug 'crucerucalin/peaksea.vim'

" Surround (TODO)
" In visual mode, select text and use S + symbol to surround text.
"   * Example:  S then ) adds () around the text
"   *           S then ( adds (  ) around the text
Plug 'tpope/vim-surround'

" Parenthesis
Plug 'chun-yang/auto-pairs'

" MRU Plugin - Most Recently Used files
" <leader>f to open recently used files search.
"   Enter to open or "O" to open vertically split
Plug 'yegappan/mru'

" BufExplorer - Find files in buffer
Plug 'jlanzarotta/bufexplorer'

" CTRL-P - Open files in buffer
Plug 'ctrlpvim/ctrlp.vim'

" Nerd tree - Show directories
Plug 'preservim/nerdtree'

" Lightline - Status line
Plug 'itchyny/lightline.vim'

" Show git changes
Plug 'airblade/vim-gitgutter'

" Fugitive - Git (Remove?)
Plug 'tpope/vim-fugitive'

" Universal Ctags - Helps neovim find ctags. Might need compiling: https://github.com/universal-ctags/ctags#how-to-build-and-install
Plug 'universal-ctags/ctags'
" Auto create/update Ctags
Plug 'ludovicchabant/vim-gutentags'
" Ctags usage:
" * Ctrl-] Jump to the definition
" * Ctrl-t Jump back
" : :ts List all definitions of the current tag

" Tagbar - Add side bar to view tag info
Plug 'preservim/tagbar'

" Clang-format
Plug 'rhysd/vim-clang-format'

" Better C++ highlighting
Plug 'jackguo380/vim-lsp-cxx-highlight'
" Escape insert mode using "jj"
Plug 'jdhao/better-escape.vim'

" Better markdown
Plug 'godlygeek/tabular'
Plug 'preservim/vim-markdown'
" CamelCase and snake_case 'w'
Plug 'chaoren/vim-wordmotion'

" Better vim-diff
Plug 'chrisbra/vim-diff-enhanced'

" Search files
Plug 'dyng/ctrlsf.vim'

" More search files
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.6' }

" Debugger
Plug 'puremourning/vimspector'

" AI
Plug 'madox2/vim-ai'

"### Plugins ###
" Colorful Parenthesis
let g:rainbow_active = 1

""" HTML """
" Emmet
" * `,,` is the way to run command in insert-mode
" * HTML Boilerplate: `html:5,,''`
" * Create a tag: `div,,`, `p,,`, etc.
" * Child tags: `div>p>a,,` Will exapand to <div><p><a...
"   * To make many items in an item: `ul>li*5,,`
" * Use `.` for class and `#` for id: `div.container>p#foo>a,,`
let g:user_emmet_leader_key=','
" Close tags via `>`
"   Use `>>` to put close tag on new line

" Python-Mode
" * Run Code: <leader>r
" * Add/Remove Break Point: <leader>b
" * Search Documentation: <leader>K
" * HELP: `:help pymode`
let g:pymode = 0
let g:pymode_lint = 1
let g:pymode_lint_on_write = 1
"autocmd FileType python setlocal nonumber
let g:pymode_lint_ignore = ["E501", "E402"]  " Ignore: Line length limit, module import not at top of file
let g:pymode_lint_cwindow = 0  " Do not open preview window for PEP errors
let g:pymode_options_colorcolumn = 0  " No colored column at max line length
let g:pymode_indent = 1  " PEP8-Compatible python indent
let g:pymode_doc = 1  " Show pydoc documentation
"let g:pymode_options_max_line_length = 120
"let g:pymode_lint_ignore = "E501"
"let g:pep8_ignore="E501"
"let g:pymode_lint_options_pep8 = {'max_line_length': 120}
"let g:syntastic_python_pylint_post_args="--max-line-length=120"
let g:pymode_trim_whitespaces = 1  "Trim unused white space at end of lines

" Grammar Check
" * To Run: `:GrammarousCheck`
" * Local mappings from the information window:
"   * Quit window: `q`
"   * Move to location of the error: `<Ctrl>`
"   * Fix the error automatically: `f`
"   * Mote to next/previous: `n`/`p`

" Pretty break indention
set breakindent

" Javascript
let g:javascript_plugin_jsdoc = 1 " Syntax highlighting
let g:javascript_plugin_flow = 1 " Flow syntax highlighting

" Linter
let g:ale_linters = {
\    'rust': ['analyzer'],
\    'javascript': ['eslint'],
\    'python': ['flake8'],
\    'go': ['go', 'golint', 'errcheck']
\}

" Go to next error with <leader>a
nmap <silent> <leader>a <Plug>(ale_next_wrap)
" Run ale when we've been in normal mode for 5 seconds
let g:ale_lint_on_text_changed = "normal"
let g:ale_lint_delay = 5

""" Coc.nvim (Auto Complete) """
" Find coc config files at: https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions#implemented-coc-extensions

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
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
inoremap <expr> <Up> pumvisible() ? "\<C-y>\<Up>" : "\<Up>"
inoremap <expr> <Down> pumvisible() ? "\<C-y>\<Down>" : "\<Down>"

" Make <CR> (i.e. Enter) auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
"inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
"                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use H to show documentation in preview window.
nnoremap <silent> H :call ShowDocumentation()<CR>
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('H', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap crn <Plug>(coc-rename)

" Formatting selected code.
xmap cf  <Plug>(coc-format-selected)
nmap cf  <Plug>(coc-format-selected)
augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region. (TODO: CodeAction??)
" Example: `caap` for current paragraph
xmap ca  <Plug>(coc-codeaction-selected)
nmap ca  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap cac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap cqf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap ccl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-J> and <C-K> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-J> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-K> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-J> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-K> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-J> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-K> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')
autocmd BufWritePre *.cpp,*.py,*.rs,*.h,*.hpp :OR

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> cd  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> ce  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> cc  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> co  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> cs  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> cj  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> ck  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> cp  :<C-u>CocListResume<CR>


set hidden " Required for operations modifying multiple buffers like rename.

""" END COC """

""" Rust """
let g:LanguageClient_serverCommands = {
\ 'rust': ['rust-analyzer'],
\ }


" Rustfmt on save
let g:rustfmt_autosave = 1

""""""

" Colorscheme
set background=dark
colorscheme peaksea

" Status bar
"let g:airline#extensions#ale#enabled = 1  " Move errors to status bar


" MRU Plugin - Most Recently Used files
" <leader>f to open recently used files search.
"   Enter to open or "O" to open vertically split
let MRU_File = '~/.config/nvim/other/vim_mru_files'
let MRU_Max_Entries = 400
map <leader>f :MRU<CR>

" BufExplorer - Find files in buffer
let g:bufExplorerDefaultHelp=0
let g:bufExplorerShowRelativePath=1
let g:bufExplorerFindActive=1
let g:bufExplorerSortBy='name'
map <leader>o :BufExplorer<cr>

" Quickly find and open a file in the current working directory
let g:ctrlp_map = '<C-f>'
let g:ctrlp_max_height = 20
let g:ctrlp_custom_ignore = 'node_modules\|^\.DS_Store\|^\.git\|^\.coffee'

" Nerd tree - Show directories
let g:NERDTreeWinPos = "right"
let NERDTreeShowHidden=0
let NERDTreeIgnore = ['\.pyc$', '__pycache__']
let g:NERDTreeWinSize=35
let NERDTreeShowBookmarks = 1   " Show the bookmarks table
let NERDTreeShowHidden = 1      " Show hidden files
let NERDTreeShowLineNumbers = 1 " Hide line numbers
let NERDTreeMinimalMenu = 1     " Use the minimal menu (m)
map <leader>nn :NERDTreeToggle<cr>
map <leader>ng :NERDTreeVCS<cr>
map <leader>nb :NERDTreeFromBookmark<Space>
map <leader>nf :NERDTreeFind<cr>


" Lightline - Status line

function! CocCurrentFunction()
    return get(b:, 'coc_current_function', '')
endfunction

let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ ['mode', 'paste'],
      \             ['readonly', 'filename', 'modified', 'cocstatus', 'currentfunction'] ],
      \   'right': [ [ 'lineinfo' ], ['percent'], ['fugitive'] ]
      \ },
      \ 'component': {
      \   'readonly': '%{&filetype=="help"?"":&readonly?"🔒":""}',
      \   'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}',
      \   'fugitive': '%{exists("*FugitiveHead")?FugitiveHead():""}'
      \ },
      \ 'component_function': {
      \   'cocstatus': 'coc#status',
      \   'currentfunction': 'CocCurrentFunction'
      \ },
      \ 'component_visible_condition': {
      \   'readonly': '(&filetype!="help"&& &readonly)',
      \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
      \   'fugitive': '(exists("*FugitiveHead") && ""!=FugitiveHead())'
      \ },
      \ 'separator': { 'left': ' ', 'right': ' ' },
      \ 'subseparator': { 'left': ' ', 'right': ' ' }
      \ }
" Use autocmd to force lightline update.
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

" Show git changes
let g:gitgutter_enabled=0
" Use <leader>gg to show git changes
nnoremap <silent> <leader>gg :GitGutterToggle<cr>

" Fugitive - Git
nnoremap <silent> <leader>gv :Gvdiffsplit<cr>

" Universal Ctags - Helps neovim find ctags. Might need compiling: https://github.com/universal-ctags/ctags#how-to-build-and-install
" Auto create/update Ctags
" Gutentags
" Don't load me if there's no ctags file
if !executable('ctags')
    let g:gutentags_dont_load = 1
endif

" Tagbar - Add side bar to view tag info
map <leader>tt :TagbarToggle<CR>

" Clang-format
autocmd FileType c ClangFormatAutoEnable
let g:clang_format#auto_format=1

" Split using ctrl+shift+v or ctrl+shift+s
nnoremap ,v <C-w>v
nnoremap ,s <C-w>s

" Escape insert mode using "jj"
Plug 'jdhao/better-escape.vim'
let g:better_escape_shortcut = 'jj'
let g:better_escape_interval = 500

" Align symbols - Tabular
vnoremap t :Tab /

" Better markdown
Plug 'preservim/vim-markdown'
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_new_list_item_indent = 0

" CamelCase and snake_case 'w'
Plug 'chaoren/vim-wordmotion'

" Better vim-diff
Plug 'chrisbra/vim-diff-enhanced'

" Move block all at once
"Plug 'matze/vim-move'
"let g:move_map_keys = 0
"smap <C-j> <Plug>MoveBlockDown
"smap <C-k> <Plug>MoveBlockUp

" Tabs
"Plug 'lewis6991/gitsigns.nvim' " OPTIONAL: for git status
"Plug 'nvim-tree/nvim-web-devicons' " OPTIONAL: for file icons
"Plug 'romgrk/barbar.nvim'

" Search files
Plug 'dyng/ctrlsf.vim'
nmap <C-s> <Plug>CtrlSFVwordPath
xmap <C-s> <Plug>CtrlSFVwordPath

" More search files
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.6' }
nnoremap <leader>tf <cmd>Telescope find_files<cr>
nnoremap <leader>tg <cmd>Telescope live_grep<cr>
nnoremap <leader>tb <cmd>Telescope buffers<cr>
nnoremap <leader>th <cmd>Telescope help_tags<cr>

" --- Debugger - Needs neovim 0.8 --- "
let g:vimspector_base_dir='/home/docker/.nvim/plugged/vimspector'
let g:vimspector_sidebar_width = 75
let g:vimspector_bottombar_height = 5
" Start Debugging
nmap <Leader>dd <Plug>VimspectorContinue
" Debug Breakpoint
nmap <Leader>db <Plug>VimspectorToggleBreakpoint
" Debug Here
nmap <Leader>dh <Plug>VimspectorRunToCursor
" Debug Restart
nmap <Leader>dr <Plug>VimspectorRestart
" Debug Pause
nmap <Leader>dp <Plug>VimspectorPause
" Debug Stop
nmap <Leader>ds <Plug>VimspectorStop
" Debug Over: Go to next line in code, skipping over function call
nmap <Leader>do <Plug>VimspectorStepOver
" Debug Next(Into): Go to next executed line in code, entering function calls
nmap <Leader>dn <Plug>VimspectorStepInto
" Debug Exit Function(Step Out): Go to next line out of funciton scope
nmap <Leader>de <Plug>VimspectorStepOut
" Debug Inspect - Normal Mode
nmap <Leader>di <Plug>VimspectorBalloonEval
" Debug Inspect - Visual Mode
xmap <Leader>di <Plug>VimspectorBalloonEval

""" Moving Around """
" Split using ctrl+shift+v or ctrl+shift+s
map <Leader>v <C-w>v
map <Leader>s <C-w>s

" Move between windows using Ctrl+jkhl
let g:BASH_Ctrl_j = 'off'
let g:BASH_Ctrl_k = 'off'
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
" Return to last edit position when opening files
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
" 0 goes to first non-blank character
map 0 ^

" AI
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
let g:vim_ai_edit = chat_engine_config

" complete text on the current line or in visual selection
nnoremap <leader>a :AI<CR>
xnoremap <leader>a :AI<CR>

" edit text with a custom prompt
"xnoremap <leader>s :AIEdit fix grammar and spelling<CR>
"nnoremap <leader>s :AIEdit fix grammar and spelling<CR>

" trigger chat
xnoremap <leader>c :AIChat<CR>
nnoremap <leader>c :AIChat<CR>

" redo last AI command
nnoremap <leader>r :AIRedo<CR>

"### Functions ###
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

" Initialize plugin system
call plug#end()
" Automatically install plugins
autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif


"### Configurations ###
" Paste
set pastetoggle=<F2>
map <leader>pp :setlocal paste!<cr>
" Allow cursor to wrap to next and previous line
set whichwrap+=<,>,h,l,[,]
" Set cursor to the middle of the screen
:set scrolloff=999
" Tab 4 spaces
filetype plugin indent on
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

""" Spellcheck """
set spelllang=en
set spell
" Specify where to add new words
try
    set spellfile=~/.config/nvim/en.utf-8.add
catch
endtry
" Limit to only 10 suggestions
set spellsuggest+=10
" Toggle / Untoggle spell checking using ,ss
map <leader>st :setlocal spell!<cr>
" Next spelling error
map <leader>sn ]s
" Previous spelling error
map <leader>sp [s
" Add word to dictionary
map <leader>sa zg
" Spell check
map <leader>ss z=

" Disable folding
set nofoldenable

""" History  """
" How many lines of history vim has to remember
set history=1000
" Persistent undo on
try
    set undodir=~/.config/nvim/undodir
    set undofile
catch
endtry

" Enable filetype plugins
filetype plugin on
filetype indent on

" Auto read file changes (when changed from outside)
set autoread
au FocusGained,BufEnter * checktime

" Always center cursor vertically
set scrolloff=999

" Menu for auto complete
set wildmenu
set wildignore=*.o,*~,*.pyc " Ignore compiled files
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store

" Show current position
set ruler

" Height of the command bar
set cmdheight=1

" Hide the buffer when it is abandoned
set hid

" Make backspace act like it should
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Searching
set ignorecase " Ignore case
set smartcase  " Be smart about cases
set hlsearch   " Highlight search results
set incsearch  " Search while typing
set magic      " Use regular expressions in search
" Space to search
map <space> /
" Use Ctrl-Space to backwards search
map <C-space> ?

""" Window Settings """
" Always split below
set splitbelow
" Enable mouse drag and selection on new windows
set mouse=v

" Don't redraw while executing macros
set lazyredraw

" Show matching bracket when hovered
set showmatch
set mat=2  " Blink rate for matching bracket

" No annoying sounds
set noerrorbells
set novisualbell
set t_vb=
set tm=500

""" Colors and Fonts """
"Enable syntax highlighting
syntax enable

" Enable 256 color palette
if $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif

" Encodings
set encoding=utf8
" Standard file type to Unix
set ffs=unix,dos,mac

" Backups - backup current file, deleted afterwards (default)
set nobackup
set writebackup

""" Indention """
set expandtab  " Use spaces instead of tabs
set smarttab   " Auto tab to the correct spot on new lines
set shiftwidth=4 " 1 tab = 4 spaces
set tabstop=4    " 1 tab = 4 spaces
set ai    " Auto indent - Copy previous indent layer
set si    " Smart indent - Be smart about auto intenting
set wrap  " Wrap lines that go off screen

""" Leader Stuff """
" Set leader
let mapleader = ","

""" Status Line """
" Always show the status line
set laststatus=2
" Format the status line
" set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c " Overwritten by air-line

""" Left Column """
"set number
"set relativenumber
" Always show the signcolumn, otherwise it would shift the text each time diagnostics appear/become resolved.
set signcolumn=number " Vim can merge signcolumn and number column into one

""" Save """
" Use :W to sudo save file
command! W executes 'w !sudo tee % > /dev/null' <bar> edit!

" Delete trailing white space on save
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

""" Edit """
" Move a line up or down using Alt + shift + JK
nmap <M-J> mz:m+<cr>`z
nmap <M-K> mz:m-2<cr>`z

""" Visual Mode """
" Select, then <leader>r to search and replace
vnoremap <silent> <leader>r :call VisualSelection('replace', '')<CR>
" Search for current word
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>

""" Cope """
"map <leader>cc :botright cope<cr>
"map <leader>co ggVGy:tabnew<cr>:set syntax=qf<cr>pgg
"map <leader>n :cn<cr>
"map <leader>p :cp<cr>


""" Parenthesis/Brackets """
vnoremap $1 <esc>`>a)<esc>`<i(<esc>
vnoremap $2 <esc>`>a]<esc>`<i[<esc>
vnoremap $3 <esc>`>a}<esc>`<i{<esc>
vnoremap $$ <esc>`>a"<esc>`<i"<esc>
vnoremap $q <esc>`>a'<esc>`<i'<esc>
vnoremap $e <esc>`>a`<esc>`<i`<esc>
" Auto complete (, ", ', [, {
inoremap $1 ()<esc>i
inoremap $2 []<esc>i
inoremap $3 {}<esc>i
inoremap $4 {<esc>o}<esc>O
inoremap $q ''<esc>i
inoremap $e ""<esc>i
inoremap { {}<Esc>ha
inoremap ( ()<Esc>ha
inoremap [ []<Esc>ha
inoremap " ""<Esc>ha
inoremap ' ''<Esc>ha
inoremap ` ``<Esc>ha
" Use 'P' to add Parenthesis around highlighted text
vnoremap <leader>s xi()<Esc>P

""" Other """
set updatetime=300 " Update swap file after 300 ms of idle time
set shortmess+=c  " Ignore some "Have to hit enter" options (TODO: Further explore)
" Make sure that enter is never overriden in the quickfix window
autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
