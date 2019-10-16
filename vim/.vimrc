set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'Chiel92/vim-autoformat'
Plugin 'NLKNguyen/papercolor-theme'
Plugin 'sheerun/vim-polyglot'
Plugin 'vim-syntastic/syntastic'
Plugin 'tmux-plugins/vim-tmux-focus-events'
call vundle#end()
filetype plugin indent on
set autoread
set background=dark
set backspace=indent,eol,start
set encoding=utf-8
set expandtab
set fileencoding=utf-8
set fileencodings=utf-8
set history=80
set ignorecase
set incsearch
set nobackup
set nohlsearch
set noshowmode
set number
set nowrap
set nowritebackup
set ruler
set showcmd
set smartcase
set tabstop=4
set title
set shiftwidth=4
set undofile
set undodir=~/.vum/undo,~/tmp,/tmp
set viminfo='20,\"80
set visualbell
set wildmenu
set wildmode=longest:full,full
let g:airline_powerline_fonts = 1
let g:airline_theme = 'papercolor'
let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'jsformatter'
let g:airline#extensions#wordcount#enabled = 1
let g:netrw_liststyle = 1
let g:netrw_banner = 0
let g:netrw_browse_split = 0
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
autocmd Filetype gitcommit setlocal spell textwidth=72
autocmd BufEnter * silent! lcd %:p:h
autocmd BufWrite * :Autoformat
colorscheme PaperColor
syntax on
