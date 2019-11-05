set runtimepath+=~/.config/nvim/plugcache/repos/github.com/Shougo/dein.vim

if dein#load_state('~/.config/nvim/plugcache')
    call dein#begin('~/.config/nvim/plugcache')
    call dein#add('~/.config/nvim/plugcache/repos/github.com/Shougo/dein.vim')
    call dein#add('NLKNguyen/papercolor-theme')
    call dein#add('Shougo/deoplete.nvim')
    call dein#add('airblade/vim-gitgutter')
    call dein#add('mhinz/vim-startify')
    call dein#add('scrooloose/nerdcommenter')
    call dein#add('tpope/vim-fugitive')
    call dein#add('vim-airline/vim-airline')
    call dein#add('vim-airline/vim-airline-themes')
    call dein#end()
    call dein#save_state()
endif

if dein#check_install()
    call dein#install()
endif
