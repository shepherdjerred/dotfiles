" Install vim-plug if it doesn't already exist
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
" Plug 'tpope/vim-surround'
Plug 'scrooloose/nerdtree'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'pearofducks/ansible-vim'
Plug 'takac/vim-hardtime'
" Plug '/usr/local/opt/fzf'
" Plug 'junegunn/fzf.vim'
Plug 'vim-scripts/paredit.vim'
Plug 'jgdavey/tslime.vim'
Plug 'luochen1990/rainbow'
call plug#end()

" For tslime
let g:tslime_always_current_session = 1
let g:tslime_always_current_window = 1

vmap <C-c><C-c> <Plug>SendSelectionToTmux
nmap <C-c><C-c> <Plug>NormalModeSendToTmux
nmap <C-c>r <Plug>SetTmuxVars

" Enable hard mode
" let g:hardtime_default_on = 1
let g:list_of_disabled_keys = ["<UP>", "<DOWN>", "<LEFT>", "<RIGHT>"]

" Show hidden files in nerdtree 
let NERDTreeShowHidden=1

" Set clipboard to system while in visual mode
" https://stackoverflow.com/questions/677986/vim-copy-selection-to-os-x-clipboard
" vmap <C-x> :!pbcopy<CR>  
" vmap <C-c> :w !pbcopy<CR><CR> 
" set clipboard=unnamed

" Hide -- INSERT --
set noshowmode

" https://dougblack.io/words/a-good-vimrc.html

set number " Show line numbers

syntax enable " Highlight based on language/syntax

" Tab settings
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set smartindent
set expandtab

filetype indent on " Indent based on file type

" Visual tab compleition with commands
set wildmenu

" Show matching parens/brackets
set showmatch

" Highlight search matches
set hlsearch

" YAML
" (for ansible)
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

