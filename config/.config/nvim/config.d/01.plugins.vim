" Configures the runtime path to include dein and plugcache
let dein_path=stdpath('config') . '/plugcache/repos/github.com/Shougo/dein.vim'
execute 'set runtimepath+=' . dein_path
let dein_plug=stdpath('config') . '/plugcache'

" Configure the plugins to load"
if dein#load_state(dein_plug)
    call dein#begin(dein_plug)
    call dein#add(dein_path)                    " Add dein to update check
    "call dein#add('Chiel92/vim-autoformat')
    call dein#add('NLKNguyen/papercolor-theme') " Papercolor VIM theme
    call dein#add('airblade/vim-gitgutter')     " Show GIT changes in gutter
    call dein#add('mbbill/undotree')            " Visual undo tree
    call dein#add('mhinz/vim-startify')         " Improved start page
    "call dein#add('scrooloose/nerdcommenter')
    "call dein#add('tpope/vim-fugitive')
    call dein#add('vim-airline/vim-airline')    " Advanced tab and statusbar
    "call dein#add('vim-airline/vim-airline-themes')
    call dein#end()
    call dein#save_state()
endif

" Check if new plugins need to be installed
if dein#check_install()
    call dein#install()
endif

unlet dein_path
unlet dein_plug
