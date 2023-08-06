colo kellys
set guifont=Inconsolata:h16
syn on
set foldmethod=syntax
so ~/.vim/ftplugin/python_fold.vim
set nocompatible

" vundle
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" Plugins
Plugin 'JuliaLang/julia-vim'

call vundle#end()            " required
filetype plugin indent on    " required


set mouse=a

" Set my prefered mapleader
let mapleader = ","

" Tlist config options
let Tlist_Ctags_Cmd = '/usr/local/bin/ctags'
let Tlist_WinWidth  = 33
let Tlist_File_Fold_Auto_Close = 1
let Tlist_Show_One_File = 1
let Tlist_Auto_Open = 1
let Tlist_Use_Right_Window = 1

let g:rainbow_active = 1

" Buffer management settings
set hidden

" Remap ' to the more useful ` (for better marking/jumping)
nnoremap ' `
nnoremap ` '

" Set a longer command history
set history=1000

" Set ExDev path
let $EX_DEV='/home/atanner/.vim/ex_dev'

" Mappings for easy vimrc editing/reloading

map <leader>ev :e ~/.vimrc<cr>
map <leader>rv :so ~/.vimrc<cr>
map <leader>P :TlistToggle<cr>
map <leader>M :ExmbToggle<cr>

" exVim mappings
nnoremap <unique> <silent> <Leader>gs :ExgsSelectToggle<CR>
nnoremap <unique> <silent> <Leader>gq :ExgsQuickViewToggle<CR>
nnoremap <unique> <silent> <Leader>gg :ExgsGoDirectly<CR>
nnoremap <unique> <silent> <Leader>n :ExgsGotoNextResult<CR>
nnoremap <unique> <silent> <Leader>N :ExgsGotoPrevResult<CR>
nnoremap <unique> <leader>ms :ExmbToggle<CR>
nnoremap <unique> <silent> <Leader>ss :ExslSelectToggle<CR>
nnoremap <unique> <silent> <Leader>sq :ExslQuickViewToggle<CR>
nnoremap <unique> <silent> <Leader>sg :ExslGoDirectly<CR>
nnoremap <unique> <leader>tt :ExjsToggle<CR>
nnoremap <unique> <silent> <Leader>tb :BackwardStack<CR>
nnoremap <unique> <silent> <Leader>tf :ForwardStack<CR>

" Make tabs expand to 4 spaces
set tabstop=4
set expandtab

" When using cmdline vim, show a useful title
set title

" Enable ruler with vertical,horizontal line position
set ruler

" Enable wildmenu for command line surfing
set wildmenu
set wildmode=list:longest

" Set cmap location shortcuts
cmap >v e ~/.vim/
cmap >p e ~/dev/pynfs
cmap >h e ~/
cmap >l e ~/dev/qa/head/lists
cmap >n e ~/dev/qa/head/lists/protocols/nfs
"cmap >fn <c-r>=expand('%:p')<cr>
"cmap >fd <c-r>=expand('%:p:h').'/'<cr>

" Create centralized vim-tmp file stores
"set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
"set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp


map <D-F11> :Tlist<CR>

if !exists("autocommands_loaded")
  let autocommands_loaded = 1
  autocmd BufRead,BufNewFile,FileReadPost *.py source ~/.vim/python
endif

" This beauty remembers where you were the last time you edited the file, and returns to the same position.
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif


