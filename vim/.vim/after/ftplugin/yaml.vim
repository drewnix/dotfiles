" =============================================================================
" YAML filetype plugin
" =============================================================================
" Language-specific settings for YAML files (including Kubernetes manifests)
" This file is automatically loaded when editing YAML files
" =============================================================================

" Only load this once
if exists('b:did_ftplugin_yaml')
  finish
endif
let b:did_ftplugin_yaml = 1

" Indentation settings (2 spaces is standard for YAML)
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
setlocal autoindent

" YAML is whitespace-sensitive, so be strict
setlocal nosmartindent
setlocal nocindent

" Code folding (based on indentation)
setlocal foldmethod=indent
setlocal foldlevel=99

" ALE fixers and linters for YAML
let b:ale_fixers = ['prettier', 'remove_trailing_lines', 'trim_whitespace']
let b:ale_linters = ['yamllint']

" Line length (some K8s manifests can be long)
setlocal textwidth=120
setlocal colorcolumn=121

" YAML-specific key mappings
" Validate Kubernetes manifests
nnoremap <buffer> <Leader>kv :!kubectl apply --dry-run=client -f %<CR>
" Show what would be created
nnoremap <buffer> <Leader>kd :!kubectl diff -f %<CR>

" Comments
setlocal commentstring=#\ %s

" Show whitespace characters (critical for YAML)
setlocal list
setlocal listchars=tab:»\ ,trail:•,extends:›,precedes:‹,nbsp:·

" Prevent tabs (YAML doesn't allow them)
setlocal expandtab

" Kubernetes-specific enhancements
" Auto-detect Kubernetes YAML files
function! DetectKubernetesYaml()
  if search('^\s*apiVersion:', 'nw') || search('^\s*kind:', 'nw')
    " This looks like a Kubernetes manifest
    setlocal filetype=yaml.kubernetes

    " Add K8s-specific abbreviations
    iabbrev <buffer> apiv apiVersion:
    iabbrev <buffer> meta metadata:
    iabbrev <buffer> spec spec:
    iabbrev <buffer> cont containers:
  endif
endfunction

augroup KubernetesYaml
  autocmd! * <buffer>
  autocmd BufReadPost <buffer> call DetectKubernetesYaml()
augroup END
