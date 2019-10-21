set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'conradirwin/vim-bracketed-paste'
Plugin 'NLKNguyen/papercolor-theme'
Plugin 'scrooloose/nerdcommenter'
Plugin 'mhinz/vim-startify'
Plugin 'chrisbra/sudoedit.vim'
Plugin 'edkolev/tmuxline.vim'
Plugin 'tmux-plugins/vim-tmux-focus-events'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'elzr/vim-json'
Plugin 'ycm-core/YouCompleteMe'
call vundle#end()
filetype plugin indent on
set autoread
set background=light
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
set nowrap
set nowritebackup
set number
set ruler
set shiftwidth=4
set showcmd
set smartcase
set tabstop=4
set timeoutlen=2000
set title
set ttimeoutlen=100
set undodir=~/.vum/undo,~/tmp,/tmp
set undofile
set viminfo='20,\"80
set visualbell
set wildmenu
set wildmode=longest:full,full
let g:airline#extensions#hunks#enabled = 1
let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'jsformatter'
let g:airline_powerline_fonts = 1
let g:airline_theme = 'papercolor'
let g:netrw_banner = 0
let g:netrw_browse_split = 0
let g:netrw_liststyle = 1
let g:ycm_max_num_candidates = 20
let g:ycm_max_num_identifier_candidates = 5
let g:ycm_min_num_identifier_candidate_chars = 3
let g:ycm_min_num_of_chars_for_completion = 3
let mapleader=","
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
autocmd Filetype gitcommit setlocal spell textwidth=72
autocmd BufEnter * silent! lcd %:p:h
silent! colorscheme PaperColor
syntax on
if exists('$TMUX') && $LC_TERMINAL =~ "iTerm"
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
elseif $LC_TERMINAL =~ "iTerm"
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
else
    let &t_SI="\<CSI>5 q"
    let &t_EI="\<CSI>1 q"
endif
