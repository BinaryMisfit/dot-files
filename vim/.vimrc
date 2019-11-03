set nocompatible

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    else
        call CocAction('doHover')
    endif
endfunction

augroup mygroup
    autocmd!
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
Plug 'airblade/vim-gitgutter'
Plug 'bkad/CamelCaseMotion'
Plug 'chrisbra/sudoedit.vim'
Plug 'conradirwin/vim-bracketed-paste'
Plug 'easymotion/vim-easymotion'
Plug 'joshdick/onedark.vim'
Plug 'mhinz/vim-startify'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'scrooloose/nerdcommenter'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'vim-airline/vim-airline', {'branch': 'master'}
Plug 'vim-airline/vim-airline-themes', {'branch': 'master'}
Plug 'vim-scripts/ReplaceWithRegister'
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

inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
inoremap <silent><expr> <c-space> coc#refresh()
inoremap <silent><expr> <TAB>
            \ <SID>check_back_space() ? "\<TAB>" :
            \ coc#refresh()
            \ pumvisible() ? "\<C-n>" :

nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
nnoremap <silent> K :call <SID>show_documentation()<CR>

nmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>ac  <Plug>(coc-codeaction)
nmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>qf  <Plug>(coc-fix-current)
nmap <leader>rn <Plug>(coc-rename)
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> gs <Plug>(coc-range-select)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gy <Plug>(coc-type-definition)

omap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)

xmap <leader>a  <Plug>(coc-codeaction-selected)
xmap <leader>f  <Plug>(coc-format-selected)
xmap af <Plug>(coc-funcobj-a)
xmap if <Plug>(coc-funcobj-i)

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
