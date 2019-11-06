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
let g:ale_fix_on_save=1
let g:buffeline_echo=0
let g:startify_bookmarks= [
  \ stdpath('config') . '/nvim/init.vim', 
  \ stdpath('config') . '/nvim/config.d/01.plugins.vim',
  \ expand('~') . '/.zshrc',
  \ ]
let g:startify_commands = [
  \ [ 'Help', ':help reference' ],
  \ [ 'Reload', ':source $MYVIMRC' ],
  \ [ 'Update', 'call dein#update()' ] 
  \ ]
let g:startify_files_number=5
let g:startify_fortune_use_unicode=1
let g:startify_lists = [
  \ { 'type': 'sessions',   'header': ['  Last Session '] },
  \ { 'type': 'dir',        'header': ['  Current Directory: ' . getcwd()] },
  \ { 'type': 'files',      'header': ['  Recent Files'] },
  \ { 'type': 'commands',   'header': ['  Commands'] },
  \ { 'type': 'bookmarks',  'header': ['  Quick List'] }
  \ ]
let g:startify_session_autoload=1
let g:startify_session_delete_buffers=1
let g:startify_session_dir=stdpath('config') . '/nvim/session'
let g:startify_session_number=5
let g:startify_session_persistence=1
let g:startify_session_sort=1
let g:startify_update_oldfiles=1
let g:undotree_SetFocusWhenToggle=1
let g:undotree_WindowLayout=3
