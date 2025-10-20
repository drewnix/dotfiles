" =============================================================================
" JavaScript filetype plugin
" =============================================================================
" Language-specific settings for JavaScript development
" This file is automatically loaded when editing JavaScript files
" =============================================================================

" Only load this once
if exists('b:did_ftplugin_javascript')
  finish
endif
let b:did_ftplugin_javascript = 1

" Indentation settings (2 spaces is standard for JavaScript)
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
setlocal autoindent
setlocal smartindent

" Code folding
setlocal foldmethod=syntax
setlocal foldlevel=99

" ALE fixers and linters for JavaScript
let b:ale_fixers = ['prettier', 'eslint']
let b:ale_linters = ['eslint']

" Line length
setlocal textwidth=100
setlocal colorcolumn=101

" JavaScript-specific key mappings
nnoremap <buffer> <Leader>r :!node %<CR>

" Comments
setlocal commentstring=//\ %s

" Enhanced syntax highlighting
let g:javascript_plugin_jsdoc = 1
let g:javascript_plugin_flow = 1
