" =============================================================================
" Rust filetype plugin
" =============================================================================
" Language-specific settings for Rust development
" This file is automatically loaded when editing Rust files
" =============================================================================

" Only load this once
if exists('b:did_ftplugin_rust')
  finish
endif
let b:did_ftplugin_rust = 1

" Indentation settings (Rust uses 4 spaces)
setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal expandtab
setlocal autoindent
setlocal smartindent

" Code folding
setlocal foldmethod=syntax
setlocal foldlevel=99

" ALE fixers and linters for Rust
let b:ale_fixers = ['rustfmt']
let b:ale_linters = ['analyzer', 'cargo']

" Line length (Rust recommends 100)
setlocal textwidth=100
setlocal colorcolumn=101

" Rust-specific key mappings
nnoremap <buffer> <Leader>r :!cargo run<CR>
nnoremap <buffer> <Leader>b :!cargo build<CR>
nnoremap <buffer> <Leader>t :!cargo test<CR>
nnoremap <buffer> <Leader>c :!cargo check<CR>

" Comments
setlocal commentstring=//\ %s

" Auto-format on save (handled by rust.vim plugin)
let b:rustfmt_autosave = 1

" Enhanced syntax highlighting
let g:rust_fold = 1
let g:rust_recommended_style = 1
