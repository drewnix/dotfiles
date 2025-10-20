" =============================================================================
" Terraform filetype plugin
" =============================================================================
" Language-specific settings for Terraform/HCL development
" This file is automatically loaded when editing Terraform files
" =============================================================================

" Only load this once
if exists('b:did_ftplugin_terraform')
  finish
endif
let b:did_ftplugin_terraform = 1

" Indentation settings (2 spaces is standard for HCL/Terraform)
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
setlocal autoindent

" Code folding
setlocal foldmethod=syntax
setlocal foldlevel=99

" ALE fixers and linters for Terraform
let b:ale_fixers = ['terraform']
let b:ale_linters = ['terraform', 'tflint']

" Line length
setlocal textwidth=120
setlocal colorcolumn=121

" Terraform-specific key mappings
nnoremap <buffer> <Leader>tf :!terraform fmt %<CR>
nnoremap <buffer> <Leader>tv :!terraform validate<CR>
nnoremap <buffer> <Leader>tp :!terraform plan<CR>

" Comments
setlocal commentstring=#\ %s

" Auto-format on save (handled by vim-terraform plugin)
let b:terraform_fmt_on_save = 1
let b:terraform_align = 1
