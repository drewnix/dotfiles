" =============================================================================
" Go filetype plugin
" =============================================================================
" Language-specific settings for Go development
" This file is automatically loaded when editing Go files
" =============================================================================

" Only load this once
if exists('b:did_ftplugin_go')
  finish
endif
let b:did_ftplugin_go = 1

" Indentation settings (Go uses TABS, not spaces)
setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal noexpandtab         " Use tabs, not spaces!
setlocal autoindent

" Code folding
setlocal foldmethod=syntax
setlocal foldlevel=99

" ALE fixers and linters for Go
let b:ale_fixers = ['gofmt', 'goimports']
let b:ale_linters = ['gopls', 'golint']

" Line length (Go doesn't have an official limit, but 100 is common)
setlocal textwidth=100
setlocal colorcolumn=101

" Go-specific key mappings
nnoremap <buffer> <Leader>r :!go run %<CR>
nnoremap <buffer> <Leader>b :!go build<CR>
nnoremap <buffer> <Leader>t :!go test ./...<CR>

" Show whitespace characters (useful since Go uses tabs)
setlocal list
setlocal listchars=tab:›\ ,trail:•,extends:#,nbsp:.

" Comments
setlocal commentstring=//\ %s

" Use goimports for formatting (set in main vimrc, but reinforce here)
let b:go_fmt_command = 'goimports'
