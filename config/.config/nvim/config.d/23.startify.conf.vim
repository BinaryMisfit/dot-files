let g:startify_bookmarks= [
      \ stdpath('config') . '/config.d/00.init.vim',
      \ stdpath('config') . '/config.d/10.plugins.vim',
      \ expand('~') . '/.zshrc',
      \ ]                                                       " Specify fixed bookmark list
let g:startify_commands = [
      \ [ 'Check', ':checkhealth' ],
      \ [ 'Update', ':PlugUpdate' ],
      \ [ 'Upgrade', ':PlugUpgrade' ],
      \ [ 'Help', ':help reference' ],
      \ [ 'Tips', ':help vimtips' ]
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
let g:startify_session_dir=stdpath('data') . '/session'   " Directory to store sessions
let g:startify_session_number=1                             " Only save 1 session
let g:startify_session_sort=1                               " Sort session by last modified
let g:startify_update_oldfiles=1                            " Update old files immediatly
