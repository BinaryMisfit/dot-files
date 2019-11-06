set runtimepath+=~/.config/nvim/plugcache/repos/github.com/Shougo/dein.vim

if dein#load_state('~/.config/nvim/plugcache')
    call dein#begin('~/.config/nvim/plugcache')
    call dein#add('~/.config/nvim/plugcache/repos/github.com/Shougo/dein.vim')
    call dein#add('Chiel92/vim-autoformat')
    call dein#add('NLKNguyen/papercolor-theme')
    call dein#add('airblade/vim-gitgutter')
    call dein#add('bling/vim-bufferline')
    call dein#add('dense-analysis/ale')
    call dein#add('junegunn/vim-easy-align')
    call dein#add('mbbill/undotree')
    call dein#add('mhinz/vim-startify')
    call dein#add('neoclide/coc.nvim', {'merge':0, 'rev': 'release'})
    call dein#add('scrooloose/nerdcommenter')
    call dein#add('sheerun/vim-polyglot')
    call dein#add('tpope/vim-fugitive')
    call dein#add('vim-airline/vim-airline')
    call dein#add('vim-airline/vim-airline-themes')
    call dein#add('vim-scripts/sessionman.vim')
    call dein#end()
    call dein#save_state()
endif

if dein#check_install()
    call dein#install()
endif
