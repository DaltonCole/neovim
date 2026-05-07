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

" Initialize plugin system
call plug#end()
