let dein_path=stdpath('config') . '/plugcache/repos/github.com/Shougo/dein.vim'
execute 'set runtimepath+=' . dein_path
let dein_plug=stdpath('config') . '/plugcache'

if dein#load_state(dein_plug)
    call dein#begin(dein_plug)
    call dein#add(dein_path)
    "call dein#add('Chiel92/vim-autoformat')
    call dein#add('NLKNguyen/papercolor-theme')
    call dein#add('airblade/vim-gitgutter')
    call dein#add('mbbill/undotree')
    call dein#add('mhinz/vim-startify')
    call dein#add('scrooloose/nerdcommenter')
    "call dein#add('tpope/vim-fugitive')
    call dein#add('vim-airline/vim-airline')
    call dein#add('vim-airline/vim-airline-themes')
    call dein#end()
    call dein#save_state()
endif

if dein#check_install()
    call dein#install()
endif

unlet dein_path
unlet dein_plug
