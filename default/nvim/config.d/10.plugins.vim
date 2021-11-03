" Set the plugin directory
call plug#begin(plugins_path)

Plug 'junegunn/vim-plug'                                " Vim plugin manager
if !exists('g:vscode')
  Plug 'morhetz/gruvbox'                                " Gruvbox Theme
  Plug 'tmux-plugins/vim-tmux-focus-events'             " Better handle tmux focus events
  Plug 'roxma/vim-tmux-clipboard'                       " Better TMUX copy and paster
  Plug 'mhinz/vim-startify'                             " Improved start page
  Plug 'tpope/vim-fugitive'                             " Advanced GIT functionality
  Plug 'airblade/vim-gitgutter'                         " Show GIT changes in gutter
  Plug 'mbbill/undotree'                                " Visual undo tree
  Plug 'scrooloose/nerdtree'                            " NERDTree file navigator
  Plug 'scrooloose/nerdcommenter'                       " Easy line comment functionality
  Plug 'dense-analysis/ale'                             " Asynchronous lint engine
  Plug 'neoclide/coc.nvim', {'branch': 'release'}       " Code completion
  Plug 'neoclide/jsonc.vim'                             " JSON with comments support
  Plug 'vim-airline/vim-airline'                        " Advanced tab and statusbar
  Plug 'vim-airline/vim-airline-themes'                 " Themes for airline
  Plug 'zeekay/vimtips'                                 " Usefull VIM tips and tricks
  Plug 'ryanoasis/vim-devicons'                         " Enable file type icons
  Plug 'sheerun/vim-polyglot'                           " Syntax Highligting
endif

" Initialize plugins
call plug#end()
