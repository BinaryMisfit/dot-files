set nocompatible

if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
Plug 'airblade/vim-gitgutter', {'branch': 'master'}
Plug 'bkad/CamelCaseMotion', {'branch': 'master'}
Plug 'chrisbra/sudoedit.vim', {'branch': 'master'}
Plug 'easymotion/vim-easymotion', {'branch': 'master'}
Plug 'joshdick/onedark.vim', {'branch': 'master'}
Plug 'mhinz/vim-startify', {'branch': 'master'}
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neoclide/coc-css', {'branch': 'master'}
Plug 'neoclide/coc-emmet', {'branch': 'master'}
Plug 'neoclide/coc-html', {'branch': 'master'}
Plug 'neoclide/coc-json', {'branch': 'master'}
Plug 'neoclide/coc-python', {'branch': 'master'}
Plug 'neoclide/coc-yaml', {'branch': 'master'}
Plug 'scrooloose/nerdcommenter', {'branch': 'master'}
Plug 'tmux-plugins/vim-tmux-focus-events', {'branch': 'master'}
Plug 'vim-airline/vim-airline', {'branch': 'master'}
Plug 'vim-airline/vim-airline-themes', {'branch': 'master'}
Plug 'vim-scripts/ReplaceWithRegister', {'branch': 'master'}
call plug#end()

autocmd BufEnter * silent! lcd %:p:h
autocmd CursorHold * silent call CocActionAsync('highlight')
autocmd Filetype gitcommit setlocal spell textwidth=72
autocmd FileType json syntax match Comment +\/\/.\+$+

set autoread
set background=dark
set backspace=indent,eol,start
set cmdheight=2
set encoding=utf-8
set expandtab
set fileencoding=utf-8
set fileencodings=utf-8
set guifont=FiraCode\ NF:h12
set hidden
set history=80
set ignorecase
set incsearch
set list
set listchars=eol:$,nbsp:_,tab:>-,trail:~,extends:>,precedes:<
set macligatures
set nobackup
set nohlsearch
set noshowmode
set nowrap
set nowritebackup
set number
set ruler
set shiftwidth=4
set shortmess+=c
set showcmd
set signcolumn=yes
set smartcase
set spell spelllang=en_gb
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
set tabstop=4
set textwidth=80
set timeoutlen=2000
set title
set ttimeoutlen=100
set undodir=~/.vum/undo,~/tmp,/tmp
set undofile
set updatetime=300
set viminfo='20,\"80
set visualbell
set wildmenu
set wildmode=longest:full,full
set wrap
set wrapmargin=80

let g:airline#extensions#hunks#enabled = 1
let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'jsformatter'
let g:airline_powerline_fonts = 1
let g:airline_theme = 'onedark'
let g:netrw_banner = 0
let g:netrw_browse_split = 0
let g:netrw_liststyle = 1
let mapleader=","

command! -nargs=0 Format :call CocAction('format')
command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')
command! -nargs=? Fold :call CocAction('fold', <f-args>)

nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>

silent! colorscheme onedark

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
