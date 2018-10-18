" Dein
if &compatible
 set nocompatible
endif
" Add the dein installation directory into runtimepath
set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

if dein#load_state('~/.cache/dein')
 call dein#begin('~/.cache/dein')

 call dein#add('~/.cache/dein')
 call dein#add('Shougo/deoplete.nvim')
 if !has('nvim')
   call dein#add('roxma/nvim-yarp')
   call dein#add('roxma/vim-hug-neovim-rpc')
 endif

 call dein#add('l04m33/vlime', {'rtp': 'vim/'})

 call dein#end()
 call dein#save_state()
endif



" Pathogen
execute pathogen#infect()



" Status line
let g:lightline = {
\ 'colorscheme': 'one'
\ }

" Hide -- INSERT --
set noshowmode



" https://dougblack.io/words/a-good-vimrc.html

set number " Show line numbers
" colorscheme zenburn

syntax enable " Highlight based on language/syntax

" Tab settings
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set smartindent
set expandtab

" set cursorline " Emphasize the line the cursor is one
filetype indent on " Indent based on file type

set wildmenu " Visual tab compleition with commands
set showmatch " Show matching parens/brackets

" Search
set incsearch
set hlsearch

" Vlime
let g:vlime_cl_impl = "my_sbcl"
        function! VlimeBuildServerCommandFor_my_sbcl(vlime_loader, vlime_eval)
            return ["/usr/local/bin/clisp",
                        \ "-i", "~/.cache/dein/repos/github.com/l04m33/vlime/lisp/start-vlime.lisp"]
        endfunction

autocmd FileType lisp setlocal shiftwidth=4 tabstop=4
