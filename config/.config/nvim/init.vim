let g:python_host_prog  = '/Library/Frameworks/Python.framework/Versions/2.7/bin/python2'
let g:python3_host_prog = '/Library/Frameworks/Python.framework/Versions/3.8/bin/python3'

for f in split(glob(stdpath('config') . '/config.d/*.vim'), '\n')
    exe 'source' f
endfor

call deoplete#custom#option('ignore_sources', {'_': ['around', 'buffer']})

let g:airline#extensions#ale#enabled=1
let g:airline#extensions#branch#enabled=1
let g:airline#extensions#branch#format=1
let g:airline#extensions#coc#enabled=1
let g:airline#extensions#cursormode#enabled=1
let g:airline#extensions#hunks#enabled=1
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#formatter='unique_tail'
let g:airline#extensions#tabline#show_tabs=1
let g:airline_detect_spelllang=0
let g:airline_powerline_fonts=1
let g:deoplete#enable_at_startup=1
let g:startify_update_oldfiles=1
let g:startify_fortune_use_unicode=0
let mapleader=','

set cmdheight=2
set clipboard+=unnamed
set expandtab
set hidden
set ignorecase
set list
set nobackup
set nohlsearch
set noshowmode
set nowrap
set nowritebackup
set number
set shiftwidth=4
set smartcase
set spell spelllang=en_gb
set tabstop=4
set textwidth=80
set title
set undofile
set updatetime=100
set viminfo='20,\"80
set visualbell
set wrap
set wrapmargin=80

nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>

autocmd! BufEnter * silent! lcd %:p:h
autocmd! BufWritePost $MYVIMRC call ReloadConfig()
autocmd! BufWritePre * %s/\s\+$//e
autocmd! FileType json syntax match Comment +\/\/.\+$+
autocmd! Filetype gitcommit setlocal spell textwidth=72

if !exists('*ReloadConfig')
    fun! ReloadConfig()
        let save_cursor = getcurpos()
        source $MYVIMRC
        call setpos('.', save_cursor)
    endfun
endif
