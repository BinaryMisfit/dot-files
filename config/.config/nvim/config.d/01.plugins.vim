let plug_install = 0
let autoload_plug_path = stdpath('config') . '/autoload/plug.vim'
if !filereadable(autoload_plug_path)
    silent exe '!curl -fL --create-dirs -o ' . autoload_plug_path .
        \ ' https://raw.github.com/junegunn/vim-plug/master/plug.vim'
    execute 'source ' . fnameescape(autoload_plug_path)
    let plug_install = 1
endif
unlet autoload_plug_path

call plug#begin()
Plug 'neoclide/coc.nvim', {'tag': '*',  'branch': 'release', 'do': { -> coc#util#install()}}
Plug 'airblade/vim-gitgutter'
Plug 'dense-analysis/ale'
Plug 'lambdalisue/suda.vim'
Plug 'mhinz/vim-startify'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
call plug#end()

if plug_install
    PlugInstall --sync | q
endif
unlet plug_install
