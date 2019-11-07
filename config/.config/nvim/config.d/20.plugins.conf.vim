" Airline
let g:airline#extensions#ale#enabled=1                      " Enable ALE plugin
let g:airline#extensions#branch#enabled=1                   " Show GIT branch
let g:airline#extensions#branch#format=1                    " Set GIT branch display format
let g:airline#extensions#bufferline#enabled=1               " Enable BufferLine plugin
let g:airline#extensions#bufferline#overwrite_variables=0   " Bufferline can't overwrite variables
let g:airline#extensions#cursormode#enabled=1               " Display cursor in different colors
let g:airline#extensions#fugitiveline#enabled=1             " Enable Fugitive plugin
let g:airline#extensions#hunks#enabled=1                    " Enable gitgutter plugin
let g:airline#extensions#tabline#enabled=1                  " Display tabline
let g:airline#extensions#tabline#formatter='unique_tail'    " Only show filename
let g:airline#extensions#tabline#show_buffers=0             " Don't show buggers with single tab
let g:airline_detect_spelllang=0                            " Hide spelling language
let g:airline_powerline_fonts=1                             " Enable powerline fonts
let g:airline_theme='papercolor'                            " Set theme to match global theme

" ALE
let g:ale_close_preview_on_insert=1                         " Close error preview on insert
let g:ale_cursor_detail=1                                   " Automatically open error preview
let g:ale_fix_on_save=1                                     " Fix errors on saving
let g:ale_sign_column_always=1                              " Always show the sign gutter

" Bufferline
let g:bufferline_echo=0                                     " Hide commands in commandline

" Startify
let g:startify_bookmarks= [
      \ stdpath('config') . '/init.vim',
      \ stdpath('config') . '/config.d/01.plugins.vim',
      \ stdpath('config') . '/config.d/02.plugins.vim',
      \ expand('~') . '/.zshrc',
      \ ]                                                       " Specify fixed bookmark list
let g:startify_commands = [
      \ [ 'Help', ':help reference' ],
      \ [ 'Reload', ':source $MYVIMRC' ],
      \ [ 'Update', 'call dein#update()' ]
      \ ]                                                       " Specify common commands
let g:startify_files_number=5                               " Limit to 5 files
let g:startify_fortune_use_unicode=1                        " Use unicode image
let g:startify_lists = [
      \ { 'type': 'sessions',   'header': [''] },
      \ { 'type': 'dir',        'header': ['  Current Directory: ' . getcwd()] },
      \ { 'type': 'files',      'header': ['  Recent Files'] },
      \ { 'type': 'commands',   'header': ['  Commands'] },
      \ { 'type': 'bookmarks',  'header': ['  Quick List'] }
      \ ]                                                       " Order and specify lists
let g:startify_session_dir=stdpath('config') . '/session'   " Directory to store sessions
let g:startify_session_number=1                             " Only save 1 session
let g:startify_session_sort=1                               " Sort session by last modified
let g:startify_update_oldfiles=1                            " Update old files immediatly

" UndoTree
let g:undotree_DiffpanelHeight=20                           " Set the height of the diff panel
let g:undotree_HelpLine=0                                   " Hide the helpline
let g:undotree_SetFocusWhenToggle=1                         " Switch to tree when opened
let g:undotree_SplitWidth=45                                " Set the width of the panel
let g:undotree_WindowLayout=3                               " Set the preferred layout
