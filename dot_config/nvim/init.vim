" Install vim-plug if it doesn't already exist
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(stdpath('data') . '/plugged')
    Plug 'tpope/vim-sensible'
    Plug 'arcticicestudio/nord-vim'
    Plug 'airblade/vim-gitgutter'
    Plug 'preservim/nerdtree'
    Plug 'vim-airline/vim-airline'
    Plug 'pearofducks/ansible-vim'
    Plug 'takac/vim-hardtime'
call plug#end()

let g:airline_theme='nord'
colorscheme nord

" Enable hard mode
let g:hardtime_default_on = 1
let g:list_of_disabled_keys = ["<UP>", "<DOWN>", "<LEFT>", "<RIGHT>"]

let NERDTreeShowHidden=1

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

" https://www.chezmoi.io/docs/how-to/#configure-vim-to-run-chezmoi-apply-whenever-you-save-a-dotfile
autocmd BufWritePost ~/.local/share/chezmoi/* ! chezmoi apply --source-path %
