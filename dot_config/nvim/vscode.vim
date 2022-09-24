call plug#begin(stdpath('data') . '/plugged')
    Plug 'tpope/vim-sensible'
    Plug 'phaazon/hop.nvim'
    Plug 'andymass/vim-matchup'
    Plug 'tpope/vim-surround'
call plug#end()

:lua require'hop'.setup()

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
