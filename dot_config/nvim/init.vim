" Install vim-plug if it doesn't already exist
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(stdpath('data') . '/plugged')
    Plug 'tpope/vim-sensible'
    Plug 'airblade/vim-gitgutter'
    Plug 'preservim/nerdtree'
    Plug 'vim-airline/vim-airline'
    Plug 'phaazon/hop.nvim'
    Plug 'tpope/vim-fugitive'
    Plug 'nacro90/numb.nvim'
    Plug 'camspiers/snap'
    Plug 'andymass/vim-matchup'
    Plug 'f-person/git-blame.nvim'
    Plug 'tpope/vim-surround'
call plug#end()

:lua require'hop'.setup()

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

" Visual tab completion with commands
set wildmenu

" Show matching parens/brackets
set showmatch

" Highlight search matches
set hlsearch
