" =============================================================================
" TypeScript filetype plugin
" =============================================================================
" Language-specific settings for TypeScript development
" This file is automatically loaded when editing TypeScript files
" =============================================================================

" Only load this once
if exists('b:did_ftplugin_typescript')
  finish
endif
let b:did_ftplugin_typescript = 1

" Indentation settings (2 spaces is standard for TypeScript)
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
setlocal autoindent
setlocal smartindent

" Code folding
setlocal foldmethod=syntax
setlocal foldlevel=99

" ALE fixers and linters for TypeScript
let b:ale_fixers = ['prettier', 'eslint']
let b:ale_linters = ['eslint', 'tsserver']

" Line length
setlocal textwidth=100
setlocal colorcolumn=101

" TypeScript-specific key mappings
nnoremap <buffer> <Leader>r :!ts-node %<CR>

" Comments
setlocal commentstring=//\ %s
