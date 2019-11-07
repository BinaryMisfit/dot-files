" Set the plugin directory
call plug#begin(plugins_path)

Plug 'NLKNguyen/papercolor-theme'             " Papercolor VIM theme
Plug 'mhinz/vim-startify'                     " Improved start page
Plug 'tpope/vim-fugitive'                     " Advanced GIT functionality
Plug 'airblade/vim-gitgutter'                 " Show GIT changes in gutter
Plug 'mbbill/undotree'                        " Visual undo tree
Plug 'scrooloose/nerdcommenter'               " Easy line comment functionality
Plug 'dense-analysis/ale'                     " Asynchronous lint engine
Plug 'vim-airline/vim-airline'                " Advanced tab and statusbar
Plug 'vim-airline/vim-airline-themes'         " Themes for airline
Plug 'ryanoasis/vim-devicons'                 " Enable file type icons

" Initialize plugins
call plug#end()
