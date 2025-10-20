" =============================================================================
" Python filetype plugin
" =============================================================================
" Language-specific settings for Python development
" This file is automatically loaded when editing Python files
" =============================================================================

" Only load this once
if exists('b:did_ftplugin_python')
  finish
endif
let b:did_ftplugin_python = 1

" Indentation settings (PEP 8)
setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal expandtab
setlocal autoindent
setlocal smartindent

" Text width to match black's default
setlocal textwidth=88
setlocal colorcolumn=89

" Code folding
setlocal foldmethod=indent
setlocal foldlevel=99

" ALE fixers and linters for Python
let b:ale_fixers = ['black', 'isort']
let b:ale_linters = ['flake8', 'mypy', 'pyright']

" Use Python 3 for syntax checking
let b:ale_python_flake8_executable = 'python3'
let b:ale_python_flake8_options = '--max-line-length=88'

" Show docstrings in folded text
setlocal foldtext=substitute(getline(v:foldstart),'\\t','\ \ \ \ ','g')

" Python-specific key mappings
nnoremap <buffer> <Leader>r :!python3 %<CR>
nnoremap <buffer> <Leader>t :!python3 -m pytest %<CR>

" Smart indenting for Python
setlocal cinwords=if,elif,else,for,while,try,except,finally,def,class,with

" Enhanced syntax highlighting
let python_highlight_all = 1
let python_highlight_space_errors = 0  " Disable (ALE handles this)

" Comments
setlocal commentstring=#\ %s
