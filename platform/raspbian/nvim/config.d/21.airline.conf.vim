if !exists('g:vscode')
  let g:airline#extensions#ale#enabled=1                      " Enable ALE plugin
  let g:airline#extensions#branch#enabled=1                   " Show GIT branch
  let g:airline#extensions#branch#format=1                    " Set GIT branch display format
  let g:airline#extensions#coc#enable=1                       " Enable coc support
  let g:airline#extensions#cursormode#enabled=1               " Display cursor in different colors
  let g:airline#extensions#fugitiveline#enabled=1             " Enable Fugitive plugin
  let g:airline#extensions#hunks#enabled=1                    " Enable gitgutter plugin
  let g:airline#extensions#tabline#enabled=1                  " Display tabline
  let g:airline#extensions#tabline#formatter='unique_tail'    " Only show filename
  let g:airline#extensions#tabline#show_buffers=0             " Don't show buffers with single tab
  let g:airline#extensions#tabline#show_close_button=0        " Don't show close button
  let g:airline#extensions#tabline#show_splits=0              " Don't show split in tabline
  let g:airline#extensions#tabline#show_tab_nr=0              " Don't show number in tabline
  let g:airline#extensions#tabline#show_tab_type=0            " Don't show tab types
  let g:airline_detect_spelllang=0                            " Hide spelling language
  let g:airline_powerline_fonts=0                             " Enable powerline fonts
  let g:airline_theme='material'                            " Set theme to match global theme
endif
