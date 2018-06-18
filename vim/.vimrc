" Not compatible with legacy vi
set nocompatible		

" Set Shell
set shell=/bin/bash

" Switch of filetype handling
filetype off

" Use UTF8 encoding
set encoding=utf8		

" Display incomplete command
set showcmd				

" Highlight search matches 
set hlsearch 

" Incremental searching
set incsearch

" Searches are case sensitive
set ignorecase

" Searches are not case sensitive if they contain a single uppercase
set smartcase

" Tab Width
set tabstop=4			

" SoftTab Width
set softtabstop=4		

" Shift Width
set shiftwidth=4		

" Expand tabs to spaces
set expandtab			

" Automatically ident
set autoindent			

" Smart ident
set smartindent			

" Enable Ruler
set ruler				

" Don't create backup files
set nobackup			

" Disable write backup files
set nowritebackup

" Disable swap files
set noswapfile

" Disable undo files
set noundofile

" Automatically ident
set autoindent			

" Smart ident
set smartindent			

" Remove Toolbar
set go-=T				

" Set Error Files
set cf					

" Yanks go to Clipboard
set clipboard+=unnamed	

" Remember history for number of items
set history=256			

" Disable viminfo
set viminfo=""

set autowrite

set nu

" Don't wrap lines
set nowrap				

set timeoutlen=250

set laststatus=2

set noerrorbells

set nohlsearch

" Backspace through everything in insert mode
set backspace=indent,eol,start	

" Configure netwr
let g:netrw_browse_split = 4
let g:netrw_altv = 1

" Set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Vundle Plugin Manager
Plugin 'gmarik/Vundle.vim'

" Surrounding Wrapper Support
Plugin 'tpope/vim-surround'

" Tabular Alignment Support
Plugin 'godlygeek/tabular'

" Git Gutter Info
Plugin 'airblade/vim-gitgutter'

" Status line plugin
Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#hunks#enabled = 1

" Git Fugitive
Plugin 'tpope/vim-fugitive'

" Polyglot
Plugin 'sheerun/vim-polyglot'

call vundle#end()    

" Enable Indent Plugin
filetype plugin indent on

" Enable syntax highlighting
syntax enable

" Custom Mappings
" Remove Up/Down/Left/Right
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>

" Set git message info
autocmd Filetype gitcommit setlocal spell textwidth=72

" Auto Change Directory
autocmd BufEnter * silent! lcd %:p:h

" Set GUI font
set guifont=Fira\ Mono\ for\ Powerline:h12
