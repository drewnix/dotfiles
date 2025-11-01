" =============================================================================
" MODERN VIM CONFIGURATION (2024-2025)
" =============================================================================
" Author: Andrew Tanner
" Description: Modernized vim configuration with vim-plug, LSP support,
"              and optimizations for cloud-native development workflows
" =============================================================================

" PLUGIN MANAGEMENT {{{
" -----------------------------------------------------------------------------
" Auto-install vim-plug if not present (self-bootstrapping)
" -----------------------------------------------------------------------------
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" Essential utilities (Tim Pope's legendary plugins)
Plug 'tpope/vim-sensible'        " Sensible defaults everyone agrees on
Plug 'tpope/vim-commentary'      " gcc to toggle comments
Plug 'tpope/vim-surround'        " Manipulate surrounding chars/quotes
Plug 'tpope/vim-repeat'          " Make . work with plugin operations

" Fuzzy finding and search
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Linting and LSP
Plug 'dense-analysis/ale'        " Async linting engine

" Git integration
Plug 'tpope/vim-fugitive'        " The best Git wrapper ever
Plug 'airblade/vim-gitgutter'    " Git diff in sign column

" Status line
Plug 'itchyny/lightline.vim'     " Fast, clean statusline

" Language-specific plugins
Plug 'hashivim/vim-terraform'                          " Terraform support
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }     " Go development
Plug 'rust-lang/rust.vim'                              " Rust support
Plug 'JuliaLang/julia-vim'                             " Julia (keeping from old config)

" Color schemes
Plug 'morhetz/gruvbox'           " Warm, retro aesthetic (most popular)
Plug 'catppuccin/vim', { 'as': 'catppuccin' }  " Soothing pastels (mocha is dark like tokyo-night)

call plug#end()
" }}}

" BASIC SETTINGS {{{
" -----------------------------------------------------------------------------
" Core vim behavior settings
" -----------------------------------------------------------------------------
filetype plugin indent on
syntax enable

" Line numbers
set number
set relativenumber

" Buffer management
set hidden                        " Allow hidden buffers with unsaved changes

" Search settings
set incsearch                     " Incremental search
set ignorecase                    " Case-insensitive search...
set smartcase                     " ...unless query contains uppercase

" Indentation
set expandtab                     " Use spaces instead of tabs
set tabstop=4                     " Tab width
set shiftwidth=4                  " Indent width
set smartindent                   " Smart auto-indenting

" Performance and responsiveness
set updatetime=300                " Faster completion and git-gutter updates
set signcolumn=yes                " Always show sign column (prevents shift)

" Command line
set wildmenu                      " Enhanced command line completion
set wildmode=list:longest         " Complete longest common match, list alternatives
set history=1000                  " Longer command history

" Interface
set title                         " Set terminal title
set ruler                         " Show cursor position
set laststatus=2                  " Always show statusline
set showcmd                       " Show partial commands
set mouse=a                       " Enable mouse support
" }}}

" COLOR SCHEME AND APPEARANCE {{{
" -----------------------------------------------------------------------------
" True color support and theme configuration
" -----------------------------------------------------------------------------
" Enable true colors if terminal supports it
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" Set colorscheme
set background=dark

" Catppuccin Mocha - dark theme similar to Tokyo Night
colorscheme catppuccin_mocha

" Alternative colorschemes (uncomment to switch):
" colorscheme gruvbox
" colorscheme catppuccin_frappe
" colorscheme catppuccin_macchiato
" }}}

" PLATFORM-SPECIFIC SETTINGS {{{
" -----------------------------------------------------------------------------
" Handle differences between macOS and Linux
" -----------------------------------------------------------------------------
function! OSX()
    return has('macunix')
endfunction

function! LINUX()
    return has('unix') && !has('macunix')
endfunction

" Clipboard settings (works on both macOS and Linux)
if has('unnamedplus')
  set clipboard=unnamedplus       " Use system clipboard (Linux)
else
  set clipboard=unnamed           " Use system clipboard (macOS)
endif
" }}}

" LEADER KEY AND MAPPINGS {{{
" -----------------------------------------------------------------------------
" Custom key mappings for productivity
" -----------------------------------------------------------------------------
let mapleader = ","

" Quick save and quit
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>

" Vimrc editing and reloading
map <leader>ev :e ~/.vimrc<cr>
map <leader>rv :so ~/.vimrc<cr>

" Fuzzy finding (fzf)
nnoremap <C-p> :Files<CR>
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>g :Rg<CR>
nnoremap <Leader>l :Lines<CR>
nnoremap <Leader>h :History<CR>

" Better mark navigation (swap ' and ` for more useful default)
nnoremap ' `
nnoremap ` '

" Git operations (fugitive)
nnoremap <Leader>gs :Git<CR>
nnoremap <Leader>gc :Git commit<CR>
nnoremap <Leader>gp :Git push<CR>
nnoremap <Leader>gl :Git pull<CR>
nnoremap <Leader>gd :Gdiff<CR>
nnoremap <Leader>gb :Git blame<CR>
" }}}

" ALE CONFIGURATION {{{
" -----------------------------------------------------------------------------
" Asynchronous Lint Engine settings
" -----------------------------------------------------------------------------
" Only lint on save (better for SSH/remote editing)
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_save = 1
let g:ale_lint_on_enter = 0

" Auto-fix on save
let g:ale_fix_on_save = 1

" Language-specific fixers
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['black', 'isort'],
\   'javascript': ['prettier'],
\   'typescript': ['prettier'],
\   'go': ['gofmt', 'goimports'],
\   'rust': ['rustfmt'],
\   'terraform': ['terraform'],
\   'json': ['prettier'],
\   'yaml': ['prettier'],
\   'markdown': ['prettier'],
\}

" Language-specific linters (ALE auto-detects installed linters)
let g:ale_linters = {
\   'python': ['flake8', 'mypy', 'pyright'],
\   'javascript': ['eslint'],
\   'typescript': ['eslint', 'tsserver'],
\   'go': ['gopls', 'golint'],
\   'rust': ['analyzer'],
\   'sh': ['shellcheck'],
\   'terraform': ['tflint'],
\}

" Error navigation
nmap <silent> [e <Plug>(ale_previous_wrap)
nmap <silent> ]e <Plug>(ale_next_wrap)

" Show error details
nmap <Leader>d :ALEDetail<CR>
" }}}

" LIGHTLINE CONFIGURATION {{{
" -----------------------------------------------------------------------------
" Status line configuration
" -----------------------------------------------------------------------------
let g:lightline = {
\   'colorscheme': 'catppuccin_mocha',
\   'active': {
\     'left': [ ['mode', 'paste'],
\               ['gitbranch', 'readonly', 'filename', 'modified'] ],
\     'right': [ ['lineinfo'],
\                ['percent'],
\                ['fileformat', 'fileencoding', 'filetype'],
\                ['linter_errors', 'linter_warnings'] ]
\   },
\   'component_function': {
\     'gitbranch': 'FugitiveHead'
\   },
\   'component_expand': {
\     'linter_warnings': 'lightline#ale#warnings',
\     'linter_errors': 'lightline#ale#errors',
\   },
\   'component_type': {
\     'linter_warnings': 'warning',
\     'linter_errors': 'error',
\   },
\}

" Enable ALE integration with lightline
let g:lightline#ale#indicator_warnings = '⚠ '
let g:lightline#ale#indicator_errors = '✗ '
" }}}

" LANGUAGE-SPECIFIC SETTINGS {{{
" -----------------------------------------------------------------------------
" Language-specific plugin configurations
" -----------------------------------------------------------------------------

" Terraform
let g:terraform_fmt_on_save = 1
let g:terraform_align = 1

" Go
let g:go_def_mode = 'gopls'               " Use gopls for definitions
let g:go_info_mode = 'gopls'              " Use gopls for hover info
let g:go_fmt_command = 'goimports'        " Run goimports on save
let g:go_auto_type_info = 1               " Show type info automatically
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1

" Rust
let g:rustfmt_autosave = 1                " Auto-format on save
let g:rust_recommended_style = 1          " Use recommended style

" Julia
let g:latex_to_unicode_auto = 1           " Auto-convert LaTeX to unicode
" }}}

" AUTOCOMMANDS {{{
" -----------------------------------------------------------------------------
" File-type specific autocommands and behaviors
" -----------------------------------------------------------------------------
augroup VimrcAutocommands
  autocmd!

  " Return to last edit position when opening files
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  " Set fold method for vimrc (use markers)
  autocmd FileType vim setlocal foldmethod=marker

  " Auto-reload vimrc on save
  autocmd BufWritePost $MYVIMRC source $MYVIMRC | echom "Reloaded " . $MYVIMRC

augroup END

augroup FiletypeSettings
  autocmd!

  " Python: Use ftplugin for detailed settings
  " (see ~/.vim/after/ftplugin/python.vim)

  " Markdown: Enable spell check
  autocmd FileType markdown setlocal spell spelllang=en_us

  " Git commits: Enable spell check and set text width
  autocmd FileType gitcommit setlocal spell spelllang=en_us textwidth=72

augroup END
" }}}

" FZF CONFIGURATION {{{
" -----------------------------------------------------------------------------
" fzf.vim settings and customization
" -----------------------------------------------------------------------------
" Use ripgrep if available
if executable('rg')
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
  set grepprg=rg\ --vimgrep
endif

" fzf layout
let g:fzf_layout = { 'down': '40%' }

" Customize fzf colors to match color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }
" }}}

" GITGUTTER CONFIGURATION {{{
" -----------------------------------------------------------------------------
" Git diff indicators in sign column
" -----------------------------------------------------------------------------
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '~'
let g:gitgutter_sign_removed = '-'
let g:gitgutter_sign_modified_removed = '~-'

" Update more frequently
let g:gitgutter_realtime = 1
let g:gitgutter_eager = 1

" Jump between hunks
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)

" Stage/undo hunks
nmap <Leader>ha <Plug>(GitGutterStageHunk)
nmap <Leader>hu <Plug>(GitGutterUndoHunk)
nmap <Leader>hp <Plug>(GitGutterPreviewHunk)
" }}}

" PERFORMANCE OPTIMIZATIONS {{{
" -----------------------------------------------------------------------------
" Settings to keep vim responsive, especially over SSH
" -----------------------------------------------------------------------------
" Disable swap files (use version control instead)
set noswapfile
set nobackup
set nowritebackup

" But enable undo file for persistent undo
if has('persistent_undo')
  set undofile
  set undodir=~/.vim/undodir
  " Create undo directory if it doesn't exist
  if !isdirectory(expand('~/.vim/undodir'))
    call mkdir(expand('~/.vim/undodir'), 'p')
  endif
endif

" Faster redrawing
set ttyfast
set lazyredraw

" Limit syntax highlighting for long lines (performance)
set synmaxcol=300
" }}}

" LOCAL OVERRIDES {{{
" -----------------------------------------------------------------------------
" Load machine-specific or personal customizations
" -----------------------------------------------------------------------------
" Company-specific config (not in repo)
if filereadable(expand('~/.vimrc.spl'))
  source ~/.vimrc.spl
endif

" Secrets and sensitive config (not in repo)
if filereadable(expand('~/.vimrc.secrets'))
  source ~/.vimrc.secrets
endif

" Local machine customizations (not in repo)
if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
" }}}

" =============================================================================
" END OF CONFIGURATION
" =============================================================================
" vim:foldmethod=marker:foldlevel=0
