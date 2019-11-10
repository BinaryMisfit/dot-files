let g:ale_fix_on_save=1                                     " Fix errors on saving
let g:ale_sign_column_always=1                              " Always show the sign gutter
let g:ale_fixers={
      \ '*': ['remove_trailing_lines', 'trim_whitespace' ],
      \ 'json': ['fixjson'],
      \ 'yaml': ['prettier']
      \ }                                                   " Specify fixers to use
let g:ale_linters={
      \ 'json': ['jsonlint'],
      \ 'yaml': ['yamllint'],
      \ 'vim': ['vint'],
      \ }                                                   " Specify linters to use
