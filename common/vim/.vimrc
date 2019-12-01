" Plugins
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/syntastic'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'pearofducks/ansible-vim'
call plug#end()

" Set clipboard to system while in visual mode
" https://stackoverflow.com/questions/677986/vim-copy-selection-to-os-x-clipboard
" vmap <C-x> :!pbcopy<CR>  
" vmap <C-c> :w !pbcopy<CR><CR> 
set clipboard=unnamed

" Hide -- INSERT --
" set noshowmode

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
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

